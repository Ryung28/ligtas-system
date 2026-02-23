# 🛡️ LIGTAS SYSTEM: Disaster Management ecosystem

Welcome to the **LIGTAS** (Local Inventory & Geolocation Tracking for Assistance & Safety) core repository. This is a professional-grade Disaster Management Ecosystem designed for CDRRMO (City Disaster Risk Reduction and Management Office) operations.

---

## 🛰️ Ecosystem Overview

This project consists of two primary interconnected platforms:

| Platform | Role | Technology Stack |
| :--- | :--- | :--- |
| **💻 Web Dashboard** | Admin Headquarters | Next.js 15, TypeScript, Shadcn/UI |
| **📱 Mobile App** | Field Responder Operations | Flutter, Riverpod, Isar (Offline-First) |
| **☁️ Backend** | Real-time Infrastructure | Supabase (PostgreSQL, Auth, Real-time) |

---

## 🗺️ Project Navigation (Mission Control)

Use this index to quickly find documentation and project modules:

### 🛠️ Development & Setup
*   [**Quickstart Guide**](./docs/setup/QUICKSTART.md) — Get the whole system running in 15 minutes.
*   [**Database Migrations**](./docs/setup/PENDING_ACCESS_MIGRATION_GUIDE.md) — SQL scripts for the Supabase backend.
*   [**Setup Guide**](./docs/setup/SETUP_GUIDE.md) — Detailed environment configuration.

### 🏗️ Architecture & Security
*   [**System Architecture**](./docs/system/ARCHITECTURE.md) — High-level design patterns and data flow.
*   [**Authentication Flow**](./docs/system/AUTHENTICATION.md) — Security protocols and role-based access.
*   [**AI Architect Guide**](./docs/guides/AI_ARCHITECT_GUIDE.md) — Best practices for managing this codebase with AI.

### 📁 Project Modules
*   [`/web`](./web/README.md) — Admin dashboard source code.
*   [`/mobile`](./mobile/README.md) — Field responder mobile app source code.
*   [`/docs`](./docs/) — Centralized documentation hub.

---

## 🧠 Senior Architect Principles

This system is built with **Safety**, **Scalability**, and **Efficiency** in mind:
1.  **Offline-First:** Field responders can operate without internet; data syncs automatically via Isar.
2.  **Repository Pattern:** UI is decoupled from data fetching for maximum testability.
3.  **Real-time Logic:** Fleet and inventory status updates instantly across all platforms via WebSockets.
4.  **Strict Typing:** Zero `any` in Web and zero `dynamic` in Mobile to prevent production crashes.

---

## 📜 Licenses & Attribution

Built for the safety of the community. All rights reserved by the LIGTAS project team.

> **"Code at the speed of thought, deploy with the precision of a responder."**