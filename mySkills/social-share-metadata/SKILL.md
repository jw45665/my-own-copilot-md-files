---
name: social-share-metadata
description: Implementiert Open-Graph-, Facebook-, WhatsApp-, Twitter/X- und allgemeine Share-Metadaten robust. Nutze diesen Skill immer bei Begriffen wie Open Graph, OG, Facebook Sharing Debugger, Link-Vorschau, Vorschaubild, Canonical, Twitter Card, Share Image, Meta-Tags, "beim Teilen fehlt Bild/Beschreibung", "Facebook zeigt nichts", "WhatsApp geht, Facebook nicht", "Crawler", "Scrapen", "403", "IIS-Log", "robots.txt", "facebookexternalhit".
---

# Social Share Metadata

Dieser Skill stellt sicher, dass Link-Vorschauen nicht nur formal vorhanden sind, sondern von realen Crawlern (insbesondere Facebook) zuverlässig gelesen werden.

## Ziel

Implementiere Share-Metadaten so, dass stabil funktioniert:

- Titel, Beschreibung und Bild in Facebook, WhatsApp, X/Twitter, LinkedIn und Messengern
- konsistente Canonical- und OG-URL
- robuste Auslieferung bei Blazor/SSR/SPA-Hybriden

## Trigger (verbindlich)

Skill zwingend auslösen bei:

- "Facebook teilen", "FB-Preview", "Sharing Debugger", "Erneut scrapen"
- "Bild fehlt", "Description fehlt", "Vorschau falsch", "nur URL sichtbar"
- "WhatsApp funktioniert, Facebook nicht"
- "OG", "Open Graph", "Twitter Card", "social preview", "share metadata"
- "403", "404", "503", "robots.txt", "facebookexternalhit", "Facebot"
- "IIS-Log", "Access-Log", "am Ende vom Log", "Scraping-Log"

## Priorisierung bei Störungen

1. **Facebook-Debugger + HTTP-Status zuerst**, nicht zuerst Twitter.
2. Bei IIS-/Access-Logs immer **bis zum Dateiende** gehen (neueste Requests unten).
3. Wenn WhatsApp funktioniert, Facebook aber nicht: primär auf FB-Crawler-Zugriff, Caching und Statuscodes fokussieren.

## Kernprinzipien

1. Crawler lesen den initialen HTTP-Response (Head), nicht nur nachträglich hydratisiertes DOM.
2. Für `og:url`, `og:image`, `canonical`, `twitter:image` immer absolute HTTPS-URLs.
3. Share-Bild muss direkt und ohne Auth erreichbar sein.
4. Bei Blazor/SPA: serverseitige Ausgabe bzw. Prerendering sicherstellen.
5. Bei Facebook-Fehlern immer Statuscode-Grund (403/503 etc.) klären, bevor Tag-Feintuning erfolgt.

## Kritische Anti-Pattern (verbindlich vermeiden)

1. `og:url` oder `canonical` mit Test-/Tracking-Parametern (`?v=4`, `utm_*`, `fbclid`) setzen.
2. Cache-Busting an der Seiten-URL statt am Bild durchführen.
3. Relative Bild-URLs (`/images/share.jpg`) für OG/Twitter ausgeben.
4. Unterschiedliche Ziel-URLs in `canonical`, `og:url` und `twitter:url` verwenden.

Regel: Query-Parameter nur für `og:image`/`twitter:image` zur kontrollierten Cache-Aktualisierung nutzen (z. B. `share.jpg?v=20260518`).

## Mindestumfang

```html
<meta name="description" content="..." />
<link rel="canonical" href="https://example.com/" />

<meta property="og:site_name" content="..." />
<meta property="og:type" content="website" />
<meta property="og:locale" content="de_DE" />
<meta property="og:title" content="..." />
<meta property="og:description" content="..." />
<meta property="og:url" content="https://example.com/" />
<meta property="og:image" content="https://example.com/path/share.jpg" />
<meta property="og:image:alt" content="..." />

<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="..." />
<meta name="twitter:description" content="..." />
<meta name="twitter:image" content="https://example.com/path/share.jpg" />
```

## Robuste Erweiterung (empfohlen)

```html
<meta property="og:image:url" content="https://example.com/path/share.jpg" />
<meta property="og:image:secure_url" content="https://example.com/path/share.jpg" />
<meta property="og:image:type" content="image/jpeg" />
<meta property="og:image:width" content="1200" />
<meta property="og:image:height" content="630" />
<link rel="image_src" href="https://example.com/path/share.jpg" />

<meta name="twitter:url" content="https://example.com/" />
<meta name="twitter:image:src" content="https://example.com/path/share.jpg" />
```

