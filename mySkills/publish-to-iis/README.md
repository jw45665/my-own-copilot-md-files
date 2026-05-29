---
name: publish-to-iis
displayName: Publish to IIS
description: Definiert einen reproduzierbaren Ablauf, um ein Vite/React-Projekt auf IIS zu veröffentlichen.
version: 1.0.0
author: JW
---

# Skill: publish-to-iis

Dieser Skill definiert einen reproduzierbaren Ablauf, um ein Vite/React-Projekt auf IIS zu veröffentlichen.

## Wann verwenden
- Wenn ein Agent ein Deployment nach IIS durchführen soll.
- Wenn Ziel-IP/Host und Domain/Site bekannt sind.
- Wenn das Admin-Passwort über `IIS_ADMIN` als Umgebungsvariable verfügbar ist.

## Benötigte Eingaben
- `targetIp`: Ziel-IP des IIS-Servers (z. B. `85.215.180.164`)
- `targetDomainOrSite`: IIS-Site-Name bzw. Domain (z. B. `react-dev.server-1.net`)
- `username`: Standardmäßig `Administrator`
- `passwordEnvVar`: Standardmäßig `IIS_ADMIN`

## Ergebnis
- Produktion-Build wird erstellt.
- Inhalte werden nach IIS übertragen.
- Erreichbarkeit wird per HTTP geprüft (Root + Deep Route).

## Umgang mit Skripten
- Der Skill funktioniert generisch und projektunabhängig.
- Ein Projekt muss keine eigenen Deploy-Skripte enthalten, damit der Agent veröffentlichen kann.
- Vorhandene Projektskripte sind optional und können als Komfort-Einstieg genutzt werden.

## Fallback-Skript im Skill
- Der Skill enthält `web-deploy.ps1` als generisches Web-Deploy-Skript.
- Dieses Skript ist der robuste Standardweg für Agenten.
- Projektskripte sind optional und ergänzend.

## Enthaltene Datei
- `SKILL.md`: Detaillierte Schritt-für-Schritt-Anleitung für Agenten.
- `web-deploy.ps1`: Generisches Web-Deploy-Skript für agentisches Veröffentlichen.
