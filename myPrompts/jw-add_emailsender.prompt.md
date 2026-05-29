---
title: Add Email Service with MailKit
version: 1.0
date_created: 2026-01-22
last_updated: 2026-01-22
owner: jw45665
tags: [process, email, mailkit, smtp, dotnet10, identity, forms]
---

# Email-Service mit MailKit für .NET Anwendungen

Dieser Prompt implementiert einen produktionsreifen Email-Service basierend auf MailKit in .NET Projekten. Der Service unterstützt zwei Szenarien:
- **Szenario A:** Basis Email-Funktionalität für Formulare und Benachrichtigungen
- **Szenario B:** Integration mit ASP.NET Core Identity für Email-Bestätigung und Passwort-Reset

## Schritt 0: .NET Version prüfen

**WICHTIG:** Dieser Prompt erfordert .NET 10 für optimale Kompatibilität.

**Prüfe PROJEKT-Version (nicht SDK!):**
```bash
# Suche TargetFramework in allen .csproj Dateien
Get-ChildItem -Recurse -Filter *.csproj | Select-String "<TargetFramework>" | Select-Object -First 1
```

**Erwartetes Ergebnis:**
- `net10.0` ✅ OK, fortfahren
- `net9.0` oder `net8.0` ⚠️ Migration empfohlen

**Falls < net10.0:**
```
⚠️ Dein Projekt nutzt .NET {erkannte_version} (aus .csproj).
Dieser Email-Service ist für .NET 10 optimiert.

.NET 10 SDK installiert? 
```bash
dotnet --list-sdks | grep "10.0"
```

Empfehlung: Führe zuerst 'jw-migrate-to-net10.prompt.md' aus.
Möchtest du trotzdem fortfahren? [Ja/Nein]
```

**Falls Nein gewählt:**
```
➡️ Führe aus: jw-migrate-to-net10.prompt.md
Danach diesen Prompt erneut ausführen.
```

## Schritt 1: Projekttyp ermitteln

**Nutze `ask_questions` Tool**, um dem Benutzer folgende Auswahl per Button zu präsentieren:

```
Question: "Welchen Projekttyp entwickelst du?"
Options:
- "ASP.NET Core (Web API, MVC, Blazor Server/WASM)" (recommended für Web-Projekte)
- "MAUI Blazor Hybrid (Web + Mobile/Desktop)"
- "WPF / WinForms / MAUI Windows"
- "Console App / Background Service"

Question: "Welches Szenario möchtest du implementieren?"
Options:
- "Basis Email-Funktionalität (Formulare, Benachrichtigungen)" (recommended)
- "Identity Email-Integration (Benutzerbestätigung, Passwort-Reset)"
- "Beides"
```

## Schritt 2: NuGet Pakete installieren

**Installiere folgende Pakete** über `dotnet add package` (Terminal):

### Für alle Projekt-Typen:
```bash
dotnet add package MailKit --version 4.9.0
dotnet add package MimeKit --version 4.9.0
```

### Zusätzlich für Identity-Integration (Szenario B):
```bash
# Falls Identity noch nicht installiert:
dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore --version 10.0.0
```

## Schritt 3: Modelle erstellen

**Erstelle Ordner und Dateien:**

### `Models/EmailConfiguration.cs`
```csharp
namespace YourNamespace.Models
{
    public class EmailConfiguration
    {
        public string Host { get; set; } = string.Empty;
        public int Port { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string From { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public bool EnableSSL { get; set; }
        public string SiteName { get; set; } = string.Empty;
    }
}
```

### `Models/EmailMessage.cs` (optional, für Formulare)
```csharp
using System.ComponentModel.DataAnnotations;

namespace YourNamespace.Models
{
    public class EmailMessage
    {
        [Required(ErrorMessage = "E-Mail-Adresse ist erforderlich")]
        [EmailAddress(ErrorMessage = "Keine gültige E-Mail-Adresse")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Betreff ist erforderlich")]
        public string Subject { get; set; } = string.Empty;

        [Required(ErrorMessage = "Nachrichtentext ist erforderlich")]
        public string Message { get; set; } = string.Empty;
    }
}
```

## Schritt 4: Service Interface & Implementierung

### `Services/IEmailSender.cs`
```csharp
namespace YourNamespace.Services
{
    public interface IEmailSender
    {
        Task SendEmailAsync(string email, string subject, string htmlMessage);
    }
}
```

