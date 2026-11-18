## Wie wir arbeiten (Workflow für alle)

1. **User Story aus Trello**: Nimm eine Karte vom Trello-Board. Starte einen **neuen Chat** und kopiere die Story in den Prompt, z. B.:
   `US-12: Als Kind möchte ich … damit …` (Titel + Beschreibung der Trello-Karte).
2. **Der Agent richtet alles ein**: Vor jeder Arbeit führt der Agent zuerst `./scripts/sync-check.sh` aus (aktualisiert `lastWorkedTimestamp.txt`; nach mehr als 2 h Inaktivität wird zuerst GitHub nach neuen Versionen) und danach `./scripts/story-branch.sh US-12 <stichwort>`. Dabei wird ein vorhandener Branch `story/us-12-*` ausgecheckt oder ein neuer von `origin/main` erstellt. Niemals direkt auf `main` arbeiten.
3. **User Story arbeiten**: Mach dir zuerst (gerne mit Hilfe des Agenten) einen Plan, wie du die User Story technisch ausarbeitest. Lasse dir gerne einzelne Teile/Optionen erklären, gegenüberstellen oder recherchiere sie selbst.
4. **Die Regeln für Agenten**: Skills werden vom Agenten geladen (caveman, ponytail, ggf. groundcheck), Shell-Befehle über `rtk` ausführen, jede Annahme und jede Code-Stelle gegen echte Daten im Internet prüfen (offizielle Doku, Demo-Projekte, installierte Paketquellen, laufender Code) — und nichts behaupten, ohne es ausprobiert zu haben.
5. **App ausführen (erste Woche: nur Swift)**: Agentic Coding machen wir in **VSCode** — die App führen wir in **Xcode** aus (Projekt öffnen, Run). Später steigen wir eventuell auf Python um; dann passen wir dieses README an.
6. **Commits & Pull Request**: Commit-Messages beginnen mit der Story-ID (`US-12: …`). Branch pushen (`git push -u origin <branch>`) und Pull Request gegen `main` öffnen. Der PR bleibt offen, bis **Philip ihn approved und merged** — niemals selbst mergen.
7. **Fertig**: Sobald der PR durch ist, ist die Story erledigt. Sonst muss nichts weiter aktualisiert werden.

## Programmflow Elefant (Routinen)
```
standby
└─ NFC scan -> finde Routine
   ├─ nicht gefunden -> "unknown sticker" Sound, zurück zu standby
   └─ gefunden -> für jeden Routinen-Schritt:
        1. Schritt-Prompt aus Routinen-Vorlage generieren, per Text-to-speech abspielen
        2. Auf Antwort des Kindes hören (Mikros sind wären dem Output gemuted)
        3. Speech-to-text on-device (Whistle)
           -> lokale Validierung der Antwort des Kindes (keyword match)
           ├─ ok -> success sound, nächster Routinen-Schritt
           ├─ Unbekannt/Unklar -> Erneut fragen (max 3x), danach Vorschlag, zusammen durchzugehen, danach überspringen
           └─ Keine Antwort nach 10-15 s -> Prompt motivierter wiederholen, danach Hilfe anbieten, sonst überspringen
   └─ Routine fertig -> reward sound ("You did it!") -> standby

global rules:
└─ 20-30 min with no interaction -> standby
```
