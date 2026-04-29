
---
title: "Slingdata"
---
## What is it ? 
[Sling](https://slingdata.io/) is a `Powerful Data Integration` tool enabling seamless ELT operations as well as quality checks across files, databases, and storage systems.
## Use Cases
- Database Replication: Replication from different type of database 
- Transfrom file to database: Loading .csv .parquet to warehouse
- Move data between Cloud Storage
- Extra Data From API
## Examples 

```
+---------------+------------------+-----------------+
| CONN NAME     | CONN TYPE        | SOURCE          |
+---------------+------------------+-----------------+
| MY_SOURCE_DB  | DB - PostgreSQL  | env variable    |
| MY_TARGET_DB  | DB - Snowflake   | env variable    |
+---------------+------------------+-----------------+
```
```md title="replication.yaml"
---
source: MY_SOURCE_DB
target: MY_TARGET_DB

defaults:
  mode: full-refresh / incremental (recommended) / truncate /snapshot ...

streams:
  my_schema.my_table.1:
    sql: |
      select 
        id,
        first_name,
        last_name,
        email,
        status
      from my_schema.my_table 
      where status = 'active'
    object: target_schema.active_users

  my_schema.my_table.2:
    sql: file:///path/to/query.sql
    object: target_schema.custom_table
---
```
