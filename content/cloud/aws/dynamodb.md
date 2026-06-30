---
title: Dynamo DB
draft: false
tags:
  - data 
  - aws
---
[[data]]
[[database]]


DynamoDB : 
description: Amazon DynamoDB is a serverless, NoSQL database service that allows you to develop modern applications at any scale. As a serverless database, pay as much as use, has no cold starts, no version upgrades, no maintenance windows, no patching, and no downtime maintenance

- NOSQL 
- Key - Value database
- SSD database storage
- Serverless
## DynamoDB Vs RDBMS

The below table provides us with core differences between a conventional relational database management system and AWS DynamoDB: 

|Operations|DynamoDB|RDBMS|
|---|---|---|
|Source connection|It uses HTTP requests and API operations.|It uses a persistent connection and SQL commands.|
|Create Table|It mainly requires the Primary key and no schema on the creation and can have various data sources.|It requires a well-defined table for its operations.|
|Getting Table Information|Only Primary keys are revealed.|All data inside the table is accessible.|
|Loading Table Data|In tables, it uses items made of attributes.|It uses rows made of columns.|
|Reading Table Data|It uses GetItem, Query, and Scan|It uses SELECT statements and filtering statements.|
|Managing Indexes|It uses a secondary index to achieve the same function. It requires specifications (partition key and sort key).|Standard Indexes created by SQL is used.|
|Modifying Table Data|It uses a UpdateItem operation.|It uses an UPDATE statement.|
|Deleting Table Data|It uses a DeleteItem operation.|It uses a DELETE statement.|
|Deleting Table|It uses a DeleteTable operation.|It uses a DROP TABLE statement.|
## Advantage of DynamoDB:

The main advantages of opting for Dynamodb are listed below: 

- It has fast and predictable performance.
- It is highly scalable.
- It offloads the administrative burden operation and scaling.
- It offers encryption at REST for data protection.
- Its scalability is highly flexible.
- AWS Management Console can be used to monitor resource utilization and performance metrics.
- It provides on-demand backups.
- It enables point-in-time recovery for your Amazon DynamoDB tables. Point-in-time recovery helps protect your tables from accidental write or delete operations. With point-in-time recovery, you can restore that table to any point in time during the last 35 days.
- It can be highly automated.   
## Limitations of DynamoDB –

The below list provides us with the limitations of Amazon DynamoDB: 

- It has a low read capacity unit of 4kB per second and a write capacity unit of 1KB per second.
- All tables and global secondary indexes must have a minimum of one read and one write capacity unit.
- Table sizes have no limits, but accounts have a 256 table limit unless you request a higher cap.
- Only Five local and twenty global secondary (default quota) indexes per table are permitted.
- DynamoDB does not prevent the use of reserved words as names.
- Partition key length and value minimum length sits at 1 byte, and maximum at 2048 bytes, however, DynamoDB places no limit on values.
