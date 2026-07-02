---
title: Data & Databases
tags:
  - data
  - database
  - sql
  - nosql
---

## Data

**Data** is raw, unprocessed facts and figures — numbers, text, images, or signals collected from the world. On its own, data has no inherent meaning; it becomes **information** when organized, structured, and interpreted in context.

### Types of Data

| Type | Description | Examples |
|---|---|---|
| **Structured** | Organized in rows/columns with fixed schema | SQL tables, CSV files |
| **Semi-structured** | Self-describing with tags/keys but no rigid schema | JSON, XML, Parquet |
| **Unstructured** | No predefined structure | Images, videos, PDFs, logs |
| **Time-series** | Data points indexed by time | Metrics, sensor readings |
| **Graph** | Entities and their relationships | Social networks, knowledge graphs |

### Data Lifecycle

1. **Generation** — data is created (user input, sensors, APIs)
2. **Collection** — ingested via streams or batch (Kafka, Airbyte)
3. **Storage** — persisted in databases, data lakes, or warehouses
4. **Processing** — cleaned, transformed, aggregated (Spark, dbt, Flink)
5. **Analysis** — queried and visualized (SQL, BI tools, notebooks)
6. **Archival/Deletion** — moved to cold storage or purged per retention policy

---

## Databases

A **database** is an organized collection of structured data, managed by a **DBMS** (Database Management System). Databases provide persistent storage, concurrent access, querying, and data integrity guarantees.

### Database Models

| Model | Description | Examples |
|---|---|---|
| **Relational (RDBMS)** | Tables with rows/columns, SQL, ACID | PostgreSQL, MySQL, SQL Server |
| **Document** | JSON-like documents, flexible schema | MongoDB, Couchbase, Firestore |
| **Key-Value** | Simple key → value lookups, high throughput | Redis, DynamoDB, Memcached |
| **Wide-Column** | Sparse rows with dynamic columns | Cassandra, HBase, ScyllaDB |
| **Graph** | Nodes and edges for connected data | Neo4j, Amazon Neptune, DGraph |
| **Time-series** | Optimized for timestamped data | InfluxDB, TimescaleDB, Prometheus |
| **Vector** | Embedding storage for ML similarity search | Pinecone, Qdrant, Weaviate |

### ACID Properties (Relational)

- **Atomicity** — transactions succeed or fail completely
- **Consistency** — data always satisfies declared constraints
- **Isolation** — concurrent transactions don't interfere
- **Durability** — committed data survives system failures

### CAP Theorem

A distributed database can guarantee at most **two** of three properties:
- **C**onsistency — every read returns the most recent write
- **A**vailability — every request gets a (non-error) response
- **P**artition Tolerance — system continues despite network failures

Most modern systems choose **AP** (Cassandra, DynamoDB) or **CP** (HBase, MongoDB with majority write concern).

### Indexing Strategies

- **B-Tree** — balanced tree, good for range queries (default in most RDBMS)
- **Hash** — exact-match lookups only, O(1)
- **GIN/GiST** — full-text search, array containment (PostgreSQL)
- **LSM-Tree** — write-optimized, used by Cassandra, RocksDB
- **Inverted Index** — term → document mapping (Elasticsearch)
- **Vector Index** — ANN search for embeddings (HNSW, IVF)

### Normalization

| Normal Form | Rule |
|---|---|
| **1NF** | Each cell holds a single value (no arrays/nested records) |
| **2NF** | 1NF + all non-key columns depend on the *entire* primary key |
| **3NF** | 2NF + no transitive dependencies (non-key → non-key) |
| **BCNF** | 3NF + every determinant is a candidate key |

In practice, warehouses and analytical databases often use **denormalized** schemas (star schema) for performance.

### Key Concepts

- **Transactions** — groups of operations executed as a unit (BEGIN/COMMIT/ROLLBACK)
- **Concurrency Control** — MVCC (Multi-Version Concurrency Control) used by PostgreSQL, MySQL InnoDB
- **Sharding** — horizontal partitioning across servers
- **Replication** — data copies for durability and read scaling (leader-follower, multi-leader)
- **Views** — virtual tables based on a query (can be materialized for performance)
- **Stored Procedures** — precompiled SQL logic executed in the database

## Files in this Section

- **PostgreSQL** — relational database notes (SQL, indexing, query optimization)
- **MongoDB** — NoSQL document database notes
- **Relational/** — deep dive into RDBMS concepts
- **NoSQL/** — non-relational database patterns and trade-offs
