---
name: vscode-web-start-config
displayName: VS Code Web Start Config
description: Set up robust VS Code startup flows for website projects so users can press F5 and get a working local server plus browser launch.
version: 1.0.0
author: JW
---

# vscode-web-start-config

Reusable skill for configuring VS Code F5 startup workflows in website projects.

## What this skill does

- Repairs or creates VS Code startup wiring for web projects.
- Ensures F5 triggers Run and Debug profiles.
- Starts a local server first, then opens a browser.
- Supports multiple browser targets such as Chrome Incognito, Edge InPrivate, and default browser.
- Updates project documentation with quick usage steps.

## Runtime strategy (Node and IIS Express)

The skill resolves server runtime in this order:

1. Reuse an existing working server task if present.
2. Prefer Node when Node is available and the project has a Node entry point.
3. If Node is missing but IIS Express exists, configure IIS Express for the web root.
4. If both are missing, propose Node LTS installation and continue after user confirmation.

Server file handling policy:

1. Existing project server files are reused and not overwritten automatically.
2. A new `server.js` is created only if no working server command exists and the user agrees.
3. The skill includes a reusable Node static server template at:
	- .github/skills/vscode-web-start-config/templates/server.node-static.js

Typical Node install command on Windows:

```powershell
winget install OpenJS.NodeJS.LTS
```

Typical IIS Express executable paths checked by the skill:

- C:/Program Files/IIS Express/iisexpress.exe
- C:/Program Files (x86)/IIS Express/iisexpress.exe

## Typical use cases

- "F5 does nothing in this website project"
- "Start local server and open browser automatically"
- "Add browser choices in launch profiles"
- "Fix broken launch.json/tasks.json setup"

## Example prompt collection

1. "Fix F5 in this website project so server starts first and browser opens after that."
2. "Add VS Code startup profiles for Chrome Incognito, Edge InPrivate, and default browser."
3. "Repair launch.json and tasks.json and keep unrelated tasks untouched."
4. "Configure F5 to use Run and Debug profile selection."
5. "If Node is not installed, guide installation; otherwise use IIS Express if available."
6. "Update README with a short Run and Debug startup guide."

## Beispiel-Promptsammlung (Deutsch)

1. "Bitte F5-Start fuer dieses Website-Projekt einrichten: Server starten und Browser oeffnen."
2. "Erweitere die Startkonfiguration um Chrome Inkognito, Edge InPrivate und Standardbrowser."
3. "Nutze vorhandene server.js weiter; nur wenn nichts vorhanden ist, neue Serverdatei anlegen."
4. "Falls Node nicht installiert ist, Installationsschritte vorschlagen oder IIS Express verwenden."
5. "Stelle sicher, dass F5 ueber Run and Debug startet und die Profil-Auswahl nutzbar ist."

## Files this skill usually edits

- .vscode/tasks.json
- .vscode/launch.json
- .vscode/keybindings.json
- README.md (optional, for user instructions)

## Expected end state

1. A working local server start task.
2. Browser-specific tasks.
3. Compound startup tasks with ordered execution.
4. Launch profiles that call preLaunchTask entries.
5. F5 mapped to debug start behavior.

## Notes

- The skill is idempotent: rerunning should update existing entries instead of duplicating them.
- Existing unrelated tasks and launch profiles should remain untouched.
- Port and URL are inferred from project files when possible; otherwise they should be confirmed with the user.
