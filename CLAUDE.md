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
