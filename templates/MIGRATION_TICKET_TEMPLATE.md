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
