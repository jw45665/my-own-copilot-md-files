---
name: consume-authcore-api
description: >
  Befähigt eine beliebige Anwendung (statische Website, MAUI, Blazor, Konsole) zur vollständigen
  Nutzung der AuthCore Identity API: Bearer-Auth, Login, Token-Refresh, Profil-, Bild- und
  Autocomplete-Endpunkte. Kopiert fertige Referenz-Implementierungen in das Zielprojekt und
  passt sie an die lokale Struktur an. Use when asked to "integrate AuthCore API", "add API client",
  "consume AuthCore", or similar integration tasks.
version: 1.0.0
author: JW
tags:
  - api
  - bearer-auth
  - identity
  - http-client
  - javascript
  - dotnet
  - integration
---

# 🔌 AuthCore API Consumer Skill

Dieser Skill integriert den **AuthCore Identity API Client** in ein beliebiges Zielprojekt.

## Wann dieser Skill verwendet werden soll

Skill aktivieren, wenn:
- Eine App die AuthCore API nutzen soll (Login, Profil, Bilder, Autocomplete)
- Ein HTTP-Client für Bearer-Token-Auth benötigt wird
- Fertige, lauffähige Client-Implementierungen schnell integriert werden sollen

## Referenz-Dateien (in `references/`)

| Datei | Zweck | Plattform |
|-------|-------|-----------|
| `authcore-api.js` | Vollständiger JS/TS-API-Client (ESM-Modul) | Browser, Node.js |
| `AuthCoreApiClient.cs` | C# HTTP-Client mit Auto-Refresh | .NET MAUI, Blazor, Konsole |
| `AuthCoreDtos.cs` | Alle DTOs für Requests/Responses | .NET (falls kein Shared-Projekt) |
| `smoke-test.ps1` | PowerShell-Smoke-Test gegen laufenden Server | Entwicklung / CI |

---

## Ausführungsworkflow

### Schritt 1: Kontext ermitteln

Bevor Code erzeugt oder kopiert wird, folgende Fragen beantworten:

**1.1 Zielplattform bestimmen**
- Gibt es eine `*.csproj`-Datei? → .NET (MAUI / Blazor / Konsole)
- Gibt es `package.json` oder `*.html`? → JavaScript/Browser
- Explizit vom User angegeben? → Direkt verwenden

**1.2 API-Dokumentation lesen**
- `docs/API-DOCUMENTATION.md` (bevorzugt — aktuellste Quelle)
- Alternativ: `http://localhost:5101/swagger/v1/swagger.json` abrufen

**1.3 Shared-DTOs prüfen (nur .NET)**
- Existiert `AuthCore.Shared` als Projekt-Referenz?
  - **Ja** → `AuthCore.Shared.DTOs` direkt referenzieren, `AuthCoreDtos.cs` NICHT kopieren
  - **Nein** → `AuthCoreDtos.cs` aus `references/` in Zielprojekt kopieren

**1.4 Server-URL ermitteln**
```
HTTPS: https://localhost:7157  (launchProfile "https")
HTTP:  http://localhost:5101   (launchProfile "http" / Android-Emulator-Host)
Android-Emulator: http://10.0.2.2:5101
```

---

### Schritt 2: Plattform-spezifische Integration

#### Plattform A — Statische Website (HTML + JS)

1. `references/authcore-api.js` → `js/authcore-api.js` im Zielprojekt kopieren
2. `API_BASE`-Konstante auf korrekte Server-URL anpassen
3. Import in `login.html` und `profil.html` einfügen (Muster aus `references/authcore-api.js` verwenden)
4. CORS-Hinweis beachten (bei `file://` → lokalen HTTP-Server starten)

#### Plattform B — .NET MAUI

1. `references/AuthCoreApiClient.cs` → `Services/AuthCoreApiClient.cs` im Zielprojekt kopieren
2. Namespace auf Ziel-Namespace anpassen
3. Falls kein Shared-Projekt: `references/AuthCoreDtos.cs` → `Services/AuthCoreDtos.cs` kopieren
4. `MauiProgram.cs`: `AddHttpClient<AuthCoreApiClient>()` registrieren
5. Token-Persistenz: `SecureStorage` verwenden (Muster in `AuthCoreApiClient.cs`)
6. Plattform-URL anpassen (Android-Emulator: `10.0.2.2`)

#### Plattform C — Blazor Server / WASM

