---
name: joergs-journal-article-format
description: Bereitet HTML-Inhalte für Copy&Paste in Jörgs Journal (SQL-Server-Blog) auf – nur reiner Body-Inhalt ohne html/head/body-Tags, ohne eigene Styles oder Meta-Tags.
version: 1.0.0
author: JW
---

# 🎯 Jörgs Journal – Article Format Skill

Dieser Skill bereitet HTML-Inhalte so auf, dass sie direkt als `Content`-Feld in den SQL-Server-Blog (Jörgs Journal) eingefügt werden können.

## 📋 Aufgabe

Extrahiere aus einem vollständigen HTML-Dokument oder einem beliebigen HTML-Fragment nur den **reinen Body-Inhalt**:

- **Entfernen:** `<html>`, `<head>`, `<body>` und deren schließende Tags
- **Entfernen:** `<style>`-Blöcke und inline `style="..."`-Attribute (sofern nicht semantisch notwendig)
- **Entfernen:** `<meta>`-Tags, `<title>`, `<link>`-Tags
- **Behalten:** Überschriften (`<h1>`–`<h6>`), Absätze (`<p>`), Listen (`<ul>`, `<ol>`, `<li>`), Links (`<a>`), Code-Blöcke (`<pre>`, `<code>`), Tabellen, `<strong>`, `<em>`, `<blockquote>`

## ✅ Ausgabeformat

Das Ergebnis ist **ausschließlich** der bereinigte HTML-Body-Inhalt – kein umschließendes Dokument-Gerüst, keine eigenen Styles, keine Kommentare außer inhaltlich relevanten.

### Beispiel Eingabe

```html
<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="UTF-8">
  <title>Mein Artikel</title>
  <style>body { font-family: Arial; }</style>
</head>
<body>
  <h1>Mein Titel</h1>
  <p>Ein Absatz mit <a href="https://example.com">einem Link</a>.</p>
</body>
</html>
```

### Beispiel Ausgabe

```html
<h1>Mein Titel</h1>
<p>Ein Absatz mit <a href="https://example.com">einem Link</a>.</p>
```

## 🚀 Verwendung

Übergib dem Skill einen HTML-String oder eine Datei. Der Skill gibt den bereinigten Content zurück, der direkt in das `Content`-Feld des SQL-Server-Blogs eingefügt werden kann.
