---
name: jw-design
description: Implementiert das JW-Design-System – ein framework-agnostisches, Fluent2-inspiriertes Design-System mit CSS-Variablen-basiertem Theme-Switching, vordefinierten Farbpaletten (KI-Club, Professional Blue, Forest Green, Warm Sunset u.a.), Top-Navigation-Layout und Mobile-First Responsive Design. Verwende diesen Skill, wenn ein modernes professionelles Design-System, Custom-Themes, ein Theme-Switcher, Top-Navigation ohne Sidebar oder ein WCAG 2.1 AA-konformes responsives Layout implementiert werden soll.
---

# JW-Design Skill

**Framework-agnostisches Design-System mit Fluent2-inspirierter Ästhetik und benutzerdefinierten Farbpaletten**

## Wann diesen Skill nutzen?

Verwende diesen Skill wenn:
- Ein modernes, professionelles Design-System implementiert werden soll
- Theme-Switching mit mehreren vordefinierten Farbpaletten benötigt wird
- Ein Top-Navigation-Layout ohne Sidebar gewünscht ist
- Responsive, accessibility-fokussierte UI erstellt werden soll
- CSS-Variablen-basiertes Theme-System benötigt wird
- Mobile-First responsive Design erforderlich ist

**Trigger-Begriffe**: "JW-Design", "modernes Layout", "Custom-Themes", "Farbpaletten", "Theme-Switcher", "Top-Navigation", "responsive Design-System"

## Design-Philosophie

Das JW-Design folgt diesen Kernprinzipien:

1. **Fluent2-Inspiration**: Moderne Microsoft-Design-Sprache als Basis
2. **CSS-Variablen-basiert**: Themes via CSS Custom Properties
3. **Mobile-First**: Optimiert für alle Bildschirmgrößen
4. **Accessibility**: WCAG 2.1 AA-konform
5. **Performance**: Sanfte Transitions ohne Layout-Shifts
6. **Theme-Persistenz**: LocalStorage-basierte Speicherung

## Layout-Struktur

### Komponenten-Hierarchie
```
MainLayout
├── TopNavigation (mit Theme-Switcher)
├── Main Content
└── Footer
```

### Flexbox-Layout Pattern
```css
.jw-layout {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
}

.jw-main-content {
    flex: 1;
    padding: var(--jw-spacing-lg);
}
```

## Farbpaletten

### 1. Default Light & Dark
Standard helle und dunkle Modi

### 2. KI-Club Light
**Primärfarbe**: `#0066cc` (Business Blue)  
**Einsatz**: Professionelle Business-Anwendungen

### 3. KI-Club Dark
**Primärfarbe**: `#3385d6` (Lighter Blue)  
**Hintergrund**: `#1a1a1a` (Near Black)  
**Einsatz**: Dunkler Modus für Entwickler-Tools

### 4. KI-Club RWB (Red-White-Blue)
**Primärfarbe**: `#dc143c` (Crimson Red)  
**Akzent**: `#ffffff` (White)  
**Sekundär**: `#0052a3` (Navy Blue)  
**Einsatz**: Patriotische/Festliche Themes, KI-Club-Branding

### 5. Professional Blue
**Primärfarbe**: `#0078d4` (Microsoft Blue)  
**Einsatz**: Enterprise-Anwendungen, Corporate Design

### 6. Forest Green
**Primärfarbe**: `#2d7d46` (Deep Forest Green)  
**Einsatz**: Umwelt-Apps, Nachhaltigkeits-Plattformen

### 7. Warm Sunset
**Primärfarbe**: `#d97706` (Amber Orange)  
**Einsatz**: Kreative Apps, Lifestyle-Plattformen

## CSS-Variablen-Schema

```css
:root {
    /* Farben */
    --jw-primary: #0066cc;
    --jw-primary-dark: #0052a3;
    --jw-primary-light: #3385d6;
    --jw-surface: #ffffff;
    --jw-surface-variant: #f5f5f5;
    --jw-on-surface: #1a1a1a;
    --jw-border: #e0e0e0;

    /* Spacing */
    --jw-spacing-xs: 0.5rem;
    --jw-spacing-sm: 1rem;
    --jw-spacing-md: 1.5rem;
    --jw-spacing-lg: 2rem;
    --jw-spacing-xl: 3rem;
    --jw-spacing-section: 4rem;

    /* Layout */
    --jw-container-max-width: 1200px;
    --jw-border-radius: 0.5rem;
    --jw-transition-speed: 0.3s;
}
```

## Theme-Switcher Implementation

