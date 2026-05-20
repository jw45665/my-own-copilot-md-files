---
name: jw-adaptive-theming-factory
description: 'Unified adaptive theming skill for web applications with Light/Dark mode, system preference support, persistence, reusable theme palettes, and Syncfusion-aware or framework-agnostic theme switching. Use when a project needs a theme switcher, prefers-color-scheme support, CSS variable theming, Bootstrap/Bootswatch-style adaptation, or a single theming strategy that works with and without Syncfusion.'
---

# jw-adaptive-theming-factory

`jw-adaptive-theming-factory` ist der zentrale Skill für adaptive Theme-Systeme in Webanwendungen. Er dient als eigenständige Anleitung für Projekte mit und ohne Syncfusion und beschreibt sowohl globale Theme-Umschaltung als auch wiederverwendbare Theme-Paletten.

## Wann dieser Skill verwendet werden soll

Verwende diesen Skill, wenn ein Projekt:

- einen Theme-Switcher benötigt
- Light- und Dark-Mode unterstützen soll
- die Systemeinstellung des Nutzers übernehmen soll
- das aktuelle Theme im Browser speichern und wiederherstellen soll
- mehrere vordefinierte Theme-Paletten nutzen soll
- Syncfusion-Komponenten automatisch mit umschalten soll
- ohne Syncfusion trotzdem sauber thematisiert werden soll
- CSS-Variablen, Bootstrap-ähnliche Themes oder eigenständige Farbpaletten verwendet

## Grundprinzip

Der Skill folgt einer klaren Priorität:

1. **Syncfusion vorhanden**
   - globale Theme-Dateien bevorzugen
   - Theme-Link-Umschaltung und `data-bs-theme` verwenden
   - Ziel: alle Syncfusion-Komponenten sollen automatisch korrekt umschalten

2. **Kein Syncfusion vorhanden**
   - CSS Custom Properties und semantische Theme-Tokens verwenden
   - Light/Dark-Mode über ein globales Theme-Attribut und Systemerkennung umsetzen
   - Theme-Zustand im Browser speichern und wiederherstellen

3. **Hybride Projekte**
   - generische Tokens und komponentenspezifische Styles trennen
   - externe Theme-Dateien nur dort verwenden, wo sie Mehrwert liefern
   - System-Theme als Fallback und Startpunkt behandeln

## Unterstützte Modi

### 1. Light/Dark-Modus

- manueller Wechsel zwischen Hell und Dunkel
- saubere visuelle Umschaltung auf globaler Ebene
- konsistente Hintergrund-, Text-, Border- und Akzentfarben

### 2. System-Theme-Übernahme

- Auslesen von `prefers-color-scheme`
- Verwendung der Systempräferenz als Standard, wenn noch kein gespeichertes Theme existiert
- optionales Reagieren auf Änderungen der Systemeinstellung

### 3. Persistenz

- Speicherung der Nutzerwahl im Browser
- Wiederherstellung beim nächsten Laden der Anwendung
- Fallback-Verhalten, falls Browser-Speicher nicht verfügbar ist

## Mitgelieferte Theme-Paletten

Die folgenden Theme-Dateien liegen im Verzeichnis `themes/` und bleiben in Namen und Farben unverändert:

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

## Empfohlene Implementierungsreihenfolge

1. Erkennen, ob das Projekt Syncfusion nutzt
2. Den kleinsten passenden globalen Theme-Mechanismus wählen
3. Eine zentrale Theme-Quelle definieren
4. Light/Dark/System-Logik ergänzen
5. Nutzerwahl persistieren
6. Theme-Switcher in die Hauptnavigation oder den App-Header integrieren
7. Theme-Dateien oder CSS-Variablen konsistent dokumentieren

## Best Practices

- Verwende semantische Namen für Farben und Tokens
- Halte den UI-Zustand unabhängig von der Theme-Quelle
- Vermeide hartkodierte Farben in Komponenten, wenn Theme-Tokens möglich sind
- Sorge für ausreichenden Kontrast und gute Lesbarkeit
- Nutze bei Syncfusion die Theme-Datei-Umschaltung statt nur lokaler Overrides, wenn ein globaler Wechsel gewünscht ist
- Fallbacks immer so gestalten, dass die Anwendung auch ohne JS oder Browser-Speicher lesbar bleibt

## Empfohlene Theme-Struktur

- `themes/` für wiederverwendbare Theme-Paletten
- `README.md` für Verzeichniszweck, Einsatzgrenzen und Integrationshinweise
- `SKILL.md` für die eigentliche Anleitung und Entscheidungslogik

## Typische Ergebnisse

Nach Anwendung dieses Skills sollte ein Projekt:

- einen klaren Theme-Switcher besitzen
- automatisch zwischen Light, Dark und Systemmodus wechseln können
- optional globale Theme-Dateien für Syncfusion umschalten
- wiederverwendbare und dokumentierte Farbpaletten enthalten
- sowohl für Syncfusion- als auch für Nicht-Syncfusion-Projekte nutzbar sein

## Hinweise zur Verwendung

Dieser Skill ist technologie-neutral formuliert und ersetzt die bisherigen getrennten Theming-Ansätze. Er legt eine priorisierte, aber framework-agnostische Vorgehensweise fest und bleibt mit Syncfusion-Projekten ebenso kompatibel wie mit Projekten ohne Syncfusion.

---

## 📊 Verwendungshinweise

### Kontrast-Prüfung

Teste alle Themes mit:
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Accessible Colors](https://accessible-colors.com/)

**Mindest-Anforderungen (WCAG AA):**
- Normaler Text: 4.5:1
- Großer Text (18pt+): 3:1
- UI-Komponenten: 3:1

### Theme-Auswahl Checkliste

- [ ] Passt zur Markenidentität
- [ ] Ausreichender Kontrast (WCAG AA minimum)
- [ ] Konsistente Farbtemperatur (warm/kalt)
- [ ] Funktioniert in Light und Dark Variants
- [ ] Alle Variablen definiert
- [ ] Auf verschiedenen Displays getestet

### Quick Copy Template

```css
[data-theme="YOUR-THEME-NAME"] {
  --bg-primary: #______;
  --bg-secondary: #______;
  --bg-accent: #______;
  --text-primary: #______;
  --text-secondary: #______;
  --accent-color: #______;
  --navbar-bg: #______;
  --navbar-text: #______;
  --header-text: #______;
  --border-color: #______;
}
```

---

**Tipp:** Verwende Tools wie [Coolors](https://coolors.co/) oder [Adobe Color](https://color.adobe.com/) zum Erstellen eigener Paletten!