1. Gleiche Implementierung wie Plattform B
2. DI-Registrierung in `Program.cs` → `builder.Services.AddHttpClient<AuthCoreApiClient>()`
3. WASM: Token-Persistenz über `IJSRuntime` / `localStorage`
4. Server: In-Memory oder Cookie-basiert (je nach Anforderung)

#### Plattform D — .NET Konsole / Desktop (WPF/WinForms)

1. `references/AuthCoreApiClient.cs` → `Services/AuthCoreApiClient.cs` kopieren
2. `HttpClient` manuell erstellen (kein DI erforderlich, aber empfohlen)
3. Token in-memory speichern (Konsole) oder in geschütztem App-Ordner (Desktop)

---

### Schritt 3: Benutzernamen-Prüfung und Autocomplete

Diese Endpunkte erfordern **kein Auth-Token** und können direkt im Client verwendet werden:

```
GET /api/v1/profile/check-username/{username}
GET /api/v1/autocomplete/cities?query=Berlin
GET /api/v1/autocomplete/countries
```

Für JS: Entsprechende Funktionen sind in `references/authcore-api.js` bereits enthalten.  
Für .NET: Methoden in `references/AuthCoreApiClient.cs` bereits implementiert.

---

### Schritt 4: Smoke-Test ausführen

```powershell
# Server starten (falls nicht läuft)
# cd AuthCore\AuthCore.Web && dotnet run --launch-profile http

# Smoke-Test ausführen
.\.github\skills\consume-authcore-api\references\smoke-test.ps1
```

Erwartet:
- Login → `accessToken` empfangen
- Profil abrufen → `publicUsername` vorhanden
- `check-username` → `{ available: true/false }`
- Autocomplete → Array mit Städtenamen

---

### Schritt 5: Erfolgskriterien

- [ ] API-Dokumentation gelesen (`docs/API-DOCUMENTATION.md` oder Swagger)
- [ ] Zielplattform ermittelt und entsprechende Dateien kopiert
- [ ] `API_BASE` / `BaseAddress` korrekt gesetzt
- [ ] Login: `accessToken` + `refreshToken` empfangen
- [ ] Bearer-Token in alle Requests gesetzt
- [ ] Auto-Refresh bei 401 implementiert
- [ ] `publicUsername` und `displayName` im Profil lesbar
- [ ] `check-username` Endpunkt integriert
- [ ] Token-Persistenz plattform-adäquat implementiert
- [ ] Smoke-Test erfolgreich

---

## Troubleshooting

| Problem | Ursache | Lösung |
|---------|---------|--------|
| `400` bei `/identity/login` | Query-Parameter fehlen | `?useCookies=false&useSessionCookies=false` anhängen |
| `401` direkt nach Login | Token-Format falsch | `Authorization: Bearer {accessToken}` (Leerzeichen prüfen) |
| `401` nach einiger Zeit | Access Token abgelaufen | `/identity/refresh` aufrufen (automatisch im Client) |
| CORS-Fehler im Browser | `file://`-Protokoll | `python -m http.server 8080` oder `npx serve .` |
| Android-Emulator → Server 404 | `localhost` nicht geroutet | `10.0.2.2` statt `localhost` verwenden |
| Profilbild-Upload schlägt fehl | Falscher `Content-Type` | Keinen `Content-Type`-Header setzen — Browser/HttpClient setzt `multipart` automatisch |
| `publicUsername` fehlt in Antwort | Profil noch nicht vervollständigt | PUT `/api/v1/profile` mit `publicUsername` + `displayName` aufrufen |

---

## Weiterführende Ressourcen

- `docs/API-DOCUMENTATION.md` — vollständige, aktuelle API-Referenz
- `.github/agents/jw-consume-authcore-api.agent.md` — interaktiver Agent für API-Fragen
- `.github/prompts/jw-add-api-endpoints-bearer-auth.prompt.md` — Server-seitige Bearer-Auth-Konfiguration
- `http://localhost:5101/swagger` — Swagger UI (nur Development)
- `https://localhost:7157/scalar/v1` — Scalar UI (nur Development)

---

<!-- Footer -->
<div style="text-align: center; font-size: 0.8em; color: #666; margin-top: 2em;">
  <p style="margin:0;">AuthCore API Consumer Skill</p>
  <p style="margin:0; font-size: 0.9em;">© 2026 <a href="https://joerg-walkowiak.de/" style="color: inherit; text-decoration: none;">Jörg Walkowiak</a>. Alle Rechte vorbehalten. | Stand: 29.05.2026</p>
</div>
