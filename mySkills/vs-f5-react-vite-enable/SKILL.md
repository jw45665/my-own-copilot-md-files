---
name: vs-f5-react-vite-enable
version: 1.0
description: Aktiviert in React/Vite-Projekten die Ausführung mit F5 in Visual Studio und legt/merged gleichzeitig die VS-Code-Debugkonfiguration an. Use when users ask things like: "Ich möchte die Anwendung in VS mit F5 starten können", "React/Vite in Visual Studio debuggen", "F5-Start für Vite einrichten", "launch.json für Edge/Chrome anlegen", "esproj mit npm run dev konfigurieren", "VS + VS Code Startkonfiguration für React Vite".
---

# VS-F5 für React/Vite aktivieren (autonome Ausführung)

Dieser Skill wird ausgeführt, nicht nur erklärt.
Wende die Schritte direkt im aktuellen Workspace an.

## Eingaben
- Projektroot mit `package.json`
- Optional vorhandene Dateien: `vite.config.ts`, `*.esproj`, `.vscode/launch.json`

## Ziel
- F5 in Visual Studio startet den Dev-Server über `npm run dev`.
- VS Code enthält lauffähige Browser-Launch-Profile für dieselbe URL.
- Änderungen sind idempotent und minimal-invasiv.

## Ausführungsregeln
- Nie blind überschreiben.
- Immer lesen, dann gezielt patchen.
- Bestehende fremde Konfigurationen beibehalten.
- Keine Duplikate erzeugen.

## Workflow (deterministisch)

### 1) Vite-Port ermitteln
1. Lies `vite.config.ts`.
2. Verwende `server.port`, falls gesetzt.
3. Fallback auf `5173`, falls kein Port konfiguriert ist.

### 2) Visual-Studio-F5 aktivieren
1. Suche eine `*.esproj` im Projekt.
2. Wenn keine existiert: erstelle `<projektname>.esproj` im Projektroot.
3. Stelle sicher, dass ein `<PropertyGroup>` mit folgenden Werten existiert:
   - `<StartupCommand>npm run dev</StartupCommand>`
   - `<JavaScriptTestRoot>src\</JavaScriptTestRoot>`
   - `<JavaScriptTestFramework>Vitest</JavaScriptTestFramework>`
   - `<ShouldRunBuildScript>false</ShouldRunBuildScript>`
   - `<BuildOutputFolder>$(MSBuildProjectDirectory)\dist</BuildOutputFolder>`
4. Falls Werte existieren und abweichen, korrigiere nur diese Werte.
5. Alle anderen XML-Knoten unverändert lassen.

Minimaler Soll-Zustand:

```xml
<Project Sdk="Microsoft.VisualStudio.JavaScript.Sdk/1.0.4338480">
  <PropertyGroup>
    <StartupCommand>npm run dev</StartupCommand>
    <JavaScriptTestRoot>src\</JavaScriptTestRoot>
    <JavaScriptTestFramework>Vitest</JavaScriptTestFramework>
    <ShouldRunBuildScript>false</ShouldRunBuildScript>
    <BuildOutputFolder>$(MSBuildProjectDirectory)\dist</BuildOutputFolder>
  </PropertyGroup>
</Project>
```

### 3) VS-Code-Launchkonfiguration mergen
1. Zielpfad: `.vscode/launch.json`.
2. Wenn Datei fehlt: neu erzeugen mit `version` und `configurations`.
3. Wenn Datei existiert:
   - JSON parsen.
   - Vorhandene `configurations` vollständig beibehalten.
   - Eintrag `name: "localhost (Edge)"` aktualisieren oder ergänzen.
   - Eintrag `name: "localhost (Chrome)"` aktualisieren oder ergänzen.
4. Für beide Profile sicherstellen:
   - `request: "launch"`
   - `url: "http://localhost:<PORT>"`
   - `webRoot: "${workspaceFolder}"`
5. Keine weiteren Konfigurationen entfernen oder umsortieren.

Soll-Einträge:

```json
{
  "type": "edge",
  "request": "launch",
  "name": "localhost (Edge)",
  "url": "http://localhost:<PORT>",
  "webRoot": "${workspaceFolder}"
}
```

```json
{
  "type": "chrome",
  "request": "launch",
  "name": "localhost (Chrome)",
  "url": "http://localhost:<PORT>",
  "webRoot": "${workspaceFolder}"
}
```

### 4) Validierung ausführen
1. Prüfe, dass `*.esproj` `StartupCommand` auf `npm run dev` enthält.
2. Prüfe, dass `.vscode/launch.json` beide Profile mit demselben Port enthält.
3. Stelle sicher, dass ein zweiter Lauf keine Duplikate erzeugt.

## Abbruch-/Fehlerregeln
- Wenn `package.json` fehlt: mit klarer Fehlermeldung abbrechen.
- Wenn `launch.json` kein valides JSON ist: Datei sichern und durch valides JSON mit Merge-Zielprofilen ersetzen.
- Wenn mehrere `*.esproj` vorhanden sind: die mit passendem Projektnamen bevorzugen, sonst die erste und Entscheidung im Ergebnis nennen.

## Ergebnisbericht
Gib nach Ausführung immer kurz aus:
- geänderte Dateien
- verwendeter Port
- ob erstellt oder gemerged wurde
- offene manuelle Restschritte (falls vorhanden)
