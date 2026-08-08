---
description: 'Copilot-Anweisungen für komponentenbasierte statische Webentwicklung mit Blazor/MAUI-Migration'
applyTo: '**/*.html, **/*.js, **/*.css'
---

## Projektüberblick

Dieses Template dient der **MVP-first Entwicklung** einer statischen Website mit **komponentenbasierter Architektur**, die nahtlos zu **Blazor (hybrid)**, **React** oder **.NET MAUI** migriert werden kann.

**Primäres Ziel:** Schnellstmögliche Entwicklung eines MVP → vollständige Website → Blazor/MAUI-Anwendung || React-App

**Architektur-Philosophie:**
- **Atomic Components**: Jede Funktionalität wird als eigenständige, isolierte Komponente entwickelt
- **Selbstständige Module**: Jede Komponente enthält HTML, CSS und JavaScript in abgeschlossenen Modulen
- **Blazor-Ready**: Struktur und Patterns sind für .razor-Komponenten optimiert
- **Zero-Breaking Migration**: Komponenten können 1:1 zu Blazor- bzw. React-Komponenten konvertiert werden

**Website-Anforderungen:**
- Responsiv (Desktop/Tablet/Mobile)
- Vollständige Touch/Maus/Tastatur-Bedienung  
- Light/Dark-Mode Support
- Performance-optimiert für MVP-Geschwindigkeit

## Komponentenarchitektur (Kern-Kontrakt)

### Dateistruktur pro Komponente
```
src/components/
├── [component-name]/
│   ├── [component-name].html     # Template mit {{prop}} Platzhaltern
│   ├── [component-name].css      # Scoped Styles (CSS-Module Pattern)
│   └── [component-name].js       # Komponentenlogik + Event-Handler
└── shared/                       # Wiederverwendbare Styles/Utils
    ├── variables.css             # CSS Custom Properties (Theme-Tokens)
    ├── utilities.css             # Utility Classes
    └── base.css                  # Reset + Grundstyles
appsettings.json                  # Secrets/Config (gitignored, .NET-konform)
appsettings.example.json          # Vorlage ohne echte Werte (eingecheckt)
vendor/                           # Lokal heruntergeladene Drittanbieter-Assets (Fonts, Icons, CSS)
```

### Komponenten-Konventionen

**HTML-Template (`[component].html`):**
- **`{{prop}}` ist Pflicht** für jeden dynamischen Wert (Texte, URLs, Delays, Sichtbarkeit). Statische Inhalte dürfen hartkodiert sein, aber alle Werte, die später ein `[Parameter]` werden sollen, MÜSSEN als `{{prop}}` stehen — sonst ist die Blazor-Conversion kein 1:1-Mapping.
- **`data-component` nur EINMAL:** Entweder im Host-Element in `index.html` ODER im Root-Element des Templates — niemals beide. Empfehlung: `data-component` nur im Host (`index.html`); das Template-Root trägt nur die Klasse `.component-[name]`. Doppelte `data-component`-Attribute erzeugen verschachtelte Selektoren und Landmark-Konflikte.
- Einzelnes Root-Element mit der Klasse `.component-[name]`
- Semantische HTML-Struktur (Header, Main, Section, etc.)
- ARIA-Attribute für Accessibility

**CSS-Module (`[component].css`):**
- Scoped über `.component-[name]` Präfix
- **Alle Farben/Typografie/Abstände über CSS Custom Properties** (zentrale Tokens in `shared/variables.css`); keine hartkodierten Farbwerte wie `#e82e1e` im Komponenten-CSS. Komponenten-CSS referenziert nur `var(--…)`.
- **Theme-Awareness Pflicht:** Styles müssen unter `:root[data-theme="dark"]` und `:root[data-theme="light"]` funktionieren (Kontrast WCAG AA).
- **Mobile-First Media Queries Pflicht:** Jede Komponente muss mindestens eine `@media (min-width: …)`-Regel für Tablet/Desktop enthalten.
- BEM-Methodologie für Klassen-Namen

