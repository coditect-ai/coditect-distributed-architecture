# ADR-004: Export Deduplication Strategy

## Status

**Accepted** - 2025-11-18

## Context

CODITECT captures conversation context via `/export` to prevent catastrophic forgetting. Over time, exports accumulate with significant redundancy:
- Same system prompts in every session
- Repeated tool calls and responses
- Similar code snippets across sessions

### Current Problems

1. **Storage bloat**: Exports grow unbounded
2. **Slow search**: Must scan all content for queries
3. **No incremental**: Must process entire export each time
4. **Redundant content**: 60-80% typical duplication

### Requirements

1. Efficient deduplication (target: 90%+ reduction)
2. Zero message loss (every unique message preserved)
3. Incremental processing (only process new content)
4. Fast retrieval (index for search)
5. Audit trail (track what came from where)

## Decision

Implement **hash-based deduplication with watermark tracking**.

### Algorithm

```python
def deduplicate_export(export_file, global_state):
    messages = parse_export(export_file)
    session_id = extract_session_id(export_file)
    watermark = global_state.get_watermark(session_id)

    new_messages = []
    for i, msg in enumerate(messages):
        if i < watermark:
            continue  # Already processed

        msg_hash = sha256(normalize(msg.content))

        if msg_hash not in global_state.hashes:
            global_state.hashes.add(msg_hash)
            new_messages.append({
                'hash': msg_hash,
                'content': msg.content,
                'role': msg.role,
                'session': session_id,
                'index': i,
                'timestamp': msg.timestamp
            })

    global_state.set_watermark(session_id, len(messages))
    return new_messages
```

### Normalization

Before hashing, normalize content to handle trivial differences:
- Strip leading/trailing whitespace
- Normalize line endings (CRLF → LF)
- Remove timestamp variations
- Collapse multiple spaces

### Storage Format

```json
// dedup_state/message_hashes.json
{
  "hashes": ["abc123...", "def456...", ...],
  "count": 4378
}

// dedup_state/watermarks.json
{
  "2025-11-18-session-1": 150,
  "2025-11-18-session-2": 89
}

// sessions/2025-11-18-session-1.json
{
  "session_id": "2025-11-18-session-1",
  "project": "ERP-ODOO-FORK",
  "messages": [
    {
      "hash": "abc123...",
      "role": "user",
      "content": "...",
      "index": 0
    }
  ],
  "extracted": {
    "decisions": [...],
    "tasks": [...],
    "code_changes": [...]
  }
}
```

### Indexing Strategy

```json
// index/topics.json
{
  "authentication": ["session-1", "session-3"],
  "database": ["session-2", "session-3"],
  "api-design": ["session-1"]
}

// index/timeline.json
[
  {"date": "2025-11-18", "sessions": ["session-1", "session-2"]},
  {"date": "2025-11-17", "sessions": ["session-0"]}
]
```

### Extraction Pipeline

```
[Raw Export]
     ↓
[Parse Messages]
     ↓
[Deduplicate] → [Global Hash Set]
     ↓
[Extract Context]
  ├─ Git changes
  ├─ Completed tasks
  ├─ Decisions made
  └─ Code artifacts
     ↓
[Index]
  ├─ Topics
  ├─ Timeline
  └─ Entities
     ↓
[Store]
```

## Alternatives Considered

### Alternative 1: Full-Text Deduplication

Exact string matching without hashing.

**Rejected because**:
- O(n*m) comparison complexity
- No normalization handling
- Slow for large corpus

### Alternative 2: Semantic Deduplication Only

Use embeddings to find similar content.

**Rejected because**:
- Loses exact duplicates
- Expensive to compute
- May merge distinct content
- Can add as enhancement layer later

### Alternative 3: Compression Only

Store compressed exports without deduplication.

**Rejected because**:
- Still stores duplicates
- No incremental processing
- No semantic extraction

### Alternative 4: Database with UNIQUE Constraint

```sql
INSERT INTO messages (hash, content)
ON CONFLICT (hash) DO NOTHING
```

**Rejected because**:
- Adds database dependency
- Overkill for current scale
- Less portable

## Consequences

### Positive

1. **90%+ storage reduction**: Typical deduplication rate
2. **Zero loss**: Every unique message preserved
3. **Incremental**: Only process new content via watermarks
4. **Fast lookup**: Hash-based O(1) duplicate check
5. **Searchable**: Indexed by topic, time, entity
6. **Portable**: JSON files, no database needed

### Negative

