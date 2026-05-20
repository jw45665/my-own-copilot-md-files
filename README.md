# my-own-copilot-md-files

Meine Sammlung von mir generierter AI Agent Skills und Instructions für die automatisierte Unterstützung verschiedener Aufgaben.

## 📋 Skills

| # | Titel | Funktion | Trigger |
|---|---|---|---|
| 1 | [**Add-MD-Footer**](mySkills/add-md-footer/skill.md) | Versieht Markdown-Dateien mit einem standardisierten Footer (Titel + Datum). | "Ergänze die MD-Datei um den Footer" / "Füge Footer hinzu" |
| 2 | [**Buchformat & Artikel**](mySkills/buchformat-artikel/skill.md) | Erstellt strukturierte Buchkapitel und Fachartikel im definierten Buch-Layout. | "Erstelle ein Kapitel im Buchformat" / "Schreibe einen Artikel im Buchformat" |
| 3 | [**Environment Detector**](mySkills/environment-detector/SKILL.md) | Erkennt automatisch OS-, Tool-, IDE- und MCP-Umgebungsinformationen für Metadaten. | `python mySkills/environment-detector/detect_env.py --merge data/model-metadata.json` |
| 4 | [**Image Downloader**](mySkills/image-downloader/SKILL.md) | Findet und lädt lizenzfreie Bilder inkl. Credits und Varianten (z. B. WebP). | `python mySkills/image-downloader/image_skill.py --search "..." --out-base assets/images/...` |
| 5 | [**KI-Club Adaptive Theming**](mySkills/ki-club-adaptive-theming/SKILL.md) | Implementiert ein dynamisches CSS-Variablen-Theme-System mit Theme-Switcher. | "Implementiere ein Theme-System" / "Füge Dark/Light-Mode hinzu" |
| 6 | [**LM Studio Model Sync**](mySkills/lm-studio-sync/SKILL.md) | Synchronisiert verfügbare LM-Studio-Modelle in die `chatLanguageModels.json`. | "Synchronisiere die LM-Studio-Modelle" |
| 7 | [**Ollama Model Sync**](mySkills/ollama-sync/SKILL.md) | Synchronisiert verfügbare Ollama-Modelle in die `chatLanguageModels.json`. | "Synchronisiere die Ollama-Modelle" |
| 8 | [**Page-Counter**](mySkills/page-counter/SKILL.md) | Anleitung + Vorlagen für einen einfachen, file-backed Seitenzähler (App-Data/counts.json) mit Endpoints `GET /api/hits` und `POST /api/hit`. | "Füge Page-Counter zur App hinzu" / "GET /api/hits, POST /api/hit" |
| 9 | [**Publish to IIS**](mySkills/publish-to-iis/SKILL.md) | Veröffentlicht ein Vite/React-Projekt auf IIS per Web Deploy mit Verifikation. | "Deploye auf IIS" / "Publish to IIS" |
| 10 | [**Social Media Postings**](mySkills/social-media-postings/skill.md) | Erstellt plattformspezifische Social-Media-Beiträge mit Hashtags und CTA. | "Erstelle einen LinkedIn-/Facebook-/X-Post" |
| 11 | [**Social Share Metadata**](mySkills/social-share-metadata/SKILL.md) | Implementiert Open-Graph-, Facebook-, WhatsApp-, Twitter/X- und allgemeine Share-Metadaten robust. | "Facebook-Preview fehlt" / "Open Graph Meta-Tags ergänzen" |
| 12 | [**Static Web Syncfusion Agentic**](mySkills/static-web-syncfusion-agentic/SKILL.md) | Entwickelt statische Websites komponentenbasiert (HTML/CSS/JS/TS) mit i18n, Theme-System und Syncfusion-First. | "Erstelle eine statische Website mit Komponentenarchitektur" / "Baue eine neue Komponente mit Syncfusion" |
| 13 | [**VS Code Web Start Config**](mySkills/vscode-web-start-config/SKILL.md) | Stellt Starterkonfigurationen für Webprojekte in VS Code bereit, inklusive Launch- und Debug-Setups. | "Erstelle eine VS Code Web-Startkonfiguration" / "Füge Web Start Config für VS Code hinzu" |
| 14 | [**VS-F5 React/Vite Enable**](mySkills/vs-f5-react-vite-enable/SKILL.md) | Aktiviert F5-Start und Debug-Konfiguration für React/Vite in Visual Studio und VS Code. | "Ich möchte die Anwendung in VS mit F5 starten können" / "React/Vite in Visual Studio debuggen" |
| 15 | [**VS Template Agent**](mySkills/vs-template-agent/skill.md) | Erstellt, installiert und validiert robuste Visual-Studio-Projekt- und Item-Templates. | "Erstelle ein Visual-Studio-Template" / "Template aus bestehendem Projekt erzeugen" |

