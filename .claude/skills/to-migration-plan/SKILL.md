---
name: to-migration-plan
description: Decompose an approved migration SDD and its ADRs into deployable phases and actionable tickets with dependencies, verification gates, failure handling, and rollback procedures.
---

# Slice the migration

## Execution modes

- **Planning (default):** Draft a plan and local ticket specifications under `docs/architecture/plans/<service-name>/`.
- **Review:** Identify unsafe ordering, missing prerequisites, and unverifiable gates without writing files.
- **Issue export:** Create tracker issues only if the user requests publishing and the host tracker and target project are confirmed.

## Preconditions and procedure

1. Read the SDD, linked ADRs, host tracker conventions, and `templates/MIGRATION_TICKET_TEMPLATE.md`. Require an explicit SDD approval record with approver and date, and resolve critical blockers first. If absent, provide a proposed plan clearly marked `Unapproved`; do not represent it as execution-ready or publish issues.
2. Build a dependency graph. Make each slice independently deployable and observable; include owner/role, preconditions, scope, implementation steps, measurable acceptance criteria, verification commands or dashboards, safety gates, and rollback or forward-recovery procedures.
3. Organize by **Phase 0: Instrumentation**, **Phase 1: Dual-Write / Shadow**, **Phase 2: Canary Cutover**, and **Phase 3: Retirement**. Adapt Phase 1 if dual writes are unsafe or unnecessary; state the selected approach from the SDD. Include contract tests, reconciliation and replay, degraded-mode testing, and a pause gate before expanding traffic.
4. Save `docs/architecture/plans/<service-name>/PLAN.md` with the phase graph and ticket index, plus numbered ticket files `TICKET-001-<slug>.md`, etc. Use concrete host commands when verified; otherwise specify the exact signal and source needed without inventing commands.
5. Order cleanup only after consumer migration, retention windows, and rollback windows expire. Make data deletion an explicit separately reviewed ticket.

## Operational boundaries

- Plan only: no deploy, traffic shift, database change, destructive cleanup, or external issue creation without a specific request.
- Never assume an SDD is approved because it exists. Record unresolved approval and dependencies as blockers.
- Do not claim zero downtime without compatibility, capacity, consistency, rollback, and monitoring evidence.

## Output format

Start with SDD path, approval status, assumptions, and blockers. Show a phase table with entry gates, tickets, exit gates, and rollback owner. Give every ticket a stable ID, dependencies, acceptance criteria, exact verification evidence, failure trigger, and recovery path. Link each ticket to the governing SDD section and ADRs.
