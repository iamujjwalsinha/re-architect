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
