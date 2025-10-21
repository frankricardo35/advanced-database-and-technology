# 🎬 Film Production and Crew Management System
## ⚙️ Parallel & Distributed Database Queries (Oracle 19c)

[![Oracle SQL](https://img.shields.io/badge/Database-Oracle%2019c-red?logo=oracle&logoColor=white)](https://www.oracle.com/database/)
[![SQL Developer](https://img.shields.io/badge/Tool-SQL%20Developer-blue?logo=databricks&logoColor=white)](https://www.oracle.com/tools/downloads/sqldev-downloads.html)
[![Topic](https://img.shields.io/badge/Focus-Parallel%20%26%20Distributed%20Databases-green)](#)
[![Author](https://img.shields.io/badge/Author-Frank%20Ricardo%20(216128218)-lightgrey)](#)

---

## 🎯 Purpose

This lab demonstrates **advanced Oracle 19c database features** in **Parallel and Distributed Query Processing** using the *Film Production & Crew Management System* schema.

It extends the centralized database to simulate **multi-branch data distribution**, **remote database access**, **parallelism**, and **transaction atomicity** via **two-phase commit (2PC)**.

---

## 🧩 Learning Objectives

By completing this exercise, students will:
1. Understand **data fragmentation and replication** across distributed schemas.
2. Use **Oracle Database Links** for remote joins and queries.
3. Simulate **Two-Phase Commit (2PC)** to ensure atomic distributed transactions.
4. Explore **Parallel Query Execution** for improved performance.
5. Observe **Concurrency Control & Lock Management** in multi-user environments.
6. Benchmark **Serial vs Parallel vs Distributed** performance using AUTOTRACE.

---

## 🏗️ Environment Setup

| Component | Description |
|------------|-------------|
| **Central Schema** | Main film production database (`FilmDB`) |
| **BranchDB_A** | Stores odd-numbered project and crew data |
| **BranchDB_B** | Stores even-numbered project and crew data |
| **Database Link** | `DBLINK_TO_B` connects `BranchDB_A` to `BranchDB_B` |
| **Oracle Version** | Oracle Database 19c or higher |
| **Tools Used** | SQL*Plus / Oracle SQL Developer |

---

## 🗺️ Architecture Diagram

```mermaid
flowchart LR
    subgraph FilmDB["🎬 Central Schema (Film Production System)"]
        P[Project Table]
        C[Crew Table]
        A[Assignment Table]
        S[Schedule Table]
        E[Expense Table]
    end

    subgraph BranchDB_A["🏢 BranchDB_A (Odd Fragments)"]
        PA[Project_A]
        CA[Crew_A]
    end

    subgraph BranchDB_B["🏢 BranchDB_B (Even Fragments)"]
        PB[Project_B]
        CB[Crew_B]
    end

    P -->|Horizontal Fragmentation| PA
    P -->|Horizontal Fragmentation| PB

    PA <-->|DBLINK_TO_B| PB
    CA <-->|DBLINK_TO_B| CB

    classDef central fill:#fef3c7,stroke:#f59e0b,stroke-width:2px,color:#000,font-weight:bold;
    classDef branch fill:#e0f2fe,stroke:#0284c7,stroke-width:2px,color:#000,font-weight:bold;
    classDef link fill:#e2e8f0,stroke:#94a3b8,stroke-width:1px,color:#111;

    class FilmDB central;
    class BranchDB_A,BranchDB_B branch;
