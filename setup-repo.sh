#!/usr/bin/env bash
set -euo pipefail

# Recreate the re-architect repository in the requested directory.
# Usage: bash setup-repo.sh [destination]
script_source="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/$(basename -- "${BASH_SOURCE[0]}")"
destination="${1:-.}"
mkdir -p -- "$destination"
destination="$(cd -- "$destination" && pwd -P)"

mkdir -p -- "$destination/.claude/skills/audit-service"
cat > "$destination/.claude/skills/audit-service/SKILL.md" <<'__RE_ARCHITECT_FILE_01__'
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
__RE_ARCHITECT_FILE_01__

mkdir -p -- "$destination/.claude/skills/grill-architecture"
cat > "$destination/.claude/skills/grill-architecture/SKILL.md" <<'__RE_ARCHITECT_FILE_02__'
---
name: grill-architecture
description: Interrogate migration design trade-offs before an SDD is finalized. Use after a service audit or when planning a strangler cutover, shadow traffic, dual writes, reconciliation, backfills, rollback, resilience, and SLOs.
---

# Grill architecture

## Execution modes

- **Interactive (default):** Ask 2–3 high-impact questions per turn, wait for answers, then probe contradictions or missing evidence.
- **Review:** Given a draft design, test its assumptions and gates against the audit; ask 2–3 questions per turn and maintain a decision log.
- **Synthesis:** On request, summarize decisions, open questions, alternatives, and evidence without pretending unresolved choices are approved.

## Procedure

1. Read the Current State Assessment, existing SDDs/ADRs, host constraints, and the user's stated objective. If there is no audit, state the missing evidence and ask only about decisions that can be assessed responsibly.
2. Rank uncertainties by reversibility and blast radius. Probe: routing and Strangler Fig versus shadow traffic; ownership and consistency during dual writes; source of truth; event ordering and idempotency; replay and backfill; reconciliation thresholds; schema compatibility; client contracts; security boundaries; circuit breakers and failure isolation; observability and SLOs; canary gates and rollback after irreversible writes.
3. For each turn, ask **no more than three questions and normally two**. Make them concrete: give the decision, meaningful options, consequences, and the evidence needed. Do not bundle multiple unrelated questions into one.
4. After each reply, update a compact decision log with `Agreed`, `Proposed`, or `Open` status and the rationale. Challenge inconsistencies respectfully; request a measurable gate or owner when a claim cannot be tested.
5. End the grilling only when the critical choices have explicit answers or are explicitly recorded as unresolved blockers. Offer the decision log to `to-sdd`.

## Operational boundaries

- Do not commit a design, write an SDD, create tickets, or modify production systems while grilling unless specifically requested.
- Never treat silence, an estimate, or a simulated answer as sign-off. Mark every assumption and distinguish a recommendation from a decision.
- Avoid forcing a preferred architecture. Present trade-offs rooted in the host system's evidence and deployment constraints.
- If a rollback cannot restore consistency, say so and explore forward recovery, reconciliation, and a safe pause gate.

## Output format

Use a short **What we know** paragraph and a numbered list of 2–3 questions per turn. For each question include the trade-off and why the answer changes implementation. Maintain a decision log:

| Decision | Options / rationale | Status | Evidence or owner |
| --- | --- | --- | --- |

When summarizing, add **Unresolved blockers** and **Proposed measurable gates**. Never label an open item approved.
__RE_ARCHITECT_FILE_02__

mkdir -p -- "$destination/.claude/skills/to-migration-plan"
cat > "$destination/.claude/skills/to-migration-plan/SKILL.md" <<'__RE_ARCHITECT_FILE_03__'
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
__RE_ARCHITECT_FILE_03__

mkdir -p -- "$destination/.claude/skills/to-sdd"
cat > "$destination/.claude/skills/to-sdd/SKILL.md" <<'__RE_ARCHITECT_FILE_04__'
---
name: to-sdd
description: Turn a migration audit and agreed architectural trade-offs into a production-ready Solution Design Document and separate Architecture Decision Records in the host repository.
---

# Write the solution design

## Execution modes

- **Draft (default):** Create or update `docs/architecture/SDD-<service-name>.md` and decision records. Mark the SDD `Draft`.
- **Revision:** Update an existing SDD and affected ADRs while preserving decision history and links.
- **Review:** Assess completeness against the template and report gaps without changing files.

## Procedure