## 🧾 Instructions

| # | Datei | Pfad |
|---|---|---|
| 1 | [**html-css-style-color-guide.instructions.md**](myInstructions/html-css-style-color-guide.instructions.md) | `myInstructions/html-css-style-color-guide.instructions.md` |
| 2 | [**jw-html-komponenten-entwicklung.instructions.md**](myInstructions/jw-html-komponenten-entwicklung.instructions.md) | `myInstructions/jw-html-komponenten-entwicklung.instructions.md` |
| 3 | [**jw-react-ui-instructions.md**](myInstructions/jw-react-ui-instructions.md) | `myInstructions/jw-react-ui-instructions.md` |
| 4 | [**jw.blazor-component.instructions.md**](myInstructions/jw.blazor-component.instructions.md) | `myInstructions/jw.blazor-component.instructions.md` |
| 5 | [**jw.copilot-instructions.instructions.md**](myInstructions/jw.copilot-instructions.instructions.md) | `myInstructions/jw.copilot-instructions.instructions.md` |
| 6 | [**jw.static-website.instructions.md**](myInstructions/jw.static-website.instructions.md) | `myInstructions/jw.static-website.instructions.md` |
| 7 | [**static-website.instructions.md**](myInstructions/static-website.instructions.md) | `myInstructions/static-website.instructions.md` |

## 📄 Dokumente

| # | Dokument | Pfad |
|---|---|---|
| 1 | **LM Studio Modelle in VS Code verwenden** | `DOCS/LM Studio Modelle in VS Code verwenden.md` |
| 2 | **Wie man die (lokal) verfügbaren Ollama-Modelle abruft und in VS Code (automatisch) bereitstellt** | `DOCS/Wie man die (lokal) verfügbaren Ollama-Modelle abruft und in VS Code (automatisch) bereitstellt.md` |

---

## 🗒️ Über Instructions

Copilot Instructions sind projektspezifische Anweisungsdateien (`.instructions.md`), die GitHub Copilot kontextbezogenes Wissen über Coding-Standards, Architekturentscheidungen und Teamkonventionen bereitstellen. Sie werden automatisch beim Öffnen eines Projekts in VS Code oder Visual Studio geladen und beeinflussen so das Verhalten von Copilot gezielt für den jeweiligen Kontext – ohne dass der Nutzer bei jeder Anfrage erneut Kontext liefern muss.

---

## 🔧 Über Skills

AI Agent Skills sind spezialisierte Module, die von AI-Assistenten verwendet werden, um spezifische Aufgaben automatisiert auszuführen. Jeder Skill kann durch bestimmte Benutzeranforderungen oder automatische Trigger aktiviert werden und führt vordefinierte Operationen durch, um die gewünschten Ergebnisse zu liefern.

---

<!-- Footer -->
<div style="text-align: center; font-size: 0.8em; color: #666; margin-top: 2em;">
  <p style="margin:0;">my-own-copilot-md-files</p>
  <p style="margin:0; font-size: 0.9em;">© JW 2026 | Stand: 07.05.2026</p>
</div>