---
name: page-counter
displayName: Page Counter
description: Beschreibt eine serverseitige Page-Counter-Integration für .NET Web-Anwendungen.
version: 1.0.0
author: JW
---

# Skill: Page-Counter (file-backed) für .NET-Anwendungen

Kurz: Dieses Skill beschreibt eine wiederverwendbare Anleitung und Vorlagen, um einen einfachen, serverseitigen Page-Counter in eine beliebige .NET Web-Anwendung (Minimal API / ASP.NET Core) zu integrieren. Die Lösung verwendet eine Datei außerhalb von wwwroot (z. B. `App-Data/counts.json`) und bietet zwei Endpoints: `GET /api/hits` und `POST /api/hit`.

Wann dieses Skill nutzen
- Du brauchst einen einfachen, persistenten Seitenzähler ohne externe DB.
- Single-Instance-Deployment (Datei-Speicher ist lokal). Für mehrere Instanzen → DB/Redis verwenden.
- Du willst, dass Deployments die Zählerdatei nicht überschreiben.

Inhalte des Skills
- Konzeption und Sicherheitsgründe (Warum außerhalb von wwwroot)
- Vorlage: `Services/HitStore.cs` (thread-safe, SemaphoreSlim)
- Vorlage: Minimal-API-Registrierung in `Program.cs` (GET/POST Endpoints)
- Client-Snippet (z. B. `wwwroot/js/main.js`) zum Aufruf der Endpoints und Aktualisierung eines Footer-Elements
- Publish-Profile (pubxml) Snippet: MsDeploySkipRules / ExcludeApp_Data, damit `App-Data` beim Web Deploy nicht überschrieben/gelöscht wird

Best-Practice: App-Data
- Lege die Datei unter `Path.Combine(env.ContentRootPath, "App-Data", "counts.json")` ab.
- Erzeuge Ordner und Datei beim ersten Start, falls nicht vorhanden.
- Schutz: Setze die Publish-Profile so, dass `App-Data` ausgeschlossen wird (siehe PubXML-Snippet weiter unten).

Code-Vorlagen (Beispielauszüge)

Services/HitStore.cs (Kernfunktionen)
```csharp
// Verwendet SemaphoreSlim, JsonSerializer, env.ContentRootPath/App-Data/counts.json
public class HitStore { /* constructor(env) init file; Task<long> GetHitsAsync(); Task<long> IncrementAsync(); */ }
```

Program.cs (Registrierung + Endpoints)
```csharp
builder.Services.AddSingleton<HitStore>();
var app = builder.Build();
app.MapGet("/api/hits", async (HitStore s) => Results.Ok(new { hits = await s.GetHitsAsync() }));
app.MapPost("/api/hit", async (HitStore s) => Results.Ok(new { hits = await s.IncrementAsync() }));
```

Client (main.js — vereinfachtes Beispiel)
```javascript
async function updateSiteHits() {
  try {
    const res = await fetch('/api/hit', { method: 'POST' });
    const json = await res.json();
    document.getElementById('siteHits').textContent = json.hits.toLocaleString('de-DE');
  } catch(e) { /* optional: GET /api/hits fallback */ }
}
document.addEventListener('DOMContentLoaded', updateSiteHits);
```

Publish-Profile (pubxml) — wichtige Anpassung
- Setze in deinen PublishProfile-Dateien (z. B. `Properties/PublishProfiles/*.pubxml`) die folgenden Einträge, damit `App-Data` nicht überschrieben oder gelöscht wird:

```xml
<!-- WICHTIG: App-Data darf beim Web Deploy nicht überschrieben werden -->
<ExcludeApp_Data>true</ExcludeApp_Data>
<MsDeploySkipRules>SkipAppData</MsDeploySkipRules>
<MsDeploySkipRulesInclude>objectName='dirPath',absolutePath='App-Data'</MsDeploySkipRulesInclude>
```

Deployment-Hinweis
- Die SkipRule verhindert, dass eine vorhandene `App-Data`-Struktur auf dem Server entfernt oder ersetzt wird. Prüfe nach dem ersten Deploy, dass auf dem Server eine initiale `App-Data/counts.json` existiert oder lege sie initial per Script/SSH an.

Limitierungen & Erweiterungen
- Diese Lösung ist für Single-Instance-Deploys gedacht. Für Skalierung verwende eine zentrale Datenbank (SQLite mit File-Lock, Redis, Azure Table, Cosmos DB etc.).
- Optional: Implementiere ein optionales Admin-Endpoint zum Setzen/Resetten des Zählers (authentifiziert).

How to use this skill
1. Kopiere die `HitStore`-Vorlage in `Services/HitStore.cs`.
2. Registriere und mappe die API-Endpoints in `Program.cs` wie oben gezeigt.
3. Ergänze im Client (Footer + JS) das `#siteHits`-Element und das JS-Aufruf-Snippet.
4. Passe alle `*.pubxml`-Publish-Profile an (siehe PubXML-Snippet) bevor du per MSDeploy publishst.

Support
- Dieses Skill enthält keine ausführbaren Tests. Empfehlungen: lokale Tests via `dotnet run`, curl-Requests (`GET /api/hits`, `POST /api/hit`) und ein kurzer Browser-Reload-Test.

Lizenz & Hinweise
- Original-Codebeispiele sind bewusst minimal gehalten und anpassbar. Dokumentation und Snippets sind für interne Nutzung bestimmt.