1. Read the assessment, grill decision log, host architectural conventions, and `templates/SDD_TEMPLATE.md` plus `templates/ADR_TEMPLATE.md`. Normalize the service name to lowercase kebab case. Respect any host documentation location, linking back to the canonical SDD path when a host convention differs.
2. Separate verified facts, proposed design, accepted decisions, and unanswered questions. Capture alternatives considered with concrete consequences. Never convert a proposal into approval.
3. Write the SDD under `docs/architecture/SDD-<service-name>.md`. Complete every template section: current/target topology; contracts; security; data ownership and migration; compatibility; rollout; observability; resilience; verification; rollback and forward recovery; explicit owners and review status. Use `Unknown — requires <evidence/owner>` for unresolved material facts.
4. Create standalone ADRs for decisions with lasting consequences or credible competing options (for example source of truth, cutover routing, dual-write strategy, or rollback policy). Use `docs/architecture/adrs/ADR-YYYYMMDD-<slug>.md`; if that path exists, append `-02`, `-03`, etc. Set status `Proposed` until an authorized decision maker accepts it. Cross-link each ADR and the SDD.
5. Check that each data transition has an invariant, reconciliation method, gate, and recovery owner. Check that rollback is feasible at every phase and call out irreversible boundaries.

## Operational boundaries

- Edit documentation only. Do not change application code, deploy, run data migrations, or create issues as part of writing an SDD.
- Do not fabricate capacity, timelines, sign-offs, compliance results, or approval. Do not overwrite accepted ADRs to reverse decisions; supersede them with a new ADR.
- Treat missing evidence as a blocker or a risk with an owner; keep design status `Draft` until the actual reviewers approve it.

## Output format

Return paths to the SDD and each ADR, an executive summary, a table of decisions with status, and a short list of unresolved blockers. Use Mermaid diagrams with named systems and data flows, and explicit direction for synchronous calls versus asynchronous events. Make contract and rollout tables readable without relying on a diagram.
__RE_ARCHITECT_FILE_04__

cat > "$destination/CLAUDE.md" <<'__RE_ARCHITECT_FILE_05__'
# re-architect session instructions

Apply these instructions when working inside this repository or a host repository that intentionally incorporates them. Follow the host's more specific safety, ownership, and documentation conventions.

## Working order

1. Audit current behavior and cite repository evidence before proposing a migration.
2. Grill unresolved architectural choices in groups of two or three questions per turn. Record accepted, proposed, and open decisions separately.
3. Write a draft SDD and standalone ADRs using the templates. Only a named approver can change an architectural decision's status to accepted.
4. Slice an approved SDD into observable, independently deployable work. If approval is absent, label the output unapproved.

Read `docs/agents/setup.md` when first entering a host repository. Skills live in `.claude/skills/audit-service/`, `grill-architecture/`, `to-sdd/`, and `to-migration-plan/` and can be invoked as slash skills in Claude Code where supported.

## Evidence and safety

Distinguish source evidence from inference and runtime unknowns. Never invent metrics, approvals, contract guarantees, or production state. Make changes only within the requested scope. Do not deploy, change data, publish issues, shift traffic, or retire systems merely because a plan describes them. Specify rollback feasibility, data reconciliation, and measurable stop gates before recommending a cutover.
__RE_ARCHITECT_FILE_05__

cat > "$destination/LICENSE" <<'__RE_ARCHITECT_FILE_06__'
MIT License

Copyright (c) 2026 re-architect contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
__RE_ARCHITECT_FILE_06__

cat > "$destination/README.md" <<'__RE_ARCHITECT_FILE_07__'
# re-architect

**Architecture discipline for service migrations, delivered as agent skills.**

