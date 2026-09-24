---
name: audit-service
description: Audit a legacy service before a migration, extraction, or rewrite. Inventory code, endpoints, RPCs, data, events, external dependencies, runtime behavior, architectural seams, and risks; produce an evidence-backed Current State Assessment.
---

# Audit service

## Execution modes

- **Discovery (default):** Inspect the repository and available read-only documentation; report findings in the conversation.
- **Document:** When asked for a persistent assessment, write `docs/architecture/CURRENT-STATE-<service-name>.md` in the host repository. Sanitize the service name to lowercase kebab case.
- **Focused:** If a domain or service is named, limit the inventory to that scope and its direct dependencies. State the boundary.

## Procedure

1. Read `CLAUDE.md`, `AGENTS.md`, architecture docs, ownership files, manifests, deployment configuration, and test conventions in the host repository. Follow the host's instructions. Use `docs/agents/setup.md` for placement conventions.
2. Map entry points: HTTP routes, RPC methods, consumers, producers, batch jobs, schedulers, and administrative interfaces. Trace each important path to business logic, persistence, and outbound calls. Give file paths and symbols as evidence.
3. Inventory data stores, tables/collections, schema ownership, read/write paths, transactions, migration scripts, retention, and backfill machinery. Trace message topics, payload versions, delivery guarantees, and replay behavior.
4. Inspect third-party services, authentication and authorization boundaries, secrets references (never values), deploy topology, flags, timeouts, retries, rate limits, and observability. Review tests and operational docs for failure and rollback evidence.
5. Separate observed facts from inference. Mark unverified runtime claims `Needs runtime confirmation` and name the telemetry or owner needed. Identify behavior that must be preserved and places that offer a safe extraction seam.

## Operational boundaries

- Read-only by default. Do not run the application, connect to production, change configuration, publish artifacts, or expose credentials to obtain evidence.
- Never equate absence of a reference in the searched files with proof that a dependency does not exist. Record search scope and gaps.
- Never invent traffic volumes, latency, SLOs, schema ownership, or contract guarantees. Label unknowns and ask for the minimal missing evidence.
- Do not recommend a target architecture as an established decision in this phase.

## Output format

Start with **Scope and evidence** (commit or inspected snapshot, searched paths, docs, and gaps). Then provide a **Current State Assessment** matrix:

| Surface | Observed behavior and evidence | Architectural seam or bottleneck | Migration risk | Confidence / next evidence |
| --- | --- | --- | --- | --- |

Include rows for interfaces, persistence, events, integrations, security, deployment, observability, and tests; use `Unknown` where evidence is missing. Finish with **Behavior to preserve**, **Dependency map** (Mermaid when useful), and **Questions for the architecture grill**, ranked by blast radius. Cite paths and line ranges where practical.
