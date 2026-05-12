---
title: Postgres
tags: [Database , RDBMS ] 
---
# PostgreSQL — Sone My Notes

---

## Table of Contents

1. [Index Types](#1-index-types)
2. [Transaction Isolation Levels & Phantom Reads](#2-transaction-isolation-levels--phantom-reads)
3. [Query Planning](#3-query-planning)
4. [MVCC — xmin, xmax, and Dead Tuples](#4-mvcc--xmin-xmax-and-dead-tuples)
5. [VACUUM](#5-vacuum)
6. [Heap & Bitmap Index Scan](#6-heap--bitmap-index-scan)
7. [JOIN Types & Best Practices](#7-join-types--best-practices)
8. [PostgreSQL vs MySQL vs MS SQL Server](#8-postgresql-vs-mysql-vs-ms-sql-server)

---

## 1. Index Types

### B-tree (Default)
The most versatile index. Internally a balanced tree — every lookup is O(log n).

- Supports `=`, `<`, `>`, `<=`, `>=`, `BETWEEN`, `LIKE 'abc%'` (prefix only)
- Used for `ORDER BY` and `DISTINCT`
- Use this unless you have a specific reason not to

```sql
CREATE INDEX ON orders (created_at);
```

### Hash
Stores a hash of the column value.

- Only supports `=`
- Slightly faster than B-tree for pure equality on large tables
- No range queries, no sorting
- Safe since Postgres 10 (previously not WAL-logged)

```sql
CREATE INDEX ON users USING hash (email);
```

### GIN — Generalized Inverted Index
Maps each *element* to the rows containing it (like a book index).

Best for:
- **JSONB** — `WHERE data @> '{"status": "active"}'`
- **Arrays** — `WHERE tags @> ARRAY['postgres']`
- **Full-text search** — `WHERE to_tsvector(body) @@ to_tsquery('database')`

Large and slow to build/update, but very fast to search. Good for read-heavy workloads.

```sql
CREATE INDEX ON articles USING gin (to_tsvector('english', body));
```

### BRIN — Block Range Index
Stores only the **min and max value per block range** (default: 128 pages).

- Tiny index — a 1TB table may have a BRIN index of just a few MB
- Only useful when data is **physically ordered on disk** (e.g. append-only time-series)
- Useless for randomly ordered data

```sql
CREATE INDEX ON events USING brin (created_at);
```

### GiST — Generalized Search Tree
A framework for custom index strategies.

- Geometric types — points, polygons (`&&`, `@>`, `<->`)
- Range types — `WHERE schedule && '[2024-01-01, 2024-12-31]'::daterange`
- Full-text search (slower than GIN but supports ranking)

### SP-GiST — Space-Partitioned GiST
For non-balanced structures like quad-trees and k-d trees. Good for spatial data with clustering.

### Partial Index
Indexes only a subset of rows — any index type can be partial.

```sql
CREATE INDEX ON orders (user_id) WHERE status = 'pending';
```

Much smaller and faster if you only query that subset.

### Expression Index
Index on a computed expression instead of a raw column.

```sql
CREATE INDEX ON users (lower(email));

-- Now this uses the index:
SELECT * FROM users WHERE lower(email) = 'test@example.com';
```

---

## 2. Transaction Isolation Levels & Phantom Reads

### Isolation Levels

| Level | Dirty Read | Non-repeatable Read | Phantom Read |
|---|---|---|---|
| READ UNCOMMITTED | ✅ prevented* | ❌ | ❌ |
| READ COMMITTED | ✅ prevented | ❌ | ❌ |
| REPEATABLE READ | ✅ | ✅ prevented | ✅ prevented* |
| SERIALIZABLE | ✅ | ✅ | ✅ prevented |

> *Postgres doesn't allow dirty reads even at READ UNCOMMITTED. Its REPEATABLE READ also prevents phantom reads as a bonus due to snapshot isolation.

**READ COMMITTED** is the default — each statement sees a fresh snapshot of committed data.

**SERIALIZABLE** uses SSI (Serializable Snapshot Isolation) — safest but highest overhead.

### What is a Phantom Read?

A phantom read happens when a transaction runs the **same query twice** and gets **different rows** the second time — because another transaction inserted or deleted rows in between.

```
Transaction A (READ COMMITTED)        Transaction B
─────────────────────────────         ────────────────────────
BEGIN;

SELECT COUNT(*) FROM orders
WHERE amount > 1000;
-- returns 5 rows

                                       BEGIN;
                                       INSERT INTO orders
                                         (amount) VALUES (2000);
                                       COMMIT;

SELECT COUNT(*) FROM orders
WHERE amount > 1000;
-- returns 6 rows ← phantom!

COMMIT;
```

At **REPEATABLE READ** or above in Postgres, Transaction A would still see 5 rows on the second query.

---

## 3. Query Planning

When you run a query, Postgres goes through:

1. **Parse** — syntax check, build a parse tree
2. **Analyze** — resolve table/column names
3. **Plan** — generate candidate execution plans and pick the cheapest based on statistics from `ANALYZE`
4. **Execute** — run the chosen plan

The planner chooses between:
- Sequential scan vs index scan vs index-only scan vs bitmap scan
- Nested loop vs hash join vs merge join

### EXPLAIN ANALYZE

Use this to see what plan was chosen and actual runtime:

```sql
EXPLAIN ANALYZE
SELECT * FROM orders WHERE user_id = 42;
```

If the planner picks a bad plan, it's often because statistics are stale. Run `ANALYZE table_name` to update them.

### Why Postgres May Ignore Your Index

If a query matches a large percentage of rows, Postgres prefers a sequential scan because random I/O for millions of index lookups is slower than one linear read of the table.

---

## 4. MVCC — xmin, xmax, and Dead Tuples

Postgres uses **Multi-Version Concurrency Control** — instead of locking rows when writing, it creates a new version of the row.

- Readers never block writers
- Writers never block readers
- Every row has two hidden system columns: `xmin` and `xmax`

### xmin and xmax

| Column | Meaning |
|---|---|
| `xmin` | Transaction ID that **inserted** this row version |
| `xmax` | Transaction ID that **deleted or updated** this row (0 if still live) |

You can query them directly:

```sql
SELECT xmin, xmax, * FROM users WHERE id = 1;
```

### What Happens on UPDATE

Postgres never modifies a row in place. An `UPDATE` is a **delete + insert**:

```
Before UPDATE:
  row: xmin=100, xmax=0,   name='Alice'

After UPDATE SET name='Alicia' in transaction 200:
  row: xmin=100, xmax=200, name='Alice'    ← dead tuple
  row: xmin=200, xmax=0,   name='Alicia'   ← new live version
```

The old row stays on disk with `xmax` set — this is what VACUUM cleans up.

### Visibility Rule

When you run a query, Postgres checks each row version against your transaction's snapshot:

- If `xmin` is a **committed** transaction before your snapshot → row exists for you
- If `xmax` is a **committed** transaction before your snapshot → row is deleted for you
- If either is from an **in-progress** transaction → depends on isolation level

### HOT Update (Heap-Only Tuple)

When you UPDATE a row and:
- The new version fits on the **same heap page**, and
- No indexed column changed

Postgres uses a HOT update — no index entry needs updating. Faster and reduces index bloat.

Check HOT usage:
```sql
SELECT relname, n_tup_hot_upd FROM pg_stat_user_tables;
```

---

## 5. VACUUM

### Why VACUUM is Needed

Every UPDATE leaves a dead tuple behind. On write-heavy tables, dead tuples accumulate and waste disk space, slowing sequential scans.

### What VACUUM Actually Removes

VACUUM doesn't just check `xmax != 0`. It checks all three conditions:

1. `xmax != 0` — row must be marked as deleted/updated
2. `xmax` is a **committed** transaction (not rolled back)
3. `xmax < OldestXmin` — no active transaction can still see this old version

### OldestXmin — The Key Concept

Postgres tracks **OldestXmin** — the oldest transaction ID still active. VACUUM can only remove dead tuples where:

```
xmax < OldestXmin
```

### Why Long-Running Transactions Are Dangerous

```
Transaction 500 opened, never closed
                    ↓
OldestXmin stuck at 500
                    ↓
VACUUM can't remove dead tuples with xmax > 500
                    ↓
Table keeps growing on disk (table bloat)
```

### VACUUM vs VACUUM FULL

| | VACUUM | VACUUM FULL |
|---|---|---|
| Removes dead tuples | ✅ | ✅ |
| Reclaims space for reuse | ✅ (marks as reusable) | ✅ |
| Shrinks physical file | ❌ | ✅ (rewrites table) |
| Locks table | ❌ (runs concurrently) | ✅ (exclusive lock) |
| Speed | Fast | Slow |

### VACUUM Step by Step

1. Scans table for dead tuples where `xmax < OldestXmin`
2. Removes dead tuples and marks space as reusable
3. Updates the **visibility map** (enables index-only scans)
4. Advances the **freeze horizon** — old `xmin` values replaced with `FrozenXID` to prevent transaction ID wraparound

### Monitor Dead Tuples

```sql
SELECT relname, n_live_tup, n_dead_tup
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;
```

---

## 6. Heap & Bitmap Index Scan

### The Heap

The **heap** is the main table storage file — rows are written in no particular order, just appended wherever there's free space.

```
Heap (the table file on disk)
┌─────────────────────────────────┐
│ page 0: row3, row7, row1 (dead) │
│ page 1: row5, row2              │
│ page 2: row8, row4, row6        │
└─────────────────────────────────┘
```

When you do a sequential scan, Postgres reads heap pages from top to bottom.

### Bitmap Index Scan

Bitmap is not an index type — it's a **scan strategy** the planner uses automatically.

**How it works:**

1. Scans the index and builds a **bitmap in memory** — one bit per heap page marking which pages have matches
2. Sorts those pages by physical location
3. Reads heap pages in order (sequential I/O instead of random I/O)

**Combining multiple indexes:**

```sql
SELECT * FROM orders
WHERE status = 'pending' AND amount > 1000;
```

```
Bitmap from index on (status)    Bitmap from index on (amount)
page 0 → 1                       page 0 → 1
page 1 → 1              AND      page 1 → 0
page 2 → 0                       page 2 → 1
page 3 → 1                       page 3 → 1
          └──────── AND ──────────┘
               page 0 → 1  ← read this
               page 1 → 0
               page 2 → 0
               page 3 → 1  ← read this
```

### Scan Types Compared

| Scan type | How it works | Best for |
|---|---|---|
| Index scan | Follow each pointer from index to heap one by one | Few rows, small result set |
| Bitmap index scan | Build bitmap, read heap pages in order | Medium result set, multiple indexes |
| Index-only scan | Read from index alone, skip the heap | All needed columns are in the index |
| Sequential scan | Read whole heap top to bottom | Large % of table, no useful index |

---

## 7. JOIN Best Practices

### LEFT JOIN — Table Order

The left table determines which rows appear in the result. The rule:

- Put the table you want **all rows from** on the left
- Put the table you're **optionally matching** on the right

Table size is secondary to intent. Postgres's query planner can reorder joins internally when a different order is cheaper (especially for INNER JOINs).

### Internal Join Algorithms

| Algorithm | How it works | Best for |
|---|---|---|
| Nested loop | For each row in outer table, scan inner table | Small tables or indexed inner table |
| Hash join | Build hash table from smaller side, probe with larger | Large unsorted datasets |
| Merge join | Scan both sides simultaneously if already sorted | Both sides sorted on join key |

The planner picks the algorithm automatically based on table sizes and available indexes.

---

## 8. PostgreSQL vs MySQL vs MS SQL Server

### Philosophy & Licensing

| | PostgreSQL | MySQL | MS SQL Server |
|---|---|---|---|
| License | Free, open source | Free (GPL) / Commercial (Oracle) | Commercial (free Express edition) |
| Owned by | Community | Oracle | Microsoft |
| SQL standard compliance | Most compliant | Looser | Good |

### MVCC & Concurrency

| | PostgreSQL | MySQL (InnoDB) | MS SQL Server |
|---|---|---|---|
| MVCC | Yes, always | Yes (InnoDB only) | Yes (row versioning) |
| Default isolation | READ COMMITTED | REPEATABLE READ | READ COMMITTED |
| Lock on read | No (snapshots) | Sometimes | Sometimes |

MySQL's default REPEATABLE READ causes more gap locks, which can lead to deadlocks in high-concurrency write workloads.

### Index Support

| Index type | PostgreSQL | MySQL | MS SQL Server |
|---|---|---|---|
| B-tree | ✅ | ✅ | ✅ |
| Hash | ✅ | ✅ | ❌ |
| GIN | ✅ | ❌ | ❌ |
| GiST | ✅ | ❌ | ❌ |
| BRIN | ✅ | ❌ | ❌ |
| Partial index | ✅ | ❌ | ✅ (filtered index) |
| Expression index | ✅ | ✅ (v8+) | ✅ (computed column) |
| Columnstore | ❌ | ❌ | ✅ excellent for analytics |

### Data Types

| Feature | PostgreSQL | MySQL | MS SQL Server |
|---|---|---|---|
| JSONB (binary JSON) | ✅ excellent | ✅ (slower) | ✅ (v2016+) |
| Arrays | ✅ native | ❌ | ❌ |
| UUID | ✅ native | ✅ (as string) | ✅ (UNIQUEIDENTIFIER) |
| Range types | ✅ native | ❌ | ❌ |
| Custom types | ✅ | ❌ | Limited |
| Geometric/spatial | ✅ PostGIS | ✅ basic | ✅ geography/geometry |

### JSON Support

| | PostgreSQL | MySQL | MS SQL Server |
|---|---|---|---|
| Storage | `json` or `jsonb` (binary, indexed) | `json` (text only) | `nvarchar` + JSON functions |
| Indexing | GIN index on jsonb — very fast | Limited | Limited |
| Maturity | Excellent | Good | Good |

### Replication & High Availability

| | PostgreSQL | MySQL | MS SQL Server |
|---|---|---|---|
| Built-in replication | Streaming + logical | Binlog | Always On AG |
| Synchronous replication | ✅ | ✅ (semi-sync) | ✅ |
| Built-in automatic failover | ❌ (needs Patroni/repmgr) | ❌ (needs orchestrator) | ✅ excellent |

### When to Choose Each

**Choose PostgreSQL when:**
- You need complex queries, CTEs, window functions
- Storing JSONB and need to index/query inside it
- You want the most SQL-standard behavior
- You need custom types, arrays, or range types
- Open source with no vendor lock-in matters

**Choose MySQL when:**
- Maximum ecosystem compatibility (WordPress, Laravel, many ORMs)
- Simple OLTP workloads with straightforward queries
- Your team already knows it well

**Choose MS SQL Server when:**
- You're in a Microsoft/Azure ecosystem (.NET, Azure, Active Directory)
- You need enterprise HA out of the box (Always On)
- Heavy analytical/reporting workloads (columnstore indexes)
- You need mature tooling like SSMS, SSRS, SSIS

### One-line Summary

| | Summary |
|---|---|
| **PostgreSQL** | Most powerful and standards-compliant, best for complex data and queries |
| **MySQL** | Easiest ecosystem fit, best for simple web apps and broad compatibility |
| **MS SQL Server** | Best enterprise HA and analytics, best in Microsoft stack |

---