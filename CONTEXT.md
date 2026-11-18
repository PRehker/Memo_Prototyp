# CONTEXT.md — Memo: final product context + week-1 prototype plan

Read this at the start of every session before working. The rules in
`AGENTS.md` always apply; the human workflow is in `README.md`.
"Memo" is the development name of the toy (the older README section calls the
same device "Elefant").

## 1. Final product (target vision)

### 1.1 What Memo is

**Memo** is a smart toy for children that guides them through preconfigured
routines (e.g. homework, shower) independently. A routine is triggered by an
NFC sticker stuck at a triggering place or on a triggering object; outside a
routine the toy is in standby. The toy has **no screen** — only NFC, a
microphone and a speaker. Parents use a companion app to configure routines;
in the final product the parent receives a **push notification when a routine
starts** and can **track progress live** as the child completes steps. The
product has two modes: "dumb" offline (keyword matching) with preset responses and "smart" online
(LLM API answering the child's questions).

### 1.2 Actors

- **Child** — triggers routines via NFC sticker, talks with Memo, confirms steps verbally.
- **Parent** — manages routines in the app, gets notified and watches live progress/history/support needs.
- **Course team (us)** — builds the prototype.

### 1.3 Components

| Component | Role | Target tech |
|---|---|---|
| Memo toy | NFC trigger, spoken dialog, runs routines; no screen | Python; PN532 NFC chip; on-device STT (**"Cactus Compute Whistle"** in older notes) + **TTS**; mic + speaker |
| Parent app | Routine library (like Apple's Siri Shortcuts), transfer to Memo, live progress, history, insights, smart-mode toggle | Swift/SwiftUI, **SwiftData** persistence |
| Cloud | LLM API for "smart" mode, optionally TTS | Provider TBD; API keys never committed |

### 1.4 Program flow (toy)

```
standby
└─ NFC scan -> find routine
   ├─ not found -> "unknown sticker" sound, back to standby
   └─ found -> for each routine step:
        1. generate step prompt from routine template, play via TTS
        2. listen for the child's answer (mic muted during output)
        3. speech-to-text on-device (Whistle)
           -> local validation of the answer (keyword match)
           ├─ ok -> success sound, next step
           ├─ unknown/unclear -> re-ask (max 3x), then offer to do it together, then skip
           └─ no answer after 10-15 s -> repeat prompt more motivating, then offer help, else skip
   └─ routine done -> reward sound ("You did it!") -> standby

global: 20-30 min with no interaction -> standby
```

### 1.5 Data model (draft)

- **Routine**: id, name, steps[], transferred flag/version, createdAt — persisted in SwiftData.
- **Step**: id, routineId, position, instruction text (spoken prompt).
- **Sticker**: nfcId -> routineId.
- **Device store (simulated Memo)**: the copy of routines "transferred to Memo" — in week 1 this lives in SwiftData too; later it is what gets sent to the toy.
- **RoutineRun**: id, routineId, startedAt, finishedAt, stepResults[] (stepId, status: done / re-asked / helped / skipped, retry count) — the "usage data sent from Memo"; parent insights (US20–23) derive from it.

### 1.6 Modes

- **Dumb / offline**: on-device STT + keyword matching, canned prompts and feedback. (Later; not this week.)
- **Smart / online**: LLM API generates Memo's responses and answers to the child's questions (US14). **This is the main scope of week 1.**

### 1.7 Safety and quality constraints

- Child-facing answers must be short, age-appropriate and never give dangerous
  instructions (US14).
- Prefer on-device speech processing where possible (privacy).

### 1.8 Story → component mapping

| Stories | Component |
|---|---|
| US1–US7 (routine CRUD, transfer, transfer status) | App (SwiftData; transfer writes the simulated device store) |
| US8–US19 (trigger, dialog, progress, feedback) | Player mode in the app (week 1), later the toy |
| US20–US23 (progress, history, support needs) | App, from RoutineRun history; live progress is natural since the app runs the routine |

## 2. User stories (mirror of the Trello board)

Full card text lives on Trello — paste the card into the prompt when starting
a story.

- **US1 — Neue Routine erstellen**: parent creates a routine with a custom name.
- **US2 — Schritte zu einer Routine hinzufügen**: add multiple ordered steps.
- **US3 — Bestehende Routinen bearbeiten**: rename, edit/add/remove steps, persists on reopen.
- **US4 — Routinen löschen**: safety confirmation, cancellable, gone from overview.
- **US5 — Routine an Memo übertragen**: transfer routine + all steps to Memo, order preserved.
- **US6 — Übertragungsstatus anzeigen**: success confirmed, failure shown understandably, retry possible, marked transferred only when confirmed.
- **US7 — Änderungen an Routinen an Memo übertragen**: re-transfer replaces the previous version on Memo.
- **US8 — Kind hält Memo an NFC Sticker**: recognize sticker, map to routine, feedback on unknown sticker, no parent-app help.
- **US9 — Aktivierung & motivierende Begrüßung**: spoken, child-friendly greeting, then intro.
- **US10 — Vorbereitung auf die Routine**: routine-matching preparation instructions (e.g. prepare desk), then continue.
- **US11 — Freut sich das Kind auf das Thema?**: Memo asks and reacts to the answer.
- **US12 — Startschuss für die Routine**.
- **US13 — Memo reagiert auf Antworten**: waits for verbal answer; confirm + next step; re-ask max 3x on unclear; help/skip on difficulties; re-ask after 10–15 s silence.
- **US14 — Memo reagiert auf Fragen**: short, age-appropriate, safe answer, then back to the routine; says so when it cannot answer.
- **US15 — Fortschritt checken**: track current step, mark confirmed steps done, adjust for skipped steps, detect completion.
- **US16 — Kind meldet "fertig"**: child says done; Memo checks against recorded progress.
- **US17 — Abschluss-Review**: after "fertig", Memo walks through all steps in order and asks for each whether it was done; open tasks are recognized and can be caught up.
- **US18 — Punkt-für-Punkt-Bestätigung**: during that review, the child confirms each task individually (done / not done).
- **US19 — Positives Feedback pro Aufgabe**: friendly feedback per confirmed task, special praise at routine end, then standby.
- **US20 — Eltern sehen den Fortschritt einer Routine** (final product: push notification on start + live progress).
- **US21 — Eltern sehen, welche Aufgaben erledigt wurden**.
- **US22 — Eltern können vergangene Routinen einsehen**.
- **US23 — Eltern erkennen Unterstützungsbedarf**: steps with re-asks/help/skips across runs, shown as hints, not facts.

## 4. Workflow (summary)

1. Take a user story from Trello, start a new chat with the full story text
   in the prompt (`US-12: As a ... I want ... so that ...`).
2. The agent runs `./scripts/sync-check.sh` (timestamp; pull if >2h stale),
   then `./scripts/story-branch.sh US-12 <slug>` (checkout or create
   `story/us-12-*` from `origin/main`). Never work on `main` (admin branch
   `operative` excepted for org changes).
3. Work per `AGENTS.md` (skills, rtk, verify against real data, prove it runs).
4. Commits `US-12: ...` with the user's own git credentials, push branch, open
   PR into `main`. Only Philip/Team approves and merges.