### HTML Structure
```html
<select id="theme-selector" aria-label="Theme auswählen">
    <option value="default">Default Light</option>
    <option value="default-dark">Default Dark</option>
    <option value="ki-club-light">KI-Club Light</option>
    <option value="ki-club-dark">KI-Club Dark</option>
    <option value="ki-club">KI-Club RWB</option>
    <option value="professional-blue">Professional Blue</option>
    <option value="forest-green">Forest Green</option>
    <option value="warm-sunset">Warm Sunset</option>
</select>
```

### JavaScript Theme-Manager
```javascript
window.jwThemeManager = (() => {
    const STORAGE_KEY = 'jw-selected-theme';

    const themes = {
        'default': { dataTheme: 'default' },
        'default-dark': { dataTheme: 'default-dark' },
        'ki-club-light': { dataTheme: 'ki-club-light' },
        'ki-club-dark': { dataTheme: 'ki-club-dark' },
        'ki-club': { dataTheme: 'ki-club' },
        'professional-blue': { dataTheme: 'professional-blue' },
        'forest-green': { dataTheme: 'forest-green' },
        'warm-sunset': { dataTheme: 'warm-sunset' }
    };

    const applyTheme = (themeKey) => {
        const theme = themes[themeKey] || themes.default;
        document.body.setAttribute('data-theme', theme.dataTheme);

        try {
            localStorage.setItem(STORAGE_KEY, themeKey);
        } catch (e) {
            console.warn('LocalStorage not available');
        }

        return themeKey;
    };

    const initializeTheme = () => {
        let themeKey = 'default';

        try {
            const savedTheme = localStorage.getItem(STORAGE_KEY);
            if (savedTheme && themes[savedTheme]) {
                themeKey = savedTheme;
            }
        } catch (e) {
            console.warn('LocalStorage not available');
        }

        return applyTheme(themeKey);
    };

    const getCurrentTheme = () => {
        try {
            const savedTheme = localStorage.getItem(STORAGE_KEY);
            return savedTheme && themes[savedTheme] ? savedTheme : 'default';
        } catch (e) {
            return 'default';
        }
    };

    return { applyTheme, initializeTheme, getCurrentTheme };
})();

// Auto-initialize on load
document.addEventListener('DOMContentLoaded', () => {
    jwThemeManager.initializeTheme();
});
```

### CSS Theme Definitions
```css
/* Default Light */
[data-theme="default"] {
    --jw-primary: #0066cc;
    --jw-surface: #ffffff;
    --jw-on-surface: #1a1a1a;
    --jw-border: #e0e0e0;
}

/* Default Dark */
[data-theme="default-dark"] {
    --jw-primary: #3385d6;
    --jw-surface: #1a1a1a;
    --jw-on-surface: #e8e8e8;
    --jw-border: #404040;
}

/* KI-Club Light */
[data-theme="ki-club-light"] {
    --jw-primary: #0066cc;
    --jw-primary-dark: #0052a3;
    --jw-primary-light: #3385d6;
    --jw-surface: #ffffff;
    --jw-surface-variant: #f5f5f5;
    --jw-on-surface: #1a1a1a;
    --jw-border: #e0e0e0;
}

/* KI-Club Dark */
[data-theme="ki-club-dark"] {
    --jw-primary: #3385d6;
    --jw-primary-dark: #5ca3e0;
    --jw-primary-light: #1a73c9;
    --jw-surface: #1a1a1a;
    --jw-surface-variant: #2a2a2a;
    --jw-on-surface: #e8e8e8;
    --jw-border: #404040;
}

/* KI-Club RWB */
[data-theme="ki-club"] {
    --jw-primary: #dc143c;
    --jw-primary-dark: #b01030;
    --jw-primary-light: #e54761;
    --jw-accent: #ffffff;
    --jw-accent-dark: #0052a3;
    --jw-surface: #1a1a1a;
    --jw-surface-variant: #2a2a2a;
    --jw-on-surface: #e8e8e8;
    --jw-border: #404040;
}

/* Professional Blue */
[data-theme="professional-blue"] {
    --jw-primary: #0078d4;
    --jw-primary-dark: #005a9e;
    --jw-primary-light: #2b88d8;
    --jw-surface: #fafafa;
    --jw-surface-variant: #f0f0f0;
    --jw-on-surface: #323130;
    --jw-border: #d2d2d2;
}

/* Forest Green */
[data-theme="forest-green"] {
    --jw-primary: #2d7d46;
    --jw-primary-dark: #1f5732;
    --jw-primary-light: #48a35f;
    --jw-surface: #f8faf9;
    --jw-surface-variant: #e8f0ea;
    --jw-on-surface: #1a2e1f;
    --jw-border: #c4d9cb;
}

/* Warm Sunset */
[data-theme="warm-sunset"] {
    --jw-primary: #d97706;
    --jw-primary-dark: #b45309;
    --jw-primary-light: #f59e0b;
    --jw-surface: #fffbf5;
    --jw-surface-variant: #fef3e2;
    --jw-on-surface: #292524;
    --jw-border: #e7d4bc;
}
```

