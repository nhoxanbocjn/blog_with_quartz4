---
title: Chap 1
tags: spark
---

- Apache Spark is an Open source analytics engine for large-scale data processing” and machine learning applications
- Spark can process an increasingly vast amount of data by scaling out (across multiple smaller machines) instead of scaling up
 
```
Spark Cluster
│
├── Node 1 ──┐
├── Node 2 ──┼──► Master ──► Executor 1.1
├── Node 3 ──┘               Executor 1..
└── ......                   Executor 2..
                             Executor 3..
```

## Features of Apache Spark
- In-memory computation
- Distributed processing using parallelize
- Can be used with many cluster managers (Spark, Yarn, Mesos e.t.c)
- Fault-tolerant
- Immutable
- Lazy evaluation
- Cache & persistence
- Inbuild-optimization when using DataFrames
- Supports ANSI SQL


## Summary

- We first encode our instructions in **Python code**, forming a **driver program**.

- When submitting our program (or launching a PySpark shell), the **cluster manager** allocates resources for us to use. Those will mostly stay constant (with the exception of **auto-scaling**) for the duration of the program.

- The **driver** ingests your code and translates it into **Spark instructions**. Those instructions are either **transformations** or **actions**.

- Once the driver reaches an **action**, it optimizes the whole computation chain and splits the work between **executors**. Executors are processes performing the actual data work, and they reside on machines labeled **worker nodes**.

## Lazy Evaluation vs Eager Evaluation
![Spark](lazy_evaluation.png)

* Python, R, and Java, are eagerly evaluated. This means that they process instructions as soon as they receive them.

## PySpark: Transformations vs Actions

Spark instructions can be classified into two categories: transformations and actions (show(), write(), and count()).

| Transformations | Actions |
|---|---|
| PySpark does **not** evaluate transformations immediately (including reading data) — no actual data work is performed at this stage. | Any operation that **writes or shows data** is called an **Action** and triggers the actual data work. |

1. Storing Instructions only not intermidate results --> save storage
2. The driver can optimise the instructiosn
3. When node failed --> Spark will be able to recreate the missing chunks of data since it has the instructions cached



