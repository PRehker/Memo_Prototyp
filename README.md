








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

## Programmflow App
TBD


## Wie setze ich Sachen technisch um
### App Programmiersprache
Option 1 (favorit): Swift
Option 2: Svelte (WebApp)

### Elefant Programmiersprache
Option 1: Python
Option 2: C

### NFC Sticker einlesen
Wir wollen den PN532 chip zum einlesen nutzen, die folgenden Bibliotheken gibt es
Option 1 (favorit): https://pypi.org/project/pn532pi/
Option 2: 

### Speech To Text (local)
Option n:
Option n:
Option n:

### Text To Speech (cloud)
Option n:


### Speech To Text (local only)
Option n:

### LLM (local)
Option n:

### LLM (cloud API)
Option n: