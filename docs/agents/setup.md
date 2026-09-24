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