## Navigation Pattern

### Top-Navigation mit Theme-Switcher
```html
<header class="jw-navbar">
    <div class="navbar-container">
        <div class="navbar-brand">
            <a href="/">App Name</a>
        </div>
        <nav class="navbar-menu">
            <a href="/">Home</a>
            <a href="/features">Features</a>
            <a href="/about">About</a>
        </nav>
        <div class="navbar-theme">
            <select id="theme-selector" onchange="jwThemeManager.applyTheme(this.value)">
                <!-- Theme options -->
            </select>
        </div>
    </div>
</header>
```

### Navigation CSS
```css
.jw-navbar {
    background: var(--jw-primary);
    color: white;
    padding: var(--jw-spacing-sm) 0;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.navbar-container {
    max-width: var(--jw-container-max-width);
    margin: 0 auto;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 var(--jw-spacing-md);
}

.navbar-brand a {
    font-size: 1.5rem;
    font-weight: 600;
    color: white;
    text-decoration: none;
}

.navbar-menu {
    display: flex;
    gap: var(--jw-spacing-md);
}

.navbar-menu a {
    color: white;
    text-decoration: none;
    padding: 0.5rem 1rem;
    border-radius: var(--jw-border-radius);
    transition: background-color var(--jw-transition-speed);
}

.navbar-menu a:hover {
    background-color: rgba(255,255,255,0.1);
}

/* Mobile */
@media (max-width: 767px) {
    .navbar-menu {
        display: none; /* Implement hamburger menu */
    }
}
```

## Hero-Header Pattern

```html
<header class="jw-hero">
    <div class="container text-center">
        <h1 class="hero-title">Welcome to App Name</h1>
        <p class="hero-subtitle">Modern design system with custom themes</p>
        <button class="jw-button-primary">Get Started</button>
    </div>
</header>
```

```css
.jw-hero {
    background: linear-gradient(135deg, var(--jw-primary) 0%, var(--jw-primary-dark) 100%);
    color: white;
    padding: var(--jw-spacing-xl) var(--jw-spacing-md);
    text-align: center;
}

.hero-title {
    font-size: 3rem;
    font-weight: 700;
    margin-bottom: var(--jw-spacing-md);
}

.hero-subtitle {
    font-size: 1.25rem;
    opacity: 0.9;
    margin-bottom: var(--jw-spacing-lg);
}

@media (max-width: 767px) {
    .hero-title { font-size: 2rem; }
    .hero-subtitle { font-size: 1rem; }
}
```

## Card-Grid Pattern

```html
<section class="jw-section">
    <div class="container">
        <h2>Features</h2>
        <div class="jw-card-grid">
            <div class="jw-card">
                <h3>Feature 1</h3>
                <p>Description</p>
            </div>
            <div class="jw-card">
                <h3>Feature 2</h3>
                <p>Description</p>
            </div>
            <div class="jw-card">
                <h3>Feature 3</h3>
                <p>Description</p>
            </div>
        </div>
    </div>
</section>
```

```css
.jw-card-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: var(--jw-spacing-lg);
    margin-top: var(--jw-spacing-lg);
}

.jw-card {
    background: var(--jw-surface);
    border: 1px solid var(--jw-border);
    border-radius: var(--jw-border-radius);
    padding: var(--jw-spacing-lg);
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    transition: transform var(--jw-transition-speed), box-shadow var(--jw-transition-speed);
}

.jw-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 4px 16px rgba(0,0,0,0.1);
}

.jw-card h3 {
    color: var(--jw-primary);
    margin-bottom: var(--jw-spacing-sm);
}
```

## Footer Pattern

```html
<footer class="jw-footer">
    <div class="footer-container">
        <p>© 2025 App Name. All rights reserved.</p>
        <p>Powered by <a href="https://ki-club.online">KI-Club</a></p>
    </div>
</footer>
```