### `Services/EmailSender.cs`
```csharp
using YourNamespace.Models;
using MailKit.Net.Smtp;
using Microsoft.Extensions.Options;
using MimeKit;
using MimeKit.Text;
using Microsoft.Extensions.Logging;

namespace YourNamespace.Services
{
    public class EmailSender : IEmailSender
    {
        private readonly EmailConfiguration _emailConfiguration;
        private readonly ILogger<EmailSender> _logger;

        public EmailSender(IOptions<EmailConfiguration> emailConfiguration, ILogger<EmailSender> logger)
        {
            _emailConfiguration = emailConfiguration.Value;
            _logger = logger;
        }

        public Task SendEmailAsync(string email, string subject, string htmlMessage)
        {
            // Betreff und Nachricht mit SiteName anreichern
            var siteName = _emailConfiguration.SiteName;
            var icon = "\uD83D\uDCE7 "; // 📧
            var finalSubject = string.IsNullOrWhiteSpace(siteName)
                ? subject
                : $"{icon}{siteName} – {subject}";

            // Optional: SiteName und Icon im Body einfügen
            var finalBody = $"<div style='font-family:sans-serif;'>"
                + (string.IsNullOrWhiteSpace(siteName) ? "" : $"<div style='font-size:1.2em;margin-bottom:8px;'><b>{siteName}</b></div>")
                + htmlMessage
                + "</div>";

            return Execute(email, finalSubject, finalBody);
        }

        private async Task Execute(string to, string subject, string htmlMessage)
        {
            string host = _emailConfiguration.Host;
            int port = _emailConfiguration.Port;
            string username = _emailConfiguration.Username;
            // Passwort bevorzugt aus Umgebungsvariable lesen
            string password = Environment.GetEnvironmentVariable("PASSWORT_NOREPLY_SERVER-1") ?? _emailConfiguration.Password;
            string from = _emailConfiguration.From;
            string name = string.IsNullOrWhiteSpace(_emailConfiguration.SiteName) ? _emailConfiguration.Name : _emailConfiguration.SiteName;
            bool enableSsl = _emailConfiguration.EnableSSL;

            var email = new MimeMessage();

            var sender = MailboxAddress.Parse(from);
            if (!string.IsNullOrEmpty(name))
                sender.Name = name;
            email.Sender = sender;
            email.From.Add(sender);
            email.To.Add(MailboxAddress.Parse(to));
            email.Subject = subject;
            email.Body = new TextPart(TextFormat.Html) { Text = htmlMessage };

            using (var smtp = new SmtpClient())
            {
                smtp.Timeout = 60000; // 60secs
                try
                {
                    await smtp.ConnectAsync(host, port, enableSsl);
                    if (!string.IsNullOrEmpty(username))
                        await smtp.AuthenticateAsync(username, password);
                    await smtp.SendAsync(email);
                    await smtp.DisconnectAsync(true);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Fehler beim Senden der E-Mail an {recipient}", to);
                    throw new ApplicationException("E-Mail konnte nicht gesendet werden", ex);
                }
            }
        }
    }
}
```

## Schritt 5: Konfiguration in appsettings.json

**Füge folgende Sektion zu `appsettings.json` hinzu:**

```json
{
  "EmailConfiguration": {
    "Host": "server-1.net",
    "Port": 587,
    "Username": "noreply@server-1.net",
    "Password": "",
    "From": "noreply@server-1.net",
    "Name": "Admin",
    "EnableSSL": true,
    "SiteName": "MyEmailPormptsTester"
  }
}
```

**WICHTIG - Best Practices:**
- **From & Username sollten identisch sein** mit echtem SMTP-Service-Account (nicht mit Test-Adressen)
- **Keine Dummy-Email-Adressen** in Test-Komponenten verwenden
- **Das Passwort-Feld bleibt IMMER leer!** Der Service liest das Passwort aus der Umgebungsvariable `PASSWORT_NOREPLY_SERVER-1`

### Umgebungsvariable setzen (Entwicklungsrechner):

**WICHTIG:** Prüfe zuerst, ob die Variable bereits existiert, um versehentliches Überschreiben zu vermeiden!

**Windows (PowerShell) - Prüfen & Setzen:**
```powershell
# Zuerst prüfen:
$existing = [System.Environment]::GetEnvironmentVariable('PASSWORT_NOREPLY_SERVER-1', 'User')
if ([string]::IsNullOrEmpty($existing)) {
    [System.Environment]::SetEnvironmentVariable('PASSWORT_NOREPLY_SERVER-1', 'IhrPasswort', 'User')
    Write-Host "Umgebungsvariable gesetzt. Bitte Visual Studio/Terminal neu starten!"
} else {
    Write-Host "Umgebungsvariable bereits vorhanden: $existing"
}
```

