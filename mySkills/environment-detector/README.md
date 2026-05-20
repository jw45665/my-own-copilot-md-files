# Environment Detector Skill

Automatische Erkennung von Umgebungsinformationen für das `environment`-Objekt in `data/model-metadata.json`.

## Features

- ✅ Automatische Erkennung von OS, Python, Node.js Versionen
- ✅ VS Code Version (via `code --version`)
- ✅ Installierte Extensions (GitHub Copilot, Pylance, etc.)
- ✅ MCP Server aus VS Code Settings
- ✅ Aktuelles Datum
- ⚠️ IDE-Name: Semi-automatisch (Heuristik + manuelle Verifikation)

## Usage

### 1. Standalone: Environment in separate Datei speichern

```bash
python skills/environment-detector/detect_env.py --output data/env-detected.json
```

**Output**: Erstellt `data/env-detected.json` mit vollständigem Environment-Objekt.

### 2. Merge: In existierende model-metadata.json einfügen

```bash
python skills/environment-detector/detect_env.py --merge data/model-metadata.json
```

**Effekt**: 
- Fügt `environment`-Objekt in `model-metadata.json` ein
- Überschreibt KEINE manuell gesetzten Werte
- Zeigt an, welche Felder manuelle Verifikation brauchen

### 3. Verbose: Detaillierte Erkennungsinformationen

```bash
python skills/environment-detector/detect_env.py --verbose --merge data/model-metadata.json
```

## Was wird erkannt?

### ✅ Vollautomatisch

- **OS**: Windows, macOS, Linux (mit Distribution)
- **Python Version**: Aus laufendem Interpreter
- **Node.js Version**: Falls installiert
- **Test-Datum**: Aktuelles Datum (ISO 8601)
- **MCP Server**: Aus VS Code Settings (`.vscode/settings.json` oder User Settings)

### ⚙️ Semi-automatisch (CLI-basiert)

- **VS Code Version**: Via `code --version` (falls VS Code im PATH)
- **Extensions**: Via `code --list-extensions --show-versions`
- **Copilot Version**: Aus Extension-Liste extrahiert

### ⚠️ Manuell erforderlich

- **IDE-Name**: Kann nicht zuverlässig unterschieden werden zwischen:
  - Visual Studio Code
  - Cursor (VS Code Fork)
  - VSCodium
  - Azure Data Studio
  - Andere VS Code-basierte IDEs

**Empfehlung**: Das Skript setzt `"Visual Studio Code (detected)"` — bitte manuell verifizieren und anpassen!

## Erkanntes Format

```json
{
  "ide": "Visual Studio Code (please verify)",
  "ide_version": "1.95.3",
  "copilot_version": "1.250.0",
  "extensions": [
    "github.copilot@1.250.0",
    "ms-python.python@2024.20.0",
    "ms-python.vscode-pylance@2024.1.1"
  ],
  "mcp_servers": [
    "playwright",
    "microsoft-docs",
    "github"
  ],
  "test_date": "2026-01-27",
  "os": "Windows 11",
  "python_version": "3.12.0",
  "node_version": "v20.11.0",
  "notes": "",
  "_detection_metadata": {
    "auto_detected": true,
    "confidence": "medium",
    "manual_verification_needed": ["ide"]
  }
}
```

## Für Agenten: Empfohlener Workflow

1. **Führe Skill aus**:
   ```bash
   python skills/environment-detector/detect_env.py --merge data/model-metadata.json
   ```

2. **Prüfe Output**: Das Skript zeigt an, welche Felder manuelle Verifikation brauchen

3. **IDE-Name anpassen**:
   - Falls du weißt, dass du in VS Code bist: Setze `"ide": "Visual Studio Code"`
   - Falls Cursor: `"ide": "Cursor"`
   - Falls Visual Studio: `"ide": "Visual Studio"`
   - Falls unsicher: Behalte `"Visual Studio Code (detected)"` oder trage `"Visual Studio Code or compatible"` ein

4. **Optional**: Ergänze `notes` mit Besonderheiten (z.B. "YOLO Mode enabled", "Custom MCP setup")

## Troubleshooting

### `code --version` funktioniert nicht

**Problem**: VS Code ist nicht im PATH oder anders benannt.

**Lösung**:
- Windows: Prüfe ob VS Code installiert ist unter `C:\Program Files\Microsoft VS Code\`
- macOS: `/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code`
- Linux: `/usr/bin/code` oder `/snap/bin/code`
- Alternativ: Trage Version manuell ein

### MCP Server werden nicht erkannt

**Problem**: Settings liegen an unüblichem Ort oder JSON hat Kommentare.

**Lösung**:
- Prüfe `.vscode/settings.json` im Workspace
- Prüfe User Settings (VS Code: `Ctrl+,` → "Open Settings (JSON)")
- Trage MCP-Server manuell in `model-metadata.json` ein

### Extensions-Liste ist leer

**Problem**: `code --list-extensions` schlägt fehl.

**Lösung**:
- Öffne VS Code
- Extensions-Panel (`Ctrl+Shift+X`)
- Liste manuell ab und trage in `model-metadata.json` ein

## Dependencies

Keine! Das Skript nutzt nur Python Standard Library.

## Integration in Agent-Workflow

Agenten sollten diesen Skill automatisch in Schritt 2 (nach Branch-Check, vor Metadaten-Befüllung) ausführen:

```markdown
1. ✅ Branch-Check
2. 🔍 Environment ermitteln: `python skills/environment-detector/detect_env.py --merge data/model-metadata.json`
3. ✏️ Metadaten vervollständigen (model-metadata.json)
4. 🏗️ Module erstellen
...
```

So ist die Umgebung dokumentiert und reproduzierbar!
