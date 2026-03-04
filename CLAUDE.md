# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**SPR House Maintenance Tracker** is a Flutter mobile app (iOS + Android) for Filipino homeowners to track property maintenance tasks and connect with home service vendors. The project is currently in the **planning/pre-implementation phase** — there is no source code yet.

The product is a two-sided marketplace:
- **Homeowners**: Set up a property, get a smart maintenance schedule with push reminders, track a Home Health Score, and book service vendors in one tap.
- **Vendors**: Fast onboarding (under 2 minutes), instant booking notifications, availability toggle, earnings dashboard, and QRPH/GCash payment collection.

## Repository Structure

```
docs/PRD/           # Product Requirements Document (sharded by section)
  index.md          # PRD table of contents — start here for product context
  4-tech-stack.md   # Tech decisions (Flutter confirmed; backend/storage TBD)
  12-epics-user-stories-acceptance-criteria.md  # Full epics H1–V9

docs/archive/       # Full original PRD.md before sharding

_bmad/              # BMAD framework — AI-assisted development methodology
  _config/          # Manifests, agent configs, IDE config
  core/             # Core BMAD tasks and workflows
  bmm/              # Software delivery module (PM, dev, architect, QA agents)
  bmb/              # BMAD builder module (create/validate agents/workflows)
  cis/              # Creative Intelligence Suite module
  tea/              # Test Architecture Enterprise module

_bmad-output/       # All AI-generated artifacts land here
  brainstorming/    # Ideation session outputs
  planning-artifacts/   # PRDs, architecture docs, epics, stories
  implementation-artifacts/  # Code specs, quick specs
  test-artifacts/   # Test plans, E2E tests
  bmb-creations/    # Custom agents/workflows built by bmb module

.claude/commands/   # Slash commands for BMAD agents and workflows
```

## Confirmed Tech Stack

| Layer | Decision |
|---|---|
| Mobile | Flutter (iOS + Android) |
| Push Notifications | Firebase Cloud Messaging via `firebase_messaging` |
| Authentication | Email + password |
| Backend | **TBD — must decide at hackathon Day 1** |
| Storage | **TBD — image uploads required** |

## Using BMAD Agents

This repo has the BMAD AI development framework installed (v6.0.4). Use slash commands to activate specialized agents:

- `/bmad-agent-bmad-master` — Orchestrator; use when unsure which agent to invoke
- `/bmad-agent-bmm-pm` — Product Manager; for PRD work
- `/bmad-agent-bmm-architect` — Architect; for technical design decisions
- `/bmad-agent-bmm-dev` — Developer agent; for story implementation
- `/bmad-agent-bmm-qa` — QA agent; for test plans and test generation
- `/bmad-bmm-dev-story` — Execute a story spec file
- `/bmad-bmm-create-architecture` — Generate architecture doc
- `/bmad-bmm-sprint-planning` — Generate sprint plan from epics
- `/bmad-help` — Get guidance on what to do next

All AI-generated artifacts should be saved under `_bmad-output/` in the appropriate subdirectory.

## Key Product Context

**Epics (MVP / Hackathon scope):**
- Epic 1–2: Property setup, maintenance templates, recurring reminders, Home Health Score (H1–H5)
- Epic 3: Vendor discovery, one-tap booking, status tracker, no-show enforcement (H6–H9)
- Epic 4–7: Vendor onboarding, booking management, earnings dashboard, QRPH payment (V1–V9)

**Critical design constraint**: No-show vendors are **immediately suspended** — this is a core trust mechanism.

**Payment flow**: Vendor sets min/max price range at onboarding; inputs final price on job completion; homeowner pays via QRPH scan or GCash deep link. No payment integration required for MVP.

**Revenue model**: Admin fee is 10% of completed job value (waived at launch). Homeowner side is always free.

## Day-1 Decisions Required Before Implementation

1. Backend framework (must support Flutter and FCM)
2. Storage provider for image uploads (profile photos, maintenance logs, QRPH codes)
3. Vendor cold-start strategy for hackathon demo (mock data vs. manual signup)
4. Verify `gcash://` deep link scheme on both iOS and Android test devices
