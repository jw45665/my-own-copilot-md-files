---
name: lm-studio-sync
displayName: LM Studio Model Sync
description: Synchronisiert automatisch die verfügbaren LM-Studio-Modelle mit der chatLanguageModels.json Konfiguration.
version: 1.0.0
author: JW
---

# LM Studio Model Sync Skill

## Beschreibung
Dieser Skill synchronisiert automatisch die verfügbaren LM-Studio-Modelle mit der chatLanguageModels.json Konfiguration. Er ruft die aktuellen Modelle vom LM Studio Server ab und aktualisiert die Konfigurationsdatei entsprechend.

## Verwendung
Wenn der Benutzer fordert:
- "Synchronisiere die LM-Studio-Modelle"
- "Aktualisiere LM-Studio Modelle"
- "Stelle die LM Studio Modelle bereit"
- "Aktualisiere chatLanguageModels.json mit LM-Studio-Modellen"

## Schritt-für-Schritt Anleitung

### 1. LM Studio Server URL ermitteln
Lese die aktuelle chatLanguageModels.json und extrahiere die LM Studio Server URL:
- Standard Port: `1234`
- URL Format: `http://192.168.178.42:1234`
- Lokale Verbindung: `http://localhost:1234`

### 2. Verfügbare Modelle abrufen
Führe REST-Abfrage aus (OpenAI-kompatible API):
```bash
curl http://192.168.178.42:1234/v1/models
```

Beispiel-Antwort:
```json
{
  "data": [
    {
      "id": "qwen/qwen2.5-coder-14b",
      "object": "model",
      "owned_by": "organization_owner"
    },
    {
      "id": "llm/gguf/mistral-7b-instruct-v0.1.q4_0.gguf",
      "object": "model",
      "owned_by": "organization_owner"
    }
  ],
  "object": "list"
}
```

### 3. Vision und Tool-Calling erkennen
Basierend auf Modell-IDs (von der `/v1/models` API):
- Wenn "llava", "vision" oder "clip" im Namen: `"vision": true`
- Wenn "qwen", "gpt", "command" oder "tool" im Namen: `"toolCalling": true`
- Embedding-Modelle ausschließen
- Standard sonst: `false`

### 4. Token-Limits bestimmen
Basierend auf der Modellgröße (aus dem Namen extrahiert):

| Größe | maxInputTokens | maxOutputTokens |
|-------|---|---|
| < 10B | 32768 | 8192 |
| 10B - 30B | 128000 | 16000 |
| > 30B | 256000 | 32000 |

Fallback für unbekannte Größen: 128000/16000

### 5. JSON-Struktur erstellen
Erstelle für jedes Modell einen Eintrag:
```json
{
  "id": "qwen/qwen2.5-coder-14b",
  "name": "qwen2.5-coder-14b",
  "url": "http://192.168.178.42:1234",
  "toolCalling": true,
  "vision": false,
  "maxInputTokens": 128000,
  "maxOutputTokens": 16000
}
```

### 6. chatLanguageModels.json aktualisieren
- Finde den LM-Studio-Eintrag (vendor: "customoai")
- Ersetze das `models`-Array komplett
- Behalte andere Provider unverändert
- Verwende `replace_string_in_file` für die Aktualisierung

### 7. Bestätigung
Gebe eine kurze Zusammenfassung aus:
- Anzahl gefundener Modelle
- Liste der Modellnamen mit Fähigkeiten
- Bestätigung der erfolgreichen Aktualisierung

## Beispiel-Ausgabe

```
Synchronisiere LM-Studio-Modelle von http://192.168.178.42:1234...
Verbindung zu LM Studio Server wird geprüft...
Verbindung zu LM Studio Server erfolgreich.
Gefundene Modelle: 11

  - qwen2.5-coder-14b (Tool-Calling)
  - deepseek-r1-distill-qwen-14b-q4_0.gguf
  - em_german_mistral_v01.q4_0.gguf
  - meta-llama-3-8b-instruct.q4_0.gguf
  - mistral-7b-instruct-v0.1.q4_0.gguf
  - orca-2-13b.q4_0.gguf
  - qwen3-30b-a3b-q4_0.gguf
  - nomic-embed-text-v1.5 (Embedding)
  - qwen3-coder-30b (Tool-Calling)
  - gpt-oss-20b
  - phi-4-mini-reasoning

Konfiguration aktualisiert.
✓ 11 Modelle erfolgreich synchronisiert
```

## Parameter (optional)
- `LMStudioUrl`: Server URL (default: http://192.168.178.42:1234)
- `ConfigPath`: Pfad zur chatLanguageModels.json
- `EnableVision`: Vision-Features aktivieren (true/false)

## Fehlerbehandlung
- Wenn der LM Studio Server nicht erreichbar ist, informiere den Benutzer
- Wenn keine Modelle gefunden werden, warne den Benutzer
- Versuche TCP-Verbindung zu testen bevor API-Anfrage gestellt wird
- Behalte alte Konfiguration bei Fehler