**Windows (CMD) - Prüfen:**
```cmd
echo %PASSWORT_NOREPLY_SERVER-1%
```
**Nur setzen, wenn leer:**
```cmd
setx PASSWORT_NOREPLY_SERVER-1 "IhrPasswort"
```

**Linux/Mac - Prüfen & Setzen:**
```bash
if [ -z "$PASSWORT_NOREPLY_SERVER-1" ]; then
    echo 'export PASSWORT_NOREPLY_SERVER-1="IhrPasswort"' >> ~/.bashrc
    source ~/.bashrc
    echo "Umgebungsvariable gesetzt!"
else
    echo "Umgebungsvariable bereits vorhanden: $PASSWORT_NOREPLY_SERVER-1"
fi
```

## Schritt 6: Dependency Injection konfigurieren

### ASP.NET Core (Web API, MVC, Blazor Server/WASM)

**In `Program.cs`:**

```csharp
using YourNamespace.Models;
using YourNamespace.Services;
using Microsoft.Extensions.Options;

var builder = WebApplication.CreateBuilder(args);

// Email-Konfiguration aus appsettings.json laden
builder.Services.Configure<EmailConfiguration>(
    builder.Configuration.GetSection("EmailConfiguration"));

// EmailSender registrieren
builder.Services.AddScoped<IEmailSender, EmailSender>();

var app = builder.Build();
```

**Für Identity-Integration (Szenario B) - zusätzlich:**

**HINWEIS:** Die vollständige Identity-Email-Integration wird von einem separaten Prompt durchgeführt.
Siehe: `jw-activate-emailconfirmation.prompt`

**Dieser Abschnitt erstellt nur das Basis-Interface, das von Identity genutzt werden kann.**

### MAUI Blazor Hybrid

**Bei Hybrid-Projekten:** Implementiere den EmailSender in einer **Shared RCL** (Razor Class Library):

**In `Shared.csproj`:**
```xml
<ItemGroup>
  <PackageReference Include="MailKit" Version="4.9.0" />
  <PackageReference Include="MimeKit" Version="4.9.0" />
</ItemGroup>
```

**In Web-Projekt `Program.cs`:**
```csharp
builder.Services.Configure<EmailConfiguration>(
    builder.Configuration.GetSection("EmailConfiguration"));
builder.Services.AddScoped<SharedNamespace.Services.IEmailSender, SharedNamespace.Services.EmailSender>();
```

**In MAUI `MauiProgram.cs`** (falls Email-Versand aus MAUI benötigt):

**WICHTIG:** NIE Credentials oder SMTP-Daten hardcodieren! Nutze appsettings.json (eingebettet) oder Umgebungsvariablen.

**Option A - Eingebettete appsettings.json (empfohlen):**

1. Erstelle `appsettings.json` im MAUI-Projekt:
```json
{
  "EmailConfiguration": {
    "Host": "server-1.net",
    "Port": 587,
    "Username": "noreply@server-1.net",
    "Password": "",
    "From": "noreply@server-1.net",
    "Name": "Admin",
    "EnableSSL": true,
    "SiteName": "MeinPortal"
  }
}
```

2. In `.csproj` als Embedded Resource markieren:
```xml
<ItemGroup>
  <EmbeddedResource Include="appsettings.json" />
</ItemGroup>
```

3. In `MauiProgram.cs` laden:
```csharp
using Microsoft.Extensions.Configuration;
using System.Reflection;

var builder = MauiApp.CreateBuilder();

// Konfiguration aus eingebetteter appsettings.json laden
var assembly = Assembly.GetExecutingAssembly();
using var stream = assembly.GetManifestResourceStream("YourNamespace.appsettings.json");

var configuration = new ConfigurationBuilder()
    .AddJsonStream(stream!)
    .Build();

builder.Services.Configure<EmailConfiguration>(
    configuration.GetSection("EmailConfiguration"));

builder.Services.AddSingleton<SharedNamespace.Services.IEmailSender, SharedNamespace.Services.EmailSender>();
```

**Option B - Umgebungsvariablen (für sensible Daten in Production):**
```csharp
builder.Services.Configure<EmailConfiguration>(config =>
{
    config.Host = Environment.GetEnvironmentVariable("EMAIL_HOST") ?? "server-1.net";
    config.Port = int.Parse(Environment.GetEnvironmentVariable("EMAIL_PORT") ?? "587");
    config.Username = Environment.GetEnvironmentVariable("EMAIL_USERNAME") ?? "noreply@server-1.net";
    config.From = Environment.GetEnvironmentVariable("EMAIL_FROM") ?? "noreply@server-1.net";
    config.EnableSSL = true;
    config.SiteName = "[Insert Project Name Here]";
});
```