## WA/FB Sofort-Template (empfohlen für Erstimplementierung)

```html
<meta name="description" content="..." />
<meta name="robots" content="index,follow,max-image-preview:large" />
<link rel="canonical" href="https://example.com/" />

<meta property="og:type" content="website" />
<meta property="og:locale" content="de_DE" />
<meta property="og:title" content="..." />
<meta property="og:description" content="..." />
<meta property="og:url" content="https://example.com/" />
<meta property="og:image" content="https://example.com/images/share.jpg?v=YYYYMMDD" />
<meta property="og:image:secure_url" content="https://example.com/images/share.jpg?v=YYYYMMDD" />
<meta property="og:image:type" content="image/jpeg" />
<meta property="og:image:width" content="1200" />
<meta property="og:image:height" content="630" />
<meta property="og:image:alt" content="..." />

<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="..." />
<meta name="twitter:description" content="..." />
<meta name="twitter:url" content="https://example.com/" />
<meta name="twitter:image" content="https://example.com/images/share.jpg?v=YYYYMMDD" />
```

Hinweis: `og:url` bleibt immer stabil ohne Query-Parameter. Für Re-Scrapes wird nur die Bild-URL versioniert.

## Facebook-/WhatsApp-spezifische Checks

Bei Problemen mit Facebook zwingend prüfen:

1. Facebook Debugger: letzter Scrape, Antwortcode, Grundtext.
2. `GET /` und `GET /share-image` im neuesten IIS-Log: 200?
3. `robots.txt` erreichbar und erlaubt (`facebookexternalhit`, `Facebot`).
4. WAF/Firewall/Bot-Protection blockt Facebook nicht.
5. Bei `fbclid`-Requests keine fehlerhafte Interaktivitäts-Pflicht (z. B. problematische `/_blazor/negotiate`-Kette).

Interpretation:

- **403**: Zugriff blockiert (Firewall/Bot-Regeln/Hoster), kein Metatag-Hauptproblem.
- **503 auf `/_blazor/negotiate`**: App-Interaktivität instabil; statische Share-Auslieferung für Crawler sicherstellen.
- **200 auf `/` + Bild, aber falsche Preview**: Cache/Re-Scrape/Canonical- oder OG-URL-Divergenz prüfen.

## Blazor & Razor Spezifisch (VERBINDLICH)

1. **Kein `<head>` in Komponenten**: Nutze niemals das HTML-Tag `<head>` innerhalb einer `.razor`-Seite. Dies wird im `<body>` gerendert und von Crawlern oft ignoriert oder führt zu Parsing-Fehlern.
2. **Nutze `<HeadContent>`**: Alle Metadaten (OG, Twitter, etc.) müssen zwingend in ein `<HeadContent>`-Element gewickelt werden, damit Blazor sie korrekt in den echten `<head>` des Dokuments injiziert.
3. **Nutze `<PageTitle>`**: Verwende für den Seitentitel ausschließlich die Razor-Komponente `<PageTitle>`, statt `<title>` zu verwenden.

## Verifikation (Pflicht)

1. Ziel-URL HTML abrufen und erforderliche Meta-Tags verifizieren.
2. Konsistenz prüfen: `canonical`, `og:url`, `twitter:url` identisch und ohne Test-/Tracking-Query (`?v=`, `utm_*`, `fbclid`).
3. Share-Bild direkt abrufen (Status, Content-Type, Größe).
4. Facebook Debugger "Erneut scrapen" ausführen und Antwortcode + extrahierte Felder prüfen.
5. IIS-Log-Ende kontrollieren, ob Requests zum Testzeitpunkt konsistent sind.

## Arbeitsmodus

1. Symptome und betroffene Plattform aufnehmen.
2. Aktuellen HTTP-Status im Debugger/Logs prüfen.
3. Meta- und Canonical-Set vervollständigen.
4. Serverseitige Auslieferung absichern.
5. Re-Scrape und Log-Verifikation durchführen.
6. Erst bei nachweislich korrekter Preview abschließen.

## Ergebnis

Erfolg bedeutet: In realen Shares erscheinen Titel, Beschreibung und Bild zuverlässig; Statuscodes und Crawler-Zugriff sind nachweislich stabil.

---

<!-- Footer -->
<div style="text-align: center; font-size: 0.8em; color: #666; margin-top: 2em;">
  <p style="margin:0;">social-share-metadata/SKILL.md</p>
  <p style="margin:0; font-size: 0.9em;">© 2026 <a href="https://joerg-walkowiak.de/" style="color: inherit; text-decoration: none;">Jörg Walkowiak</a>. Alle Rechte vorbehalten. | Stand: 18.05.2026</p>
</div>