**JavaScript-Module (`[component].js`):**
- ES6-Module Export: `export class ComponentName {}`
- Lifecycle-Methoden: `init(element, props)`, `destroy()`, `update(props)`
  - `init(element, props)` speichert `this.element` und `this.props` und rendert den Initialzustand.
  - `update(props)` wird von `main.js` nach `init` sowie bei Prop-Änderungen aufgerufen und aktualisiert DOM/State (Mapping → Blazor Component State).
- **Event-Handler als benannte Klassen-Methoden** (keine Arrow-Functions direkt in `onclick = (e) => …`). Beispiel: `this.submitButton.onclick = (e) => this.handleSubmit(e);` mit `handleSubmit(e) { … }`.
- **Custom Events dispatchen** für nachgelagerte Logik: `this.element.dispatchEvent(new CustomEvent('subscribe', { detail: …, bubbles: true }))` → mappt 1:1 auf Blazor `EventCallback<T>`.
- **Keine `innerHTML`-Zuweisung mit fremden Daten** (siehe Sicherheit). Nutze `textContent` oder DOMPurify.
- Keine globalen Variablen

### Shell-Integration
- Host-Elemente nutzen `data-component="[name]"` + `data-*` für Props
- `src/main.js` lädt Komponenten aus `COMPONENTS_PATH = 'src/components'`
- Automatisches CSS/JS-Loading pro Komponente
- **`main.js` MUSS nach `init(element, props)` zwingend `instance.update(props)` aufrufen**, damit der `update(props)`-Vertrag erfüllt ist.
- **Props-Validation:** `readProps()` validiert gegen ein optionales Schema pro Komponente (Typ/Required). Ungültige Props → `console.warn` + Fallback-Default, kein Crash.
- **Template-Loading nur aus lokaler, vertrauenswürdiger Quelle** (`fetch` aus `COMPONENTS_PATH`); niemals fremde/Remote-Templates per `innerHTML` einfügen.
- **Config laden:** `main.js` lädt `appsettings.json` per `fetch` und reicht Werte als Props an Komponenten durch.

### Sicherheit
- **Kritisch:** Alle `data-*` Werte sind untrusted
- **Niemals:** Direktes `innerHTML` ohne Sanitization
- **Verwende:** DOMPurify für HTML-Content oder `textContent`
- **Secrets (API-Keys, Tokens, AJAX-Security) NIE in `.js`-Dateien hartkodieren.** Alle Secrets/Config-Werte gehören in `appsettings.json` (gitignored). Eine `appsettings.example.json` ohne echte Werte ist eingecheckt und dient als Vorlage (`cp appsettings.example.json appsettings.json`). `main.js` lädt `appsettings.json` und reicht Werte als Props durch.
  - **Hinweis zur Client-Sichtbarkeit:** Werte, die im Browser zwingend gebraucht werden (z. B. Unsplash `Client-ID`), sind clientseitig prinzipbedingt im Netzwerk-Tab sichtbar. Das ist akzeptabel für Public-APIs. Echte Backend-Secrets (z. B. WordPress-`security`-Token für `admin-ajax.php`) dürfen NICHT clientseitig stehen — diese gehören später hinter einen eigenen Server-Endpoint (Proxy), der in der Blazor-App als API-Kontroller realisiert wird.
- **`innerHTML` mit Server-Payloads verboten:** Antworten wie `data.message` MÜSSEN via `textContent` oder (bei HTML) DOMPurify gesetzt werden. Rohes `resultElement.innerHTML = data.message` ist ein XSS-Risiko und untersagt.
- **Keine Remote-Templates:** `main.js` fügt nur lokal geladene Templates per `innerHTML` ein, niemals Remote-HTML.

## Blazor/MAUI-Migration Guidelines

### Komponentenbasierte Entwicklung für .razor-Konvertierung

**Aktuelle Struktur → Blazor Mapping:**
```
[component].html     → [Component].razor (HTML Section)
[component].css      → [Component].razor.css (Scoped Styles)  
[component].js       → [Component].razor.cs (Code-Behind)
```