`re-architect` helps Claude Code, Cursor, and other coding agents inspect a legacy system, force the hard design conversations, write reviewable architecture documents, and plan safe incremental cutovers. Inspired by the small, composable skills approach of [mattpocock/skills](https://github.com/mattpocock/skills). It is a documentation and planning toolkit, not an automatic migration engine.

```mermaid
flowchart LR
    A["Audit legacy service"] --> B["Grill trade-offs"]
    B --> C["SDD and ADRs"]
    C --> D["Migration slices"]
    D --> E["Gated delivery"]
    E -. "runtime findings" .-> A
```

## The four-step lifecycle

| Step | Skill | Outcome |
| --- | --- | --- |
| Audit | `.claude/skills/audit-service/SKILL.md` | Evidence-backed Current State Assessment: interfaces, stores, events, seams, gaps, risks. |
| Grill | `.claude/skills/grill-architecture/SKILL.md` | Two or three targeted questions per turn; explicit options, decisions, and unresolved blockers. |
| Design | `.claude/skills/to-sdd/SKILL.md` | Draft `docs/architecture/SDD-<service-name>.md` and linked ADRs. |
| Slice | `.claude/skills/to-migration-plan/SKILL.md` | Phased plan and independently deployable ticket specifications, gated by design approval. |

## Install

For agents using the Skills CLI, run from the host repository:

```bash
npx skills add iamujjwalsinha/re-architect
```

Select the skills appropriate to your agent when prompted. The CLI's installation behavior and discovery locations depend on the agent and CLI version; check the resulting skill paths before use. For manual installation, clone this repository and copy the skill folders and templates into your host repository:

```bash
git clone https://github.com/iamujjwalsinha/re-architect.git
mkdir -p my-service/.claude/skills my-service/templates my-service/docs/agents
cp -R re-architect/.claude/skills/. my-service/.claude/skills/
cp -R re-architect/templates/. my-service/templates/
cp re-architect/docs/agents/setup.md my-service/docs/agents/setup.md
```

Merge the guidance in `CLAUDE.md` with any existing host instructions; do not overwrite host rules. Claude Code can invoke `/audit-service`, `/grill-architecture`, `/to-sdd`, and `/to-migration-plan` where project skills are supported. In Cursor or another coding agent, ask it to read the corresponding `SKILL.md` and apply the instructions. Keep `templates/` available to the agent when generating documents.

To recreate this repository's files from one script in an empty directory:

```bash
bash setup-repo.sh ./re-architect
```

## Example: extracting a monolith's billing capability

1. **Audit:** Trace `POST /invoices` from the monolith controller through transaction boundaries, invoice tables, payment provider calls, and `invoice.created` events. The assessment finds that the monolith owns invoice IDs, while a scheduled job retries webhook delivery. Traffic and retry lag remain `Needs runtime confirmation` until measured.
2. **Grill:** Decide whether the new billing service receives shadow reads before routing writes; choose one source of truth during dual writes; establish idempotency keys and a reconciliation query. Agree on canary abort thresholds, recovery authority, and how to handle invoices created after a rollback.
3. **Design:** Write `SDD-billing.md`. Link ADRs for routing ownership and write consistency. Document API/event compatibility, schema expansion, backfill checkpoints, auth propagation, SLOs, and a rollback procedure that accounts for already committed invoices.
4. **Slice:** Instrument invoice divergence and latency first. Shadow requests without side effects, then safely replicate writes if the approved design calls for it. Backfill and reconcile, canary a small traffic share behind a route switch, widen only after observation gates, then retire the old path after the rollback window. Each ticket names a test, metric, stop signal, and recovery owner.

The example is illustrative; the skills require evidence and named approval for a real system. Planning does not authorize production changes.

## Repository map

```text
.claude/skills/{audit-service,grill-architecture,to-sdd,to-migration-plan}/SKILL.md
templates/{SDD_TEMPLATE,ADR_TEMPLATE,MIGRATION_TICKET_TEMPLATE}.md
docs/agents/setup.md
CLAUDE.md
setup-repo.sh
LICENSE
```

## License

MIT. See [LICENSE](LICENSE).
__RE_ARCHITECT_FILE_07__

mkdir -p -- "$destination/docs/agents"
cat > "$destination/docs/agents/setup.md" <<'__RE_ARCHITECT_FILE_08__'
# Host repository setup

`re-architect` supplies instructions and templates; an agent must first learn the conventions of the repository in which it is installed. The installation copies `.claude/skills/`, `templates/`, and optionally `CLAUDE.md` into the host. Review the host's existing `CLAUDE.md` before merging instructions; never overwrite it blindly.

## Inspect before writing

1. Identify the host root and read its `CLAUDE.md`, `AGENTS.md`, contributor guide, ownership map, package/workspace manifests, and CI configuration.
2. Find architectural material under `docs/`, `architecture/`, RFC or ADR folders, API schemas, runbooks, and deployment definitions. Use a targeted file search and record what was searched.
3. Map bounded contexts from service directories, modules, API ownership, database tables, event topics, and CODEOWNERS. A folder boundary alone does not establish data ownership.
4. Find the issue tracker from repository links, templates, project configuration, and explicit user instructions. Do not create remote issues until the destination project and requested action are clear.
5. Prefer existing naming and document conventions where they are compatible. Keep a canonical `docs/architecture/SDD-<service-name>.md` and linked ADRs if the host has no stronger convention. Link any host-specific location from that canonical path.

## Adapt the workflow

Begin with `/audit-service`, follow with `/grill-architecture`, then `/to-sdd`, then `/to-migration-plan` after approval. A focused audit can precede a partial grill, but an incomplete audit cannot turn guesses into facts. Preserve evidence paths and decision statuses across steps. Treat host policies and the user's instructions as controlling; ask only for information required to choose an unsafe or irreversible action.

Cursor and other agents can read the same `SKILL.md` files directly and follow the equivalent four stages. Their skill discovery conventions vary; point the agent at the specific file if it does not discover `.claude/skills/` automatically.
__RE_ARCHITECT_FILE_08__

mkdir -p -- "$destination/templates"
cat > "$destination/templates/ADR_TEMPLATE.md" <<'__RE_ARCHITECT_FILE_09__'
# ADR: Architectural decision

**Status:** Proposed

**Date:** Record the decision date

**Deciders:** Record names or accountable roles

**Related SDD:** Link the governing design

> Copy to `docs/architecture/adrs/ADR-YYYYMMDD-<slug>.md`. Use `Proposed`, `Accepted`, `Deprecated`, or `Superseded by <link>` truthfully. A new ADR supersedes an accepted decision; do not erase history.

## Context

Describe the forces that make this decision necessary: current behavior, constraints, quality attributes, evidence, and what fails if no decision is made. Link the assessment and measurable baseline.

## Decision

State the chosen option and the exact boundary where it applies. Record competing options and why they were rejected. Identify the person or group authorized to accept this decision.

## Consequences

List expected benefits, costs, operational burden, security implications, migration and rollback impact, and new failure modes. Identify which consequences need monitoring or follow-up work.

## Compliance

State how implementation and ongoing operation will be checked: contract tests, dashboards, review gates, ownership checks, and the evidence that would justify revisiting this ADR.
__RE_ARCHITECT_FILE_09__

mkdir -p -- "$destination/templates"
cat > "$destination/templates/MIGRATION_TICKET_TEMPLATE.md" <<'__RE_ARCHITECT_FILE_10__'
# Migration ticket: Deployable change

**ID:** Assign a stable ticket number

**Phase:** 0 Instrumentation / 1 Shadow or Dual-Write / 2 Canary / 3 Retirement

**Status:** Draft

**Owner:** Assign the implementing role

**Depends on:** Link prerequisite ticket IDs

**Design:** Link SDD section and governing ADRs

> Copy to `docs/architecture/plans/<service-name>/TICKET-NNN-<slug>.md`. Keep scope small enough to deploy and revert independently. Do not mark acceptance before evidence exists.

## Outcome and scope

State the observable production outcome, affected systems, included work, and excluded work. Identify the feature flag or traffic route used to isolate this slice.

## Pre-conditions

List completed dependencies, compatible schemas and clients, access and reviewer requirements, baseline telemetry, runbook, and rollback readiness. Give links to the evidence for each gate.

## Migration steps

Number concrete implementation, deployment, and activation steps. State the actor, environment, expected state after each step, idempotency/retry behavior, and the point at which writes become irreversible.

## Acceptance criteria

Write testable conditions covering functionality, compatibility, security, performance, and data consistency. Use explicit thresholds and observation windows approved in the SDD.

## Verification gates

List the automated test or dashboard query, its expected result, the person checking it, and evidence location. Define a pass/pause/rollback decision before expanding traffic.

## Failure triggers and rollback

Give precise abort signals and the operator's steps to stop traffic or writes, restore a compatible state, reconcile or replay data, verify recovery, and notify the on-call owner. If rollback is impossible, give the SDD's forward-recovery path and escalation gate.
__RE_ARCHITECT_FILE_10__

mkdir -p -- "$destination/templates"
cat > "$destination/templates/SDD_TEMPLATE.md" <<'__RE_ARCHITECT_FILE_11__'
# Solution Design Document: Service migration

**Status:** Draft | **Owner:** Record the accountable team and reviewer | **Last updated:** Record the date | **Related ADRs:** Link the decisions below

> Copy this template to `docs/architecture/SDD-<service-name>.md`. Replace instructional sentences with evidence and decisions. State `Unknown — requires evidence from <owner>` for unresolved facts; do not mark the document approved until reviewers sign off.

## 1. Executive summary

Describe the business objective, affected users and services, migration boundary, expected benefits, non-goals, key risks, and decision requested. Summarize the route to zero downtime and the criteria for stopping safely.

## 2. Scope, evidence, and constraints

Link the Current State Assessment, relevant code paths, dashboards, contract schemas, and incident history. Record the inspected commit and evidence date. State traffic/volume baselines, regulatory constraints, dependencies, assumptions, unknowns, and owners for missing evidence.

## 3. Current and target architecture

Describe where requests enter, which component owns each datum, which calls are synchronous, and which events are asynchronous. Replace the generic labels in both diagrams with actual components and annotate consistency boundaries in prose.

```mermaid
flowchart LR
    Client --> LegacyAPI
    LegacyAPI --> LegacyDB
    LegacyAPI --> Partner
```

```mermaid
flowchart LR
    Client --> Router
    Router --> LegacyAPI
    Router --> NewService
    LegacyAPI --> LegacyDB
    NewService --> NewDB
    NewService -. event .-> Bus
```

| Capability | Current owner | Target owner | Transition seam | Compatibility requirement |
| --- | --- | --- | --- | --- |
| Describe each capability | Identify the source | Identify the future source | Define how routing changes | State which clients must keep working |

## 4. Functional behavior and contracts

Specify API/RPC operations, auth requirements, request/response schemas, errors, pagination, timeouts, and version negotiation. For each event, specify producer, consumer, schema/version, key, ordering, delivery guarantee, replay, and deduplication. Link schema and contract tests; describe behavior under partial failure.

| Contract | Producer → consumer | Versioning / compatibility | Failure and retry behavior | Test evidence |
| --- | --- | --- | --- | --- |
| Name the interface | Identify both ends | State compatibility rules | Define timeout, retry, and idempotency | Link executable checks |

## 5. Data schema and migration strategy

Identify the system of record at every stage. Record schema changes, data classification, read/write ownership, key mapping, transaction boundaries, retention, and migration tooling. Detail expand/migrate/contract order; dual-write or CDC behavior; backfill pagination and checkpoints; handling of late writes; deduplication and idempotency; reconciliation query and tolerances. Explain how to detect and repair divergence and who can pause the job.

| Dataset | Source → destination | Invariant | Backfill / replay | Reconciliation gate | Recovery owner |
| --- | --- | --- | --- | --- | --- |
| Name a dataset | State both stores | State a testable property | Describe checkpoint and replay | Give measurable threshold and window | Name the accountable role |

## 6. Security and authorization

Describe identity propagation, service authentication, authorization rules, tenant isolation, secret storage and rotation, encryption in transit/at rest, audit logs, PII handling, retention, and threat-model changes. Identify reviewers and verification evidence.

## 7. Operational readiness

Define SLIs/SLOs and error budgets from measured baselines: availability, latency, throughput, queue lag, data divergence, and recovery time. Include dashboards, alert thresholds and owners, tracing/correlation IDs, runbooks, capacity tests, failure isolation, circuit breakers, retries, dead-letter handling, rate limiting, and on-call escalation. Distinguish service SLA from internal SLO.

| Signal | Baseline | Target / gate | Data source | Alert owner |
| --- | --- | --- | --- | --- |
| Name an SLI | Link observed baseline | State numeric target or unresolved decision | Link query or dashboard | Name role |

## 8. Rollout and verification

State Phase 0 instrumentation, Phase 1 shadow or dual-write, Phase 2 canary percentages and observation windows, and Phase 3 retirement. For each stage define entry criteria, compatibility checks, automated and human checks, traffic gate, abort trigger, and authorization to advance. Include contract, load, security, fault, and reconciliation tests.

## 9. Rollback and forward-recovery playbook

For each phase describe the switch, operator, maximum decision time, client impact, state consistency impact, evidence of restored service, and steps for reconciling writes. Identify the first irreversible step and what forward recovery replaces rollback after it. Do not promise a rollback that cannot undo writes or schema deletion.

| Phase | Abort trigger | Route/data action | Verification | Decision owner |
| --- | --- | --- | --- | --- |
| Name phase | Measurable threshold | Specify safe action and replay | Specify service and data checks | Name role |

## 10. Decisions, risks, and approval

Link standalone ADRs for consequential choices. Maintain a risk register with likelihood, impact, mitigation, signal, and owner. List open questions with due dates. Record reviewer names, roles, dates, and approval scope when actually obtained; until then retain `Draft` status.
__RE_ARCHITECT_FILE_11__

if [[ ! "$script_source" -ef "$destination/setup-repo.sh" ]]; then
  cp -- "$script_source" "$destination/setup-repo.sh"
fi
chmod +x -- "$destination/setup-repo.sh"
printf 'Created re-architect in %s\n' "$destination"