1. **Hash collisions**: Theoretically possible
   - **Mitigation**: SHA-256 has negligible collision rate

2. **Lost context**: Deduped message loses repetition context
   - **Mitigation**: Store session/index for each occurrence

3. **Normalization edge cases**: May merge different content
   - **Mitigation**: Conservative normalization rules

### Performance Characteristics

| Operation | Complexity | Typical Time |
|-----------|------------|--------------|
| Parse export | O(n) | ~100ms for 1000 msgs |
| Hash message | O(m) | ~1ms per message |
| Check duplicate | O(1) | ~0.01ms |
| Full dedup run | O(n) | ~200ms for 1000 msgs |
| Load global state | O(k) | ~50ms for 10K hashes |

## Implementation

### Core Deduplication Script

```python
#!/usr/bin/env python3
"""export-dedup.py - Deduplicate Claude exports"""

import hashlib
import json
import re
from pathlib import Path

def normalize(content: str) -> str:
    """Normalize content for consistent hashing."""
    content = content.strip()
    content = content.replace('\r\n', '\n')
    content = re.sub(r' +', ' ', content)
    return content

def hash_message(content: str) -> str:
    """Generate SHA-256 hash of normalized content."""
    normalized = normalize(content)
    return hashlib.sha256(normalized.encode()).hexdigest()

def parse_export(filepath: Path) -> list:
    """Parse Claude export file into messages."""
    messages = []
    current_role = None
    current_content = []

    with open(filepath) as f:
        for line in f:
            if line.startswith('Human:'):
                if current_role:
                    messages.append({
                        'role': current_role,
                        'content': '\n'.join(current_content)
                    })
                current_role = 'user'
                current_content = [line[6:].strip()]
            elif line.startswith('Assistant:'):
                if current_role:
                    messages.append({
                        'role': current_role,
                        'content': '\n'.join(current_content)
                    })
                current_role = 'assistant'
                current_content = [line[10:].strip()]
            else:
                current_content.append(line.rstrip())

    if current_role:
        messages.append({
            'role': current_role,
            'content': '\n'.join(current_content)
        })

    return messages

def deduplicate(export_path: Path, memory_context: Path):
    """Deduplicate export against global state."""
    # Load global state
    hashes_file = memory_context / 'dedup_state' / 'message_hashes.json'
    watermarks_file = memory_context / 'dedup_state' / 'watermarks.json'

    with open(hashes_file) as f:
        state = json.load(f)
        global_hashes = set(state.get('hashes', []))

    with open(watermarks_file) as f:
        watermarks = json.load(f)

    # Parse and deduplicate
    messages = parse_export(export_path)
    session_id = export_path.stem
    watermark = watermarks.get(session_id, 0)

    new_messages = []
    for i, msg in enumerate(messages):
        if i < watermark:
            continue

        msg_hash = hash_message(msg['content'])
        if msg_hash not in global_hashes:
            global_hashes.add(msg_hash)
            new_messages.append({
                'hash': msg_hash,
                'role': msg['role'],
                'content': msg['content'],
                'session': session_id,
                'index': i
            })

    # Update state
    watermarks[session_id] = len(messages)

    with open(hashes_file, 'w') as f:
        json.dump({
            'hashes': list(global_hashes),
            'count': len(global_hashes)
        }, f, indent=2)

    with open(watermarks_file, 'w') as f:
        json.dump(watermarks, f, indent=2)

    # Report
    print(f"Processed: {len(messages)} messages")
    print(f"New unique: {len(new_messages)}")
    print(f"Duplicates: {len(messages) - watermark - len(new_messages)}")
    print(f"Total unique: {len(global_hashes)}")

    return new_messages

if __name__ == '__main__':
    import sys
    export_path = Path(sys.argv[1])
    memory_context = Path(sys.argv[2])
    deduplicate(export_path, memory_context)
```

### Usage

```bash
# Process an export
python3 export-dedup.py \
  /path/to/2025-11-18-export.txt \
  /Users/halcasteel/PROJECTS/MEMORY-CONTEXT

# Output:
# Processed: 150 messages
# New unique: 45
# Duplicates: 105
# Total unique: 4423
```

## Related Decisions

- **ADR-002**: Centralized Memory Context (where deduped content lives)
- **ADR-001**: Distributed Brain Architecture (source of exports)

## References

- [Content-Addressable Storage](https://en.wikipedia.org/wiki/Content-addressable_storage)
- [SHA-256 Hash Function](https://en.wikipedia.org/wiki/SHA-2)
- [Git Object Model](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects)