**Blazor-Ready Patterns:**
- **Props**: `{{prop}}` im Template + `data-*` Attribute → `[Parameter]` Properties
- **Events**: Custom Events (`dispatchEvent(new CustomEvent(...))`) → `EventCallback<T>`
- **State**: `this.props` + `update(props)` → Component State / `[Parameter]`-gebundener State
- **Lifecycle**: `init()/destroy()` → `OnInitialized()/Dispose()`; `update(props)` → `OnParametersSet()`
- **Config**: `appsettings.json` → .NET `appsettings.json` + `IConfiguration` (1:1 Mapping, kein Refactoring nötig)

### Entwicklungsrichtlinien für Migration

**HTML-Template (→ .razor):**
```html
<!-- Aktuell: component.html -->
<div class="component-card" data-component="card">
  <h3>{{title}}</h3>
  <p>{{content}}</p>
  <button data-action="{{action}}">{{buttonText}}</button>
</div>

<!-- Blazor-Ziel: Card.razor -->
<div class="component-card">
  <h3>@Title</h3>
  <p>@Content</p>
  <button @onclick="HandleClick">@ButtonText</button>
</div>
```

**CSS-Scoping (→ .razor.css):**
```css
/* Aktuell: component.css */
.component-card {
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius);
}

/* Blazor-Ziel: Card.razor.css (automatisch scoped) */
.component-card {
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius);
}
```

**JavaScript-Logic (→ .razor.cs):**
```javascript
// Aktuell: component.js
export class Card {
  init(element, props) {
    this.element = element;
    this.props = props;
  }
  
  handleClick() {
    // Event logic
  }
}

// Blazor-Ziel: Card.razor.cs
public partial class Card : ComponentBase
{
  [Parameter] public string Title { get; set; }
  [Parameter] public string Content { get; set; }
  [Parameter] public EventCallback OnClick { get; set; }
  
  private async Task HandleClick()
  {
    await OnClick.InvokeAsync();
  }
}
```

### Wichtige Patterns & Konventionen

- **Semantisches HTML**: Nutze sinnvolle Tags, Landmark-Roles und Labels.
- **Responsives Design**:
  - Mobile-First, flüssige Layouts, CSS Grid/Flexbox.
  - Media Queries für Telefon/Tablet/Desktop-Breakpoints.
  - Bilder/Medien responsiv bereitstellen.
- **Bedienung (Touch/Maus/Tastatur)**:
  - Sichtbarer Fokuszustand, sinnvolle Tab-Reihenfolge.
  - Tastatursteuerung (Enter/Space, Pfeiltasten bei Widgets).
  - Touch-Ziele ausreichend groß; Pointer- und Keyboard-Events berücksichtigen.
- **Accessibility (A11y)**:
  - ARIA nur ergänzend, wenn Semantik nicht ausreicht.
  - Kontraste, Alternativtexte, sinnvolle Link-/Button-Beschriftungen.
- **Theme (Light/Dark)**:
  - Umschaltung per Button; Zustand in `localStorage` speichern.
  - Systempräferenz `prefers-color-scheme` respektieren.
  - Farben über CSS-Variablen definieren.
  - **Pflicht:** Jede Komponente muss unter `:root[data-theme="dark"]` und `:root[data-theme="light"]` lesbare Kontraste (WCAG AA) bieten. Reines Dark-Design ohne Light-Variante ist nicht zulässig.

### Entwickler-Workflows

- **Starten/Testen**: `index.html` direkt im Browser öffnen; optional
  statischen Server verwenden (z. B. wegen CORS).
- **Responsiveness prüfen**: DevTools Device-Emulation für gängige Viewports.
- **Accessibility prüfen**: Tastaturbedienung, Screenreader, Kontrast-Checks.

### Beispiele

- Theme-Umschaltung (JS):
```js
const root = document.documentElement;
const themeToggle = document.getElementById('theme-toggle');

function applyTheme(t) {
  root.setAttribute('data-theme', t);
  localStorage.setItem('theme', t);
}

applyTheme(localStorage.getItem('theme') ||
           (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'));

themeToggle?.addEventListener('click', () => {
  const next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
  applyTheme(next);
});
```

