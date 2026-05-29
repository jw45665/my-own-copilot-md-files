---
name: ollama-sync
displayName: Ollama Model Sync
description: Synchronisiert automatisch die verfügbaren Ollama-Modelle mit der chatLanguageModels.json Konfiguration.
version: 1.0.0
author: JW
---

# Ollama Model Sync Skill

## Beschreibung
Dieser Skill synchronisiert automatisch die verfügbaren Ollama-Modelle mit der chatLanguageModels.json Konfiguration. Er ruft die aktuellen Modelle vom Ollama-Server ab und aktualisiert die Konfigurationsdatei entsprechend.

## Verwendung
Wenn der Benutzer fordert:
- "Synchronisiere die Ollama-Modelle"
- "Aktualisiere die Ollama-Modelliste"
- "Stelle die verfügbaren Ollama-Modelle bereit"
- "Aktualisiere chatLanguageModels.json mit Ollama-Modellen"

## Schritt-für-Schritt Anleitung

### 1. Ollama-Server URL ermitteln
Lese die aktuelle chatLanguageModels.json und extrahiere die Ollama-Server URL:
- Standardpfad (Benutzer): `vscode-userdata:/c%3A/Users/blazo/AppData/Roaming/Code%20-%20Insiders/User/chatLanguageModels.json`
- Workspace-Pfad: `.vscode/settings.json` (unter `chat.languageModels`)

### 2. Verfügbare Modelle abrufen
Führe curl-Befehl aus:
```bash
curl <OLLAMA_URL>/api/tags
```

Beispiel-Antwort:
```json
{
  "models": [
    {
      "name": "qwen2.5-coder:latest",
      "model": "qwen2.5-coder:latest",
      "size": 4661211936,
      "digest": "...",
      "details": {
        "parameter_size": "7.6B",
        "quantization_level": "Q4_K_M"
      }
    }
  ]
}
```

### 3. Token-Limits bestimmen
Für jedes Modell, ermittle basierend auf der Parameter-Größe angemessene Token-Limits:

| Parameter Size | maxInputTokens | maxOutputTokens |
|---------------|----------------|-----------------|
| < 10B         | 32768          | 8192            |
| 10B - 20B     | 65536          | 16384           |
| > 20B         | 131072         | 32768           |

Falls `details.parameter_size` nicht verfügbar ist, verwende 32768/8192 als Standard.

### 4. JSON-Struktur erstellen
Erstelle für jedes Modell einen Eintrag:
```json
{
  "id": "<model.name>",
  "name": "<model.name>",
  "maxInputTokens": <calculated>,
  "maxOutputTokens": <calculated>
}
```

### 5. chatLanguageModels.json aktualisieren
- Finde den Ollama-Eintrag in der Konfiguration
- Ersetze das `models`-Array komplett mit den aktuellen Modellen
- Behalte andere Provider (z.B. LM-Studio) unverändert
- Verwende `replace_string_in_file` oder `multi_replace_string_in_file` für die Aktualisierung

### 6. Bestätigung
Gebe eine kurze Zusammenfassung aus:
- Anzahl der gefundenen Modelle
- Liste der Modellnamen
- Bestätigung der erfolgreichen Aktualisierung

## Beispiel-Ausgabe

```
Ollama-Modelle synchronisiert:
- phi4-reasoning:14b
- qwen3-coder:30b
- gpt-oss:20b
- deepseek-r1:8b

4 Modelle in chatLanguageModels.json aktualisiert.
```

## Fehlerbehandlung
- Wenn der Ollama-Server nicht erreichbar ist, informiere den Benutzer
- Wenn keine Modelle gefunden werden, warne den Benutzer
- Behalte die alte Konfiguration, falls ein Fehler auftritt

## Hinweise
- Der Skill funktioniert sowohl mit der Benutzer- als auch der Workspace-Konfiguration
- Andere Provider in der chatLanguageModels.json bleiben unverändert
- Die Modellnamen werden direkt von Ollama übernommen (mit Tags wie `:14b` oder `:latest`)
