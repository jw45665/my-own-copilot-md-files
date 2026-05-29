---
name: jw-adaptive-theming-factory
displayName: JW Adaptive Theming Factory
description: Zentrales Skillverzeichnis für adaptive Themes in Webanwendungen.
version: 1.0.0
author: JW
---

# jw-adaptive-theming-factory

`jw-adaptive-theming-factory` ist das zentrale Skillverzeichnis für adaptive Themes in Webanwendungen. Es stellt eine einheitliche Theming-Grundlage bereit, die sowohl mit Syncfusion als auch ohne Syncfusion genutzt werden kann.

## Was der Skill leistet

Der Skill unterstützt beim Entwerfen und Implementieren von:

- globalen Light-/Dark-Mode-Konzepten
- System-Theme-Übernahme über `prefers-color-scheme`
- Theme-Persistenz im Browser
- CSS-Variablen-basierten Designsystemen
- Syncfusion-kompatibler Theme-Umschaltung über Theme-Links und `data-bs-theme`
- wiederverwendbaren Theme-Paletten mit unveränderten Namen und Farben
- konsistenter Theming-Logik für Projekte mit und ohne Syncfusion

## Wann der Skill verwendet werden soll

Verwende diesen Skill, wenn ein Projekt:

- einen Theme-Switcher benötigt
- Light- und Dark-Mode unterstützen soll
- die Systemeinstellung des Nutzers automatisch übernehmen soll
- das aktuelle Theme im Browser speichern und wiederherstellen soll
- mehrere konsistente Theme-Paletten bereitstellen soll
- eine zentrale, wiederverwendbare Theming-Struktur benötigt
- Syncfusion-Komponenten global mit umschalten soll
- ohne Syncfusion trotzdem sauber thematisiert werden soll

## Prioritätsregeln

1. **Syncfusion vorhanden**
   - globale Theme-Dateien bevorzugen
   - Theme-Link-Umschaltung und `data-bs-theme` verwenden
   - Ziel ist, dass Syncfusion-Komponenten automatisch mit umschalten

2. **Kein Syncfusion vorhanden**
   - CSS-Variablen und semantische Theme-Tokens verwenden
   - Light/Dark/System-Mode auf Basis von `prefers-color-scheme` umsetzen
   - Theme-State im Browser speichern und wiederherstellen

3. **Beide Welten relevant**
   - generische Tokens und komponentenspezifische Anpassungen getrennt halten
   - Theme-Dateien nur dort verwenden, wo sie Mehrwert liefern

## Enthaltene Themes

Die folgenden Theme-Paletten sind im Verzeichnis `themes/` enthalten und werden unverändert verwendet:

- `ki-club-default.md`
- `light.md`
- `dark.md`
- `red.md`
- `professional-blue.md`
- `corporate-gray.md`
- `executive-purple.md`
- `forest-green.md`
- `ocean-blue.md`
- `earth-brown.md`
- `warm-sunset.md`
- `fiery-orange.md`
- `arctic-frost.md`
- `mint-fresh.md`
- `rose-pink.md`
- `lavender-dream.md`
- `deep-space.md`
- `midnight-blue.md`
- `charcoal.md`
- `high-contrast.md`
- `sepia-reader.md`

## Verzeichnisstruktur

```text
jw-adaptive-theming-factory/
├── README.md
├── SKILL.md
└── themes/
    ├── ki-default.md
    ├── light.md
    ├── dark.md
    ├── red.md
    ├── professional-blue.md
    ├── corporate-gray.md
    ├── executive-purple.md
    ├── forest.md
    ├── ocean.md
    ├── earth.md
    ├── sunset.md
    ├── fiery-orange.md
    ├── arctic.md
    ├── mint.md
    ├── rose.md
    ├── lavender.md
    ├── deep-space.md
    ├── midnight.md
    ├── charcoal.md
    ├── high-contrast.md
    └── sepia.md
```

## Ergebnis des Skills

Der Skill soll dabei helfen, ein sauberes, wartbares und zugängliches Theme-System zu entwerfen. Die Empfehlung ist immer:

- zuerst die vorhandene UI-Technologie erkennen
- dann den kleinsten passenden Theming-Mechanismus wählen
- abschließend einen Switcher mit Persistenz und System-Fallback ergänzen