### WPF / WinForms / MAUI Windows

**In `App.xaml.cs` (WPF) oder `Program.cs` (WinForms):**

```csharp
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using YourNamespace.Models;
using YourNamespace.Services;

// ServiceCollection erstellen
var services = new ServiceCollection();

// Konfiguration laden (falls appsettings.json verwendet wird)
var configuration = new ConfigurationBuilder()
    .SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .Build();

services.Configure<EmailConfiguration>(configuration.GetSection("EmailConfiguration"));

// Logging hinzufügen
services.AddLogging(builder => builder.AddDebug());

// EmailSender registrieren
services.AddSingleton<IEmailSender, EmailSender>();

// ServiceProvider bauen
var serviceProvider = services.BuildServiceProvider();

// Verwendung:
var emailSender = serviceProvider.GetRequiredService<IEmailSender>();
await emailSender.SendEmailAsync("test@example.com", "Test", "<p>Test-Nachricht</p>");
```

**Für appsettings.json Support** (zusätzliches NuGet):
```bash
dotnet add package Microsoft.Extensions.Configuration.Json --version 10.0.0
```

### Console App / Background Service

**In `Program.cs`:**

```csharp
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Configuration;
using YourNamespace.Models;
using YourNamespace.Services;

var builder = Host.CreateApplicationBuilder(args);

// Email-Konfiguration
builder.Services.Configure<EmailConfiguration>(
    builder.Configuration.GetSection("EmailConfiguration"));

// EmailSender registrieren
builder.Services.AddSingleton<IEmailSender, EmailSender>();

var host = builder.Build();

// Verwendung:
var emailSender = host.Services.GetRequiredService<IEmailSender>();
await emailSender.SendEmailAsync("test@example.com", "Test", "<p>Test-Nachricht</p>");

await host.RunAsync();
```

## Schritt 7: Verwendung

### Basis Email-Versand (Szenario A)

**In Controller/Service:**
```csharp
public class ContactController : Controller
{
    private readonly IEmailSender _emailSender;

    public ContactController(IEmailSender emailSender)
    {
        _emailSender = emailSender;
    }

    [HttpPost]
    public async Task<IActionResult> SendMessage(EmailMessage model)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        await _emailSender.SendEmailAsync(
            model.Email, 
            model.Subject, 
            $"<p>{model.Message}</p>"
        );

        return Ok("E-Mail erfolgreich gesendet");
    }
}
```

### Identity Email-Integration (Szenario B)

**Erkenne ob Identity bereits im Projekt vorhanden:**
```bash
grep -r "AddIdentityCore\\|AddDefaultIdentity" **/*.cs
```

**Falls Identity vorhanden:**
```
✅ ASP.NET Core Identity erkannt!
Möchtest du die Email-Bestätigung aktivieren?

Dies ersetzt den Dummy-EmailSender und aktiviert:
- Email-Bestätigung bei Registrierung
- Passwort-Reset per Email
- Email-basierte 2FA

Dieser Schritt ruft automatisch auf: jw-activate-emailconfirmation.prompt
[Ja/Nein]
```

**Falls JA gewählt:**
```
➡️ Führe aus: jw-activate-emailconfirmation.prompt
```

**Falls Identity NICHT vorhanden:**
```
ℹ️ Kein Identity-System erkannt.
Der EmailSender ist jetzt für Formulare und Benachrichtigungen bereit.

Möchtest du ASP.NET Core Identity mit Passkey-Support hinzufügen?
➡️ Siehe: jw-add-accounts-with-passkeys-webauthn.prompt.md
```

## Schritt 8: Testen mit Blazor-Komponente

**Erstelle eine neue Razor-Komponente `Components/Pages/TestEmail.razor`** für den Test des Email-Service:

