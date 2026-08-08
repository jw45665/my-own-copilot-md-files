---
name: add-md-footer
description: 'Versieht Markdown-Dateien mit einem standardisierten Footer (Titel + Datum). Nutze diesen Skill, wenn Markdown-Dateien (README, CHANGELOG, Dokumentation) einen einheitlichen Footer mit Projektname, Copyright und aktuellem Datum erhalten sollen.'
version: 1.0.0
author: JW
license: MIT
---

# Add-MD-Footer Skill

Fuegt Markdown-Dateien automatisch einen standardisierten Footer hinzu oder aktualisiert einen vorhandenen. Der Footer enthaelt den Titel der Datei (aus der ersten H1-Ueberschrift), den Projektnamen (aus dem Git-Repository), das aktuelle Datum und einen Copyright-Hinweis.

## Wann diesen Skill nutzen

- Neue Markdown-Datei wurde erstellt und benoetigt einen Footer
- Bestehende Markdown-Datei wurde geaendert und der Footer-Stand soll aktualisiert werden
- Alle Markdown-Dateien im Projekt-Root sollen einheitlich mit Footern versehen werden
- CHANGELOG.md, README.md oder MISSING_FEATURES.md wurden bearbeitet

## Footer-Format

```html
---

<!-- Footer -->
<div style="text-align: center; font-size: 0.8em; color: #666; margin-top: 2em;">
  <p style="margin:0;">Dateititel (projektname)</p>
  <p style="margin:0; font-size: 0.9em;">© YYYY <a href="https://joerg-walkowiak.de/" style="color: inherit; text-decoration: none;">Joerg Walkowiak</a>. Alle Rechte vorbehalten. | Stand: DD.MM.YYYY</p>
</div>
```

## Parameter

| Parameter | Typ     | Pflicht | Standard | Beschreibung |
|-----------|---------|---------|----------|-------------|
| `-Path`   | string  | Nein    | `.`      | Pfad zu einer einzelnen `.md`-Datei oder einem Verzeichnis (alle `.md`-Dateien im Verzeichnis werden verarbeitet, nicht rekursiv) |
| `-Force`  | switch  | Nein    | `false`  | Wenn gesetzt, wird ein vorhandener Footer aktualisiert. Ohne `-Force` werden Dateien mit bestehendem Footer uebersprungen. |

## Verwendung

### Einzelne Datei verarbeiten (Footer hinzufuegen)

```powershell
.\.github\skills\add-md-footer\add-md-footer.ps1 -Path "README.md"
```

### Einzelne Datei mit vorhandenem Footer aktualisieren

```powershell
.\.github\skills\add-md-footer\add-md-footer.ps1 -Path "CHANGELOG.md" -Force
```

### Alle Markdown-Dateien im Projekt-Root verarbeiten

```powershell
.\.github\skills\add-md-footer\add-md-footer.ps1 -Path "."
```

### Alle Markdown-Dateien im Projekt-Root aktualisieren (erzwingt Datum-Update)

```powershell
.\.github\skills\add-md-footer\add-md-footer.ps1 -Path "." -Force
```

## Workflow

1. Pruefen ob eine oder mehrere Dateien verarbeitet werden sollen.
2. Projektnamen aus dem Git-Repository-Namen ermitteln (Fallback: Verzeichnisname).
3. Ersten H1-Titel (`# Titel`) aus der Markdown-Datei lesen (Fallback: Dateiname ohne Endung).
4. Footer-Block erzeugen mit Titel, Projektname, Jahr und aktuellem Datum.
5. Falls Footer vorhanden und `-Force` nicht gesetzt: Datei ueberspringen.
6. Falls Footer vorhanden und `-Force` gesetzt: bestehenden Footer-Block entfernen und neu setzen.
7. Datei in UTF-8 (mit BOM fuer PS 5.1-Kompatibilitaet) zurueckschreiben.
8. Ergebnis: Anzahl verarbeiteter und uebersprungener Dateien.

## Ausgabe (Konsole)

```
Verarbeite 3 Markdown-Datei(en) in: C:\repo
  [ADDED]    README.md
  [UPDATED]  CHANGELOG.md
  [SKIP]     MISSING_FEATURES.md

Fertig: 2 verarbeitet, 1 uebersprungen.
```

## Hinweise

- Das Skript verarbeitet nur Dateien im angegebenen Verzeichnis, **nicht rekursiv** in Unterordnern.
- Der Projektnamen wird automatisch aus `git rev-parse --show-toplevel` abgeleitet.
- Vorhandene Footer werden anhand des HTML-Kommentars `<!-- Footer -->` erkannt.
- Die Datei wird immer als UTF-8 mit BOM gespeichert, damit PowerShell 5.1 sie korrekt liest.
- Umlaute und Sonderzeichen in Titeln werden unveraendert uebernommen.

## Verwandte Skills

- `jw-design` - JW Design System Richtlinien
- `ki-club-adaptive-theming` - Theme-System fuer Syncfusion Blazor