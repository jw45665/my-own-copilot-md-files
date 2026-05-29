---
title: Add Identity API Endpoints with Bearer Token Auth
version: 2.0
date_created: 2026-01-22
last_updated: 2026-05-29
owner: API Team
tags: [process, api, bearer-token, identity, html, javascript, blazor, maui, mobile, authentication]
---

> 📌 **Scope:** Dieser Prompt behandelt die **server-seitige Konfiguration** von Bearer-Token-Auth in ASP.NET Core.  
> Für die **Client-seitige Integration** (HTML/JS, MAUI, Blazor) → Agent: [`.github/agents/jw-consume-authcore-api.agent.md`](../agents/jw-consume-authcore-api.agent.md)

---

# Identity API Endpoints mit Bearer Token Authentifizierung

Dieser Prompt fügt Identity API Endpoints für externe Clients (MAUI, Mobile, Desktop) hinzu und konfiguriert **duale Authentifizierung** (Cookie + Bearer Token parallel).

## Voraussetzungen
- ✅ ASP.NET Core Identity installiert
- ✅ .NET 10 SDK
- ✅ Entity Framework Core konfiguriert

## Schritt 1: .NET Version prüfen

**Prüfe PROJEKT-Version in .csproj:**
```bash
# Suche TargetFramework
Get-ChildItem -Recurse -Filter *.csproj | Select-String "<TargetFramework>"
```

**Falls < net10.0:**
```
⚠️ Projekt nutzt {version}. 
Identity API Endpoints mit Bearer Token erfordern .NET 10.

➡️ Empfehlung: jw-migrate-to-net10.prompt.md
```

## Schritt 2: Duale Authentifizierung konfigurieren

**In `Program.cs` ERSETZE Standard-Auth durch:**

```csharp
// WICHTIG: Zuerst Authentication konfigurieren, dann getrennt Bearer und Cookies
var authenticationBuilder = builder.Services.AddAuthentication(options =>
{
    // Für Web-UI: Cookie-basierte Authentifizierung
    options.DefaultScheme = IdentityConstants.ApplicationScheme;
    options.DefaultSignInScheme = IdentityConstants.ExternalScheme;
    
    // WICHTIG: Kein DefaultChallengeScheme setzen!
    // Dies ermöglicht sowohl Cookie- als auch Bearer-Token-Authentifizierung
});

// Bearer-Token für MAUI/Mobile-API (muss VOR AddIdentityCookies!)
authenticationBuilder.AddBearerToken(IdentityConstants.BearerScheme);

// Cookie-Authentifizierung für Web-UI
authenticationBuilder.AddIdentityCookies();

builder.Services.AddIdentityCore<ApplicationUser>(options => 
{
    options.SignIn.RequireConfirmedAccount = true;
    options.Stores.SchemaVersion = IdentitySchemaVersions.Version3; // .NET 10
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddSignInManager()
.AddApiEndpoints() // ⭐ WICHTIG: Für API-Endpoints
.AddDefaultTokenProviders();
```

## Schritt 3: Identity API Endpoints aktivieren

**In `Program.cs` NACH `app.Build()` hinzufügen:**

```csharp
// Middleware-Reihenfolge KRITISCH:
app.UseAuthentication();
app.UseAuthorization();
app.UseAntiforgery(); // NACH Auth!

// ⭐ Identity API Endpoints für externe Clients
app.MapGroup("/identity").MapIdentityApi<ApplicationUser>();

// Blazor/MVC Endpoints
app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

// Web-UI Identity Endpoints (für Blazor-Komponenten)
app.MapAdditionalIdentityEndpoints();
```

## Schritt 4: Verfügbare Endpoints testen

**Automatisch verfügbare Endpoints:**

### POST /identity/register
Registriert neuen Benutzer

**Request:**
```json
{
  "email": "user@example.com",
  "password": "StrongPassword123!"
}
```

**Response:** `200 OK`

### POST /identity/login
Login mit Bearer Token

**Request:**
```json
{
  "email": "user@example.com",
  "password": "StrongPassword123!"
}
```

**Response:**
```json
{
  "tokenType": "Bearer",
  "accessToken": "...",
  "expiresIn": 3600,
  "refreshToken": "..."
}
```

### POST /identity/refresh
Token erneuern

**Request:**
```json
{
  "refreshToken": "..."
}
```

**Response:** Neuer Access Token

### POST /identity/confirmEmail
Email bestätigen (Falls RequireConfirmedAccount = true)

### POST /identity/resendConfirmationEmail
Bestätigungs-Email erneut senden

### POST /identity/forgotPassword
Passwort-Reset anfordern

### POST /identity/resetPassword
Passwort mit Token zurücksetzen

### GET /identity/manage/info
Benutzerinformationen abrufen (Authentifizierung erforderlich)

**Headers:**
```
Authorization: Bearer {accessToken}
```

## Schritt 5: OpenAPI/Scalar-Dokumentation hinzufügen

```csharp
builder.Services.AddOpenApi();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference(options =>
    {
        options
            .WithTitle("AuthCore API")
            .WithTheme(ScalarTheme.Purple)
            .WithDefaultHttpClient(ScalarTarget.CSharp, ScalarClient.HttpClient);
    });
}
```

**Zugriff:** `https://localhost:7157/scalar/v1`

**Port aus launchSettings.json** – HTTPS: 7157, HTTP: 5101

## Schritt 6: App starten und testen

**Anwendung starten:**
```powershell
cd AuthCore\AuthCore.Web
dotnet run --launch-profile https
```

**Ports (aus launchSettings.json):**
- HTTPS: `https://localhost:7157`
- HTTP: `http://localhost:5101`

**Swagger/Scalar UI:**
- `https://localhost:7157/swagger` ← Swagger UI
- `https://localhost:7157/scalar/v1` ← Scalar UI

**Falls Port bereits belegt ("address already in use"):**
```powershell
# Finde Prozess auf Port (Beispiel: 7157 oder 5101)
Get-NetTCPConnection -LocalPort 7157 -ErrorAction SilentlyContinue | 
    Select-Object -ExpandProperty OwningProcess | 
    ForEach-Object { Stop-Process -Id $_ -Force }

# App neu starten
dotnet run --launch-profile https
```

## Schritt 7: Test-Endpoint erstellen

```csharp
app.MapGet("/api/test-auth", (ClaimsPrincipal user) =>
{
    return Results.Ok(new 
    { 
        isAuthenticated = user.Identity?.IsAuthenticated ?? false,
        userName = user.Identity?.Name,
        authType = user.Identity?.AuthenticationType
    });
})
.RequireAuthorization()
.WithName("TestAuth");
```

**Hinweis:** `.WithOpenApi()` ist in .NET 10 deprecated und nicht mehr notwendig.

## Schritt 8: MAUI-Client konfigurieren (optional)

Falls MAUI-Projekt vorhanden, erstelle `Services/HttpClientHelper.cs`:

```csharp
namespace YourNamespace.Services
{
    internal class HttpClientHelper
    {
        private const string LanBaseUrl = "http://192.168.178.42:5101/";
        private static string _baseUrl = "http://localhost:5101/";
        
        public static string BaseUrl
        {
            get
            {
#if DEBUG
                if (DeviceInfo.Platform == DevicePlatform.Android)
                {
                    _baseUrl = DeviceInfo.DeviceType == DeviceType.Virtual
                        ? _baseUrl.Replace("localhost", "10.0.2.2")
                        : LanBaseUrl;
                }
#endif
                return _baseUrl;
            }
        }
        
        public static string LoginUrl => $"{BaseUrl}identity/login";
        public static string RefreshUrl => $"{BaseUrl}identity/refresh";
        
        public static HttpClient GetHttpClient()
        {
            return new HttpClient();
        }
    }
}
```

> **Hinweis:** Für vollständige Client-Integration aller Plattformen (inkl. HTML/JS) → `.github/agents/jw-consume-authcore-api.agent.md`

## Troubleshooting

### Problem: "400 Bad Request" bei /identity/login
**Ursache:** Antiforgery-Middleware VOR Authentication

**Lösung:** Reihenfolge: `UseAuthentication()` → `UseAuthorization()` → `UseAntiforgery()`

### Problem: Cookie-Login funktioniert nicht mehr
**Ursache:** `DefaultChallengeScheme` gesetzt

**Lösung:** NICHT setzen! Beide Schemas parallel möglich.

### Problem: Bearer Token wird nicht akzeptiert
**Ursache:** `AddBearerToken` fehlt oder nach `AddIdentityCookies`

**Lösung:** `AddBearerToken` MUSS VOR `AddIdentityCookies`

### Problem: "Failed to bind to address - address already in use"
**Ursache:** Port ist bereits belegt (oft von vorheriger dotnet-Instanz)

**Lösung:**
```powershell
# Finde & beende Prozess auf Port (Beispiel für 7134)
Get-NetTCPConnection -LocalPort 7134 -ErrorAction SilentlyContinue | 
    Select-Object -ExpandProperty OwningProcess | 
    ForEach-Object { Stop-Process -Id $_ -Force }

dotnet run --launch-profile https
```

## Erfolgs-Kriterien
- [ ] Duale Auth konfiguriert (Cookie + Bearer)
- [ ] `/identity` Endpoints gemappt
- [ ] POST /identity/login funktioniert
- [ ] Access Token erhalten
- [ ] Token bei geschützten Endpoints funktioniert
- [ ] Scalar-Dokumentation verfügbar
- [ ] Web-UI-Login noch funktioniert

## Weiterführende Prompts
- **Client-Integration (alle Plattformen):** [`.github/agents/jw-consume-authcore-api.agent.md`](../agents/jw-consume-authcore-api.agent.md)
- MAUI Auth: Erstelle `MauiAuthenticationStateProvider`
- Refresh Token: Implementiere Auto-Refresh-Logik
- Rate Limiting: `jw-add-rate-limiting.prompt.md`
- E-Mail-Bestätigung: `jw-activate-emailconfirmation.prompt.md`

## Referenzen
- [MapIdentityApi](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/identity-api-authorization)
- [Bearer Token Auth](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/identity/spa)

---

<!-- Footer -->
<div style="text-align: center; font-size: 0.8em; color: #666; margin-top: 2em;">
  <p style="margin:0;">Add Identity API Endpoints with Bearer Token Auth</p>
  <p style="margin:0; font-size: 0.9em;">© 2026 <a href="https://joerg-walkowiak.de/" style="color: inherit; text-decoration: none;">Jörg Walkowiak</a>. Alle Rechte vorbehalten. | Stand: 29.05.2026</p>
</div>