- Theme-Variablen (CSS):
```css
:root {
  --bg: #ffffff;
  --fg: #111111;
  --accent: #2563eb;
}

:root[data-theme="dark"] {
  --bg: #0b0f14;
  --fg: #e5e7eb;
  --accent: #60a5fa;
}

html, body { background: var(--bg); color: var(--fg); }
```

- Grundstruktur (HTML):
```html
<header>
  <nav aria-label="Hauptnavigation">
    <!-- Links -->
  </nav>
</header>
<main id="content" tabindex="-1">
  <!-- Seiteninhalt -->
</main>
<footer>
  <!-- Footer -->
</footer>
```

### Hinweise

- Theme in `localStorage`
- Performance und Zugänglichkeit priorisieren (Lazy-Loading, reduzierte Motion
  respektieren, sinnvolle Landmark-Struktur).
- Änderungen stets gegen Responsiveness, Tastatur-/Touch-Bedienung und
  Kontrast prüfen

## Sicherheits‑Kernregeln (1‑Satz jeweils)

- Alle `data-*` Werte als untrusted behandeln; keine direkte `innerHTML`‑Zuweisung ohne Sanitizer.
- Keine Secrets in `.js`-Dateien, `package.json` oder Skripten; nutze `appsettings.json` (gitignored) bzw. später .NET `IConfiguration` / GitHub Secrets.
- Server-Payloads niemals roh per `innerHTML` setzen — `textContent` oder DOMPurify verwenden.
- Fehler‑Logs in Issues nur mit sensiblen Daten redacted.

## Externe Ressourcen (Lokalitäts‑Regel)

**Grundsatz: Alles lokal.** Die Website darf zur Laufzeit keine Drittanbieter-CDNs (cdnjs, Google Fonts, WordPress-Plugin-CSS, Unsplash-CDN) referenzieren.

- **Herunterladen & selbst ausliefern:** Benötigte Dateien (Fonts, Icon-Sets wie Font Awesome, CSS-Frameworks, Hintergrundbilder) werden einmalig nach `vendor/` geladen und vom eigenen Server ausgeliefert.
- **Fonts:** Google Fonts werden lokal als `woff2` in `vendor/fonts/` abgelegt und per `@font-face` eingebunden (kein `<link>` zu fonts.googleapis.com).
- **Icons:** Font Awesome (oder ein schlankeres Icon-Set) wird lokal nach `vendor/icons/` kopiert, nicht per cdnjs geladen.
- **Hintergrundbilder:** Unsplash-Bilder werden heruntergeladen und nach `vendor/images/` gelegt; die Unsplash-Download-API wird nicht clientseitig aufgerufen.
- **WordPress-Abhängigkeiten entfernen:** Das Newsletter-Formular darf kein WordPress-Plugin-CSS und keine `wp-admin/admin-ajax.php`-Calls mehr machen. Stattdessen: lokaler Proxy-Endpoint (später Blazor-API) oder `appsettings.json`-konfigurierter Endpoint.
- **Begründung:** Vermeidet Third-Party-Tracking, DSGVO-Risiken, Offline-Ausfälle und macht die Seite für die Blazor-Migration vollständig self-contained.

## Konkrete Grenzen (was nicht geändert werden darf ohne PR‑Note)

- Keine Breaking‑Änderungen an `index.html` Shell API ohne RFC/PR und Migrationshinweis.
- Wenn die Template‑Syntax (`{{...}}`) geändert wird, ergänze `src/main.js` in derselben PR und dokumentiere die Migration.

## Quick troubleshooting checklist

- Keine Seite? Läuft `npm run start`? Wenn nein: `npm install` → prüfe Errors.
- Komponenten laden nicht? Existiert `src/components/<name>.html`? Ist `COMPONENTS_PATH` relativ?
- XSS‑Risiko? Wird `innerHTML` verwendet? Wenn ja, warum?

## Befugnisse

- Erstelle Issues, Branches und PRs. Kleine Komponenten/Docs dürfen per PR hinzugefügt werden. Shell‑API Änderungen nur mit Review.

---




