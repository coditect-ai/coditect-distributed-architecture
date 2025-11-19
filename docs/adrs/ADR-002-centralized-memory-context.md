# ADR-002: Centralized Memory Context

## Status

**Accepted** - 2025-11-18

## Context

CODITECT uses `/export` files to capture conversation context for session continuity. We need to determine how to:
- Store exports from multiple projects
- Deduplicate redundant content
- Maintain session continuity across projects
- Prevent catastrophic forgetting from context compaction

### Current Problems

1. **Scattered exports**: Each project has its own MEMORY-CONTEXT
2. **Duplication**: Same messages stored multiple times across projects
3. **No global view**: Cannot see all context in one place
4. **Forgetting risk**: Compaction without backup loses context forever

### Requirements

1. Single location for all exports
2. Global deduplication across all sessions
3. Session continuity tracking
4. Zero message loss (catastrophic forgetting prevention)
5. Efficient storage and retrieval

## Decision

Implement a **centralized MEMORY-CONTEXT** at the PROJECTS root level.

### Architecture

```
PROJECTS/
├── MEMORY-CONTEXT/                   # CENTRAL memory for ALL projects
│   ├── dedup_state/                  # Global deduplication tracking
│   │   ├── message_hashes.json       # All unique message hashes
│   │   ├── checkpoints.json          # Checkpoint metadata
│   │   └── watermarks.json           # Per-session watermarks
│   │
│   ├── exports-archive/              # Archived raw exports
│   │   ├── 2025-11-18-project-a.txt
│   │   └── 2025-11-18-project-b.txt
│   │
│   ├── sessions/                     # Processed session data
│   │   ├── 2025-11-18-session-1.md   # Extracted context
│   │   └── 2025-11-18-session-1.json # Structured data
│   │
│   └── index/                        # Search and retrieval
│       ├── topics.json               # Topic index
│       ├── entities.json             # Entity index
│       └── timeline.json             # Chronological index
```

### Deduplication Strategy

1. **Hash-based deduplication**
   - SHA-256 hash of each message content
   - Global hash set across all sessions
   - Only store new unique messages

2. **Watermark tracking**
   - Track last processed message per session
   - Resume from watermark on incremental updates
   - Prevent reprocessing

3. **Semantic deduplication** (future)
   - Embedding-based similarity
   - Merge near-duplicates
   - Preserve unique context

### Export Processing Flow

```
[Project Export] → [export-dedup.py] → [MEMORY-CONTEXT/]
     │                    │                    │
     │                    ├─ Hash & dedupe     ├─ dedup_state/
     │                    ├─ Extract context   ├─ sessions/
     │                    └─ Archive original  └─ exports-archive/
```

### Key Components

1. **export-dedup.py**
   - Parses Claude export files
   - Computes message hashes
   - Filters duplicates against global state
   - Extracts structured context (git, tasks, decisions)
   - Archives original export

2. **dedup_state/**
   - `message_hashes.json`: Set of all unique hashes
   - `checkpoints.json`: Checkpoint metadata
   - `watermarks.json`: Per-session progress tracking

3. **sessions/**
   - Processed session summaries
   - Extracted decisions and context
   - Ready for session continuity

## Alternatives Considered

### Alternative 1: Distributed MEMORY-CONTEXT per Project

```
Project-1/MEMORY-CONTEXT/
Project-2/MEMORY-CONTEXT/
```

**Rejected because**:
- Duplicate messages across projects
- No global view
- Complex cross-project queries
- Higher storage requirements

### Alternative 2: Database Storage

```
PostgreSQL with message table
```

**Rejected because**:
- Overkill for current scale
- Harder to version control
- Less portable
- Adds infrastructure dependency

### Alternative 3: Cloud Storage (S3)

**Rejected because**:
- Adds cloud dependency
- Latency for local operations
- Cost for frequent access

## Consequences

### Positive

1. **Zero forgetting**: All unique messages preserved forever
2. **Efficient storage**: 95%+ deduplication typical
3. **Global search**: Query across all projects/sessions
4. **Session continuity**: Easy to resume any session
5. **Single backup point**: One directory to backup
6. **Audit trail**: Complete history of all interactions

### Negative

1. **Single point of failure**: MEMORY-CONTEXT corruption affects all
   - **Mitigation**: Regular backups, git versioning

2. **Growing storage**: Accumulates over time
   - **Mitigation**: Compression, archival strategy

3. **Cross-project coupling**: All projects share memory
   - **Mitigation**: Session tagging for filtering

### Risks

1. **Backup failure**: Losing MEMORY-CONTEXT loses all history
   - **Mitigation**: Automated daily backups, cloud sync

2. **Corruption**: JSON corruption breaks deduplication
   - **Mitigation**: Validation on load, backup before write

## Implementation

### Initial Setup

```bash
mkdir -p PROJECTS/MEMORY-CONTEXT/{dedup_state,exports-archive,sessions,index}

# Initialize dedup state
echo '[]' > PROJECTS/MEMORY-CONTEXT/dedup_state/message_hashes.json
echo '{}' > PROJECTS/MEMORY-CONTEXT/dedup_state/checkpoints.json
echo '{}' > PROJECTS/MEMORY-CONTEXT/dedup_state/watermarks.json
```

### Export Processing

```bash
# After /export in Claude Code
python3 .coditect/scripts/export-dedup.py \
  --input /path/to/export.txt \
  --memory-context PROJECTS/MEMORY-CONTEXT
```

### Backup

```bash
# Daily backup cron
tar -czf memory-backup-$(date +%Y%m%d).tar.gz PROJECTS/MEMORY-CONTEXT/
```

## Related Decisions

- **ADR-001**: Distributed Brain Architecture
- **ADR-004**: Export Deduplication Strategy (details algorithm)

## References

- [Mem0 Memory Architecture](https://mem0.ai)
- [LangGraph Checkpointing](https://langchain-ai.github.io/langgraph/)
- [Catastrophic Forgetting Prevention](https://arxiv.org/abs/1612.00796)