```csharp
@page "/test-email"
@rendermode InteractiveServer
@using YourNamespace.Services
@using YourNamespace.Models
@using Microsoft.Extensions.Options
@inject IEmailSender EmailSender
@inject IOptions<EmailConfiguration> EmailConfig

<PageTitle>Test-Email</PageTitle>

<div class="container mt-5">
    <h1>Email-Service Test</h1>

    <div class="card">
        <div class="card-body">
            <p><strong>Sender (From):</strong> <code>@EmailConfig.Value.From</code></p>
            <p><strong>Empfänger:</strong> <code>@EmailConfig.Value.From</code></p>
            
            <button class="btn btn-primary" @onclick="SendTestEmail" disabled="@isSending">
                @if (isSending)
                {
                    <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
                    <span>Sende...</span>
                }
                else
                {
                    <span>Test-Email senden</span>
                }
            </button>

            @if (!string.IsNullOrEmpty(message))
            {
                <div class="alert alert-@(isSuccess ? "success" : "danger") mt-3" role="alert">
                    <strong>@(isSuccess ? "✅ Erfolg" : "❌ Fehler"):</strong> @message
                </div>
            }
        </div>
    </div>
</div>

@code {
    private bool isSending = false;
    private string message = string.Empty;
    private bool isSuccess = false;

    private async Task SendTestEmail()
    {
        isSending = true;
        message = string.Empty;
        isSuccess = false;

        try
        {
            await EmailSender.SendEmailAsync(
                EmailConfig.Value.From,
                "Test-Email",
                "<h1>Test</h1><p>Dies ist eine Test-E-Mail vom EmailService.</p>"
            );

            message = $"Testmail an {EmailConfig.Value.From} erfolgreich gesendet.";
            isSuccess = true;
        }
        catch (Exception ex)
        {
            message = $"Fehler beim Versenden: {ex.Message}";
            isSuccess = false;
        }
        finally
        {
            isSending = false;
        }
    }
}
```

**WICHTIG - Best Practices für Test-Komponenten:**
- ✅ Test-Komponente als **eigenständige `.razor`-Datei** (nicht in `Program.cs`)
- ✅ **`@rendermode InteractiveServer` ist ERFORDERLICH** - ohne diese Direktive funktionieren Event-Handler nicht!
- ✅ Nutze **echte SMTP-Konfiguration** (nicht test@example.com)
- ✅ Sende an **From-Adresse** (`noreply@server-1.net`) - validiert SMTP-Setup
- ✅ Zeige **aussagekräftige Rückmeldung**: "Testmail an [From] erfolgreich gesendet."
- ✅ Fehler werden **direkt angezeigt** (z.B. Authentifizierungsprobleme)

**Test durchführen:**
```powershell
# App starten
dotnet run --project MyEmailPormptsTester/MyEmailPormptsTester

# Im Browser öffnen: https://localhost:7209/test-email
# Klick auf "Test-Email senden"
```

## Troubleshooting

### Problem: "Authentication failed"
- **Lösung:** Prüfe, ob Umgebungsvariable `PASSWORT_NOREPLY_SERVER-1` gesetzt ist
- **Prüfen (PowerShell):** `[System.Environment]::GetEnvironmentVariable('PASSWORT_NOREPLY_SERVER-1', 'User')`

### Problem: "SMTP server connection failed"
- **Lösung:** Prüfe Firewall-Regeln für Port 587
- **Lösung:** Teste mit `telnet server-1.net 587`

### Problem: Identity sendet keine Emails
- **Lösung:** Stelle sicher, dass `IdentityEmailSender` als **Singleton** registriert ist
- **Lösung:** Prüfe, dass `IServiceScopeFactory` verwendet wird, um Scoped Services aufzulösen

### Problem: Emails landen im Spam
- **Lösung:** Konfiguriere SPF/DKIM/DMARC Records für `server-1.net`
- **Lösung:** Verwende einen dedizierten SMTP-Server mit guter Reputation

## Checkliste

- [ ] MailKit & MimeKit NuGet Pakete installiert
- [ ] `EmailConfiguration` Model erstellt
- [ ] `IEmailSender` Interface erstellt
- [ ] `EmailSender` Implementierung erstellt
- [ ] `appsettings.json` mit SMTP-Daten konfiguriert
- [ ] Umgebungsvariable `PASSWORT_NOREPLY_SERVER-1` gesetzt (Dev & Produktion)
- [ ] DI in `Program.cs` konfiguriert
- [ ] (Szenario B) `IdentityEmailSender` erstellt und registriert
- [ ] (Szenario B) `RequireConfirmedAccount = true` gesetzt
- [ ] Test-Email erfolgreich versendet

## Produktions-Hinweise

1. **Umgebungsvariable auf Server setzen:**
   - Azure App Service: Application Settings → `PASSWORT_NOREPLY_SERVER-1`
   - IIS: Server Manager → Environment Variables
   - Docker: `-e PASSWORT_NOREPLY_SERVER-1=password` oder docker-compose.yml

2. **Rate Limiting implementieren** (Spam-Schutz):
   ```csharp
   builder.Services.AddRateLimiter(options => { /* ... */ });
   ```

3. **Email-Queue** für große Mengen (z.B. Hangfire/Azure Service Bus)

4. **Monitoring & Logging:** Implementiere dedizierte Email-Logs für Fehlerbehebung