```css
.jw-footer {
    background: var(--jw-surface-variant);
    color: var(--jw-on-surface);
    padding: var(--jw-spacing-lg) 0;
    text-align: center;
    border-top: 1px solid var(--jw-border);
}

.footer-container {
    max-width: var(--jw-container-max-width);
    margin: 0 auto;
    padding: 0 var(--jw-spacing-md);
}

.jw-footer a {
    color: var(--jw-primary);
    text-decoration: none;
}

.jw-footer a:hover {
    text-decoration: underline;
}
```

## Responsive Breakpoints

```css
/* Mobile First Approach */

/* Small devices (phones, less than 768px) */
/* Default styles */

/* Medium devices (tablets, 768px and up) */
@media (min-width: 768px) {
    .container {
        max-width: 720px;
    }
}

/* Large devices (desktops, 1024px and up) */
@media (min-width: 1024px) {
    .container {
        max-width: 960px;
    }
}

/* Extra large devices (large desktops, 1440px and up) */
@media (min-width: 1440px) {
    .container {
        max-width: var(--jw-container-max-width);
    }
}
```

## Accessibility Guidelines

1. **Semantisches HTML**:
```html
<header>, <nav>, <main>, <section>, <footer>
```

2. **ARIA-Labels**:
```html
<button aria-label="Close menu">×</button>
<nav aria-label="Main navigation">
```

3. **Keyboard Navigation**:
```css
*:focus {
    outline: 2px solid var(--jw-primary);
    outline-offset: 2px;
}
```

4. **Kontrast-Ratio**: Mindestens 4.5:1 (WCAG AA)

5. **Screen-Reader Support**:
```html
<span class="sr-only">Screen reader only text</span>
```

```css
.sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0,0,0,0);
    white-space: nowrap;
    border: 0;
}
```

## Framework-Spezifische Anpassungen

### React
```jsx
import { useTheme } from './hooks/useTheme';

function ThemeSwitcher() {
    const { currentTheme, setTheme } = useTheme();

    return (
        <select value={currentTheme} onChange={(e) => setTheme(e.target.value)}>
            <option value="default">Default Light</option>
            {/* ... */}
        </select>
    );
}
```

### Vue
```vue
<template>
    <select v-model="currentTheme" @change="applyTheme">
        <option value="default">Default Light</option>
        <!-- ... -->
    </select>
</template>

<script>
export default {
    data() {
        return {
            currentTheme: 'default'
        };
    },
    methods: {
        applyTheme() {
            jwThemeManager.applyTheme(this.currentTheme);
        }
    }
};
</script>
```

### Angular
```typescript
import { Component } from '@angular/core';

@Component({
    selector: 'theme-switcher',
    template: `
        <select [(ngModel)]="currentTheme" (change)="applyTheme()">
            <option value="default">Default Light</option>
            <!-- ... -->
        </select>
    `
})
export class ThemeSwitcherComponent {
    currentTheme = 'default';

    applyTheme() {
        (window as any).jwThemeManager.applyTheme(this.currentTheme);
    }
}
```

## Implementation Checklist

- [ ] CSS-Variablen definiert für alle 8 Themes
- [ ] Theme-Manager JavaScript implementiert
- [ ] LocalStorage-Persistenz funktioniert
- [ ] Theme-Switcher UI integriert
- [ ] Responsive Design (Mobile, Tablet, Desktop)
- [ ] Accessibility: Semantisches HTML + ARIA
- [ ] Keyboard-Navigation funktioniert
- [ ] Kontrast-Ratio ≥ 4.5:1
- [ ] Performance: Keine Layout-Shifts beim Theme-Wechsel
- [ ] Cross-Browser-Kompatibilität getestet

## Verbotene Praktiken

❌ **NICHT verwenden**:
- Hardcodierte Farben statt CSS-Variablen
- Inline-Styles für Theme-Farben
- Andere Theme-Frameworks (Material, Bootstrap für Theming)
- JavaScript-berechnete Styles statt CSS
- Fixed Layouts statt Responsive
- `!important` für Theme-Overrides

## Beispiel-Projekt-Struktur

```
project/
├── css/
│   ├── jw-design.css        # Globale Styles + Theme-Definitionen
│   ├── layout.css            # Layout-specific styles
│   └── components.css        # Component styles
├── js/
│   └── theme-manager.js      # Theme-Switcher Logic
├── index.html                # Main page
└── README.md
```

---

**Erstellt**: 22.01.2025  
**Version**: 1.0  
**Framework-Agnostisch**: Funktioniert mit Vanilla JS, React, Vue, Angular, Blazor, etc.
