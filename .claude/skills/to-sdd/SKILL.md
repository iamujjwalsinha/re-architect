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
