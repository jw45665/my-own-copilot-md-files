---
title: Activate Email Confirmation for ASP.NET Core Identity
version: 1.0
date_created: 2026-01-22
last_updated: 2026-01-22
owner: jw45665
tags: [process, identity, email-confirmation, security, authentication, dotnet10]
---

# Email-Bestätigung für ASP.NET Core Identity aktivieren

Dieser Prompt ersetzt den Dummy-EmailSender (`IdentityNoOpEmailSender`) durch einen echten Email-Service und aktiviert Email-Bestätigung für Benutzerkonten.

## Voraussetzungen

**WICHTIG:** Dieser Prompt erfordert:
- ✅ ASP.NET Core Identity bereits installiert
- ✅ Email-Service implementiert (siehe `jw-add-emailsender.prompt.md`)
- ✅ `IEmailSender` Interface vorhanden
- ✅ SMTP-Konfiguration funktionsfähig

## Schritt 1: Voraussetzungen prüfen

**Prüfe ob Identity vorhanden:**
```bash
grep -r "AddIdentityCore\\|AddDefaultIdentity" **/*.cs
```

**Falls NICHT vorhanden:**
```
❌ ASP.NET Core Identity nicht gefunden!

Dieser Prompt erfordert ein bestehendes Identity-System.
Möchtest du Identity mit Passkey-Support hinzufügen?

➡️ Führe aus: jw-add-accounts-with-passkeys-webauthn.prompt.md
[Abbrechen]
```

**Prüfe ob EmailSender vorhanden:**
```bash
grep -r "interface IEmailSender" **/*.cs
```

**Falls NICHT vorhanden:**
```
❌ Email-Service nicht gefunden!

Dieser Prompt erfordert einen konfigurierten Email-Service.
Soll ich diesen jetzt hinzufügen?

➡️ Führe aus: jw-add-emailsender.prompt.md
[Ja/Abbrechen]
```

## Schritt 2: IdentityEmailSender erstellen

**Erstelle `Services/IdentityEmailSender.cs` oder `Components/Account/IdentityEmailSender.cs`:**

**WICHTIG:** Diese Klasse ist ein **Adapter**, der vom Identity-Framework automatisch aufgerufen wird.
- Die Methoden werden **NICHT manuell aufgerufen**
- `confirmationLink` und `resetCode` werden vom Framework generiert
- Hash-Werte zur Verifizierung sind bereits enthalten

```csharp
using Microsoft.AspNetCore.Identity;
using YourNamespace.Data; // ApplicationUser
using YourNamespace.Services; // IEmailSender

namespace YourNamespace.Services // ODER YourNamespace.Components.Account
{
    /// <summary>
    /// Adapter für ASP.NET Core Identity - wird automatisch vom Framework aufgerufen.
    /// Verbindet Identity mit dem EmailSender-Service.
    /// </summary>
    internal sealed class IdentityEmailSender : IEmailSender<ApplicationUser>
    {
        private readonly IServiceScopeFactory _serviceScopeFactory;

        /// <summary>
        /// Nutzt IServiceScopeFactory, um Scoped Services aus einem Singleton aufzulösen.
        /// WICHTIG: IdentityEmailSender wird als Singleton registriert!
        /// </summary>
        public IdentityEmailSender(IServiceScopeFactory serviceScopeFactory)
        {
            _serviceScopeFactory = serviceScopeFactory;
        }

        /// <summary>
        /// Wird vom Identity-Framework bei Registrierung aufgerufen.
        /// confirmationLink enthält den generierten Token-Hash.
        /// </summary>
        public async Task SendConfirmationLinkAsync(ApplicationUser user, string email, string confirmationLink)
        {
            using var scope = _serviceScopeFactory.CreateScope();
            var emailSender = scope.ServiceProvider.GetRequiredService<IEmailSender>();
            
            await emailSender.SendEmailAsync(
                email, 
                "Bestätigen Sie Ihre E-Mail-Adresse", 
                $"<div style='font-family: sans-serif; max-width: 600px;'>" +
                $"<h2>Willkommen!</h2>" +
                $"<p>Hallo <strong>{user.Email}</strong>,</p>" +
                $"<p>vielen Dank für Ihre Registrierung. Bitte bestätigen Sie Ihre E-Mail-Adresse, " +
                $"um Ihr Konto zu aktivieren.</p>" +
                $"<p style='text-align: center; margin: 30px 0;'>" +
                $"<a href='{confirmationLink}' style='background-color: #007bff; color: white; padding: 12px 24px; " +
                $"text-decoration: none; border-radius: 4px; display: inline-block;'>E-Mail bestätigen</a></p>" +
                $"<p style='color: #666; font-size: 0.9em;'>Falls Sie sich nicht registriert haben, ignorieren Sie diese E-Mail.</p>" +
                $"<p>Mit freundlichen Grüßen,<br>Ihr Team</p>" +
                $"</div>"
            );
        }

        /// <summary>
        /// Wird bei Passwort-Vergessen aufgerufen.
        /// resetLink enthält den generierten Reset-Token.
        /// </summary>
        public async Task SendPasswordResetLinkAsync(ApplicationUser user, string email, string resetLink)
        {
            using var scope = _serviceScopeFactory.CreateScope();
            var emailSender = scope.ServiceProvider.GetRequiredService<IEmailSender>();
            
            await emailSender.SendEmailAsync(
                email, 
                "Passwort zurücksetzen", 
                $"<div style='font-family: sans-serif; max-width: 600px;'>" +
                $"<h2>Passwort zurücksetzen</h2>" +
                $"<p>Hallo <strong>{user.Email}</strong>,</p>" +
                $"<p>Sie haben eine Anfrage zum Zurücksetzen Ihres Passworts gestellt.</p>" +
                $"<p style='text-align: center; margin: 30px 0;'>" +
                $"<a href='{resetLink}' style='background-color: #dc3545; color: white; padding: 12px 24px; " +
                $"text-decoration: none; border-radius: 4px; display: inline-block;'>Passwort zurücksetzen</a></p>" +
                $"<p style='color: #666; font-size: 0.9em;'>Dieser Link ist 24 Stunden gültig.</p>" +
                $"<p style='color: #dc3545; font-size: 0.9em;'><strong>Falls Sie diese Anfrage nicht gestellt haben, " +
                $"ignorieren Sie diese E-Mail. Ihr Passwort bleibt unverändert.</strong></p>" +
                $"<p>Mit freundlichen Grüßen,<br>Ihr Team</p>" +
                $"</div>"
            );
        }

        /// <summary>
        /// Alternative zu SendPasswordResetLinkAsync - verwendet Code statt Link.
        /// resetCode ist ein kurzer numerischer Code.
        /// </summary>
        public async Task SendPasswordResetCodeAsync(ApplicationUser user, string email, string resetCode)
        {
            using var scope = _serviceScopeFactory.CreateScope();
            var emailSender = scope.ServiceProvider.GetRequiredService<IEmailSender>();
            
            await emailSender.SendEmailAsync(
                email, 
                "Passwort zurücksetzen - Sicherheitscode", 
                $"<div style='font-family: sans-serif; max-width: 600px;'>" +
                $"<h2>Passwort zurücksetzen</h2>" +
                $"<p>Hallo <strong>{user.Email}</strong>,</p>" +
                $"<p>Sie haben eine Anfrage zum Zurücksetzen Ihres Passworts gestellt.</p>" +
                $"<p>Verwenden Sie folgenden Sicherheitscode:</p>" +
                $"<div style='text-align: center; margin: 30px 0;'>" +
                $"<div style='background-color: #f8f9fa; border: 2px solid #007bff; border-radius: 8px; " +
                $"padding: 20px; display: inline-block;'>" +
                $"<span style='font-size: 32px; font-weight: bold; letter-spacing: 4px; color: #007bff;'>{resetCode}</span>" +
                $"</div>" +
                $"</div>" +
                $"<p style='color: #666; font-size: 0.9em;'>Dieser Code ist 15 Minuten gültig.</p>" +
                $"<p style='color: #dc3545; font-size: 0.9em;'><strong>Falls Sie diese Anfrage nicht gestellt haben, " +
                $"ignorieren Sie diese E-Mail.</strong></p>" +
                $"<p>Mit freundlichen Grüßen,<br>Ihr Team</p>" +
                $"</div>"
            );
        }
    }
}
```

## Schritt 3: Automatische Datenbank-Migration konfigurieren

**Füge automatische EF-Migration in `Program.cs` hinzu:**

Diese Konfiguration stellt sicher, dass die Datenbank und alle Identity-Tabellen beim Start automatisch erstellt/aktualisiert werden.

**Finde in `Program.cs` die Zeile:**
```csharp
var app = builder.Build();
```

**Füge DIREKT NACH `app.Build()` hinzu:**
```csharp
var app = builder.Build();

// Automatische Datenbank-Migration beim Start
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    db.Database.Migrate();
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
```

**Vorteile:**
- ✅ Keine manuellen `dotnet ef database update` Aufrufe nötig
- ✅ Datenbank wird automatisch erstellt/aktualisiert
- ✅ Identity-Tabellen (AspNetUsers, AspNetRoles, AspNetUserPasskeys, etc.) werden automatisch angelegt
- ✅ Ideal für CI/CD-Pipelines und erste Deployments
- ✅ Funktioniert mit LocalDB, SQL Server, PostgreSQL, etc.

**Produktions-Hinweis:** Für kritische Produktions-Deployments kann eine separate Migration-Pipeline mit Rollback-Strategie sicherer sein. Für die meisten Anwendungsfälle ist automatische Migration jedoch ausreichend.

## Schritt 4: DI-Registrierung in Program.cs

**Finde die Identity-Konfiguration in `Program.cs`:**
```bash
grep -A 10 "AddIdentityCore\\|AddDefaultIdentity" **/Program.cs
```

**Füge NACH der Identity-Konfiguration hinzu:**

```csharp
// Email-Bestätigung aktivieren
builder.Services.AddIdentityCore<ApplicationUser>(options => 
{
    options.SignIn.RequireConfirmedAccount = true; // ⭐ Email-Bestätigung aktivieren
    options.Stores.SchemaVersion = IdentitySchemaVersions.Version3; // Für .NET 10
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddSignInManager()
.AddDefaultTokenProviders(); // WICHTIG: Für Token-Generierung

// ⭐ Identity EmailSender registrieren (als Singleton!)
// WICHTIG: Muss NACH AddIdentityCore, aber VOR MapIdentityApi
builder.Services.AddSingleton<IEmailSender<ApplicationUser>, IdentityEmailSender>();
```

**Oder falls `AddDefaultIdentity` verwendet wird:**
```csharp
builder.Services.AddDefaultIdentity<ApplicationUser>(options => 
{
    options.SignIn.RequireConfirmedAccount = true; // ⭐ Email-Bestätigung aktivieren
})
.AddEntityFrameworkStores<ApplicationDbContext>();

// ⭐ Identity EmailSender registrieren
builder.Services.AddSingleton<IEmailSender<ApplicationUser>, IdentityEmailSender>();
```

## Schritt 5: Dummy-EmailSender entfernen

**Suche nach `IdentityNoOpEmailSender`:**
```bash
grep -r "IdentityNoOpEmailSender" **/*.cs
```

**Falls gefunden - Entfernen:**
```csharp
// ALT (entfernen):
builder.Services.AddSingleton<IEmailSender<ApplicationUser>, IdentityNoOpEmailSender>();
```

**Oder in separater Datei (löschen):**
```bash
rm Services/IdentityNoOpEmailSender.cs
# ODER
rm Components/Account/IdentityNoOpEmailSender.cs
```

## Schritt 6: Login-Seite anpassen (optional)

**Falls Dev-Modus "Quick-Confirm" vorhanden ist, entfernen:**

**Suche in `Components/Account/Pages/RegisterConfirmation.razor` oder ähnlich:**
```bash
grep -r "Click here to confirm your account" **/*.razor
```

**Entferne Dev-Bypass-Code wie:**
```razor
@* ALT - NUR FÜR DEV (entfernen für Produktion): *@
<a href="@confirmLink">Click here to confirm your account</a>
```

## Schritt 7: Testen

### Test-Registrierung:

1. **Starte die Anwendung:**
```bash
dotnet run
```

2. **Registriere neuen Benutzer:**
- Navigiere zu `/Account/Register`
- Fülle Formular aus
- Klicke auf "Register"

3. **Prüfe Email-Eingang:**
- ✅ Bestätigungs-Email erhalten?
- ✅ Link klickbar?
- ✅ HTML korrekt formatiert?
- ✅ SiteName im Betreff?

4. **Klicke Bestätigungs-Link:**
- ✅ Account wird aktiviert
- ✅ Login möglich

### Test-Passwort-Reset:

1. **Navigiere zu `/Account/ForgotPassword`**
2. **Gib Email ein**
3. **Prüfe Email mit Reset-Link**
4. **Setze neues Passwort**

## Schritt 8: Datenbank prüfen

**Prüfe ob Benutzer bestätigt wurde:**
```sql
SELECT Id, Email, EmailConfirmed, UserName 
FROM AspNetUsers 
ORDER BY Id DESC;
```

**Erwartetes Ergebnis:**
- `EmailConfirmed = 1` nach Bestätigung
- `EmailConfirmed = 0` vor Bestätigung

## Troubleshooting

### Problem: "No service for type IEmailSender<ApplicationUser>"
**Ursache:** `IdentityEmailSender` nicht registriert oder falsche Reihenfolge

**Lösung:**
```csharp
// Muss als Singleton registriert werden!
builder.Services.AddSingleton<IEmailSender<ApplicationUser>, IdentityEmailSender>();
```

### Problem: Email wird nicht versendet
**Ursache:** Basis-EmailSender nicht korrekt konfiguriert

**Lösung:**
```bash
# Teste Basis-EmailSender einzeln
➡️ Siehe: jw-add-emailsender.documentation.md
```

### Problem: "Cannot resolve scoped service from root provider"
**Ursache:** `IEmailSender` ist Scoped, aber `IdentityEmailSender` ist Singleton

**Lösung:** Genau deswegen nutzt `IdentityEmailSender` `IServiceScopeFactory`!
Prüfe, ob Implementierung korrekt ist.

### Problem: "Database does not exist" beim ersten Start
**Ursache:** Datenbank wurde noch nicht erstellt

**Lösung:** Mit automatischer Migration (Schritt 3) wird die Datenbank beim ersten Start automatisch erstellt. Alternativ manuell:
```bash
dotnet ef database update
```

### Problem: Login funktioniert nicht nach Registrierung
**Ursache:** `RequireConfirmedAccount = true` aktiv, aber Email nicht bestätigt

**Erwartetes Verhalten:** Das ist korrekt! Benutzer muss Email bestätigen.

**Für Dev-Tests:**
```csharp
// NUR FÜR DEV (nicht in Produktion!):
options.SignIn.RequireConfirmedAccount = !builder.Environment.IsDevelopment();
```

## Erfolgs-Kriterien

- [ ] Automatische Datenbank-Migration in `Program.cs` konfiguriert
- [ ] `IdentityEmailSender.cs` erstellt
- [ ] In `Program.cs` als Singleton registriert
- [ ] `RequireConfirmedAccount = true` gesetzt
- [ ] Dummy-EmailSender entfernt
- [ ] Test-Registrierung: Email erhalten
- [ ] Email-Bestätigung funktioniert
- [ ] Login nach Bestätigung möglich
- [ ] Passwort-Reset getestet

## Checkliste

- [ ] Voraussetzungen geprüft (Identity + EmailSender vorhanden)
- [ ] Automatische Datenbank-Migration konfiguriert (db.Database.Migrate())
- [ ] `IdentityEmailSender.cs` erstellt mit allen 3 Methoden
- [ ] DI-Registrierung korrekt (Singleton + IServiceScopeFactory)
- [ ] `RequireConfirmedAccount = true` aktiviert
- [ ] Dummy-EmailSender entfernt
- [ ] Dev-Bypass-Code entfernt
- [ ] Test-Registrierung erfolgreich
- [ ] Email-Bestätigung funktioniert
- [ ] Passwort-Reset funktioniert
- [ ] Datenbank `EmailConfirmed = 1` nach Bestätigung

## Weiterführende Prompts

- **Passkey-Support:** `jw-add-accounts-with-passkeys-webauthn.prompt.md`
- **API-Endpoints:** `jw-add-api-endpoints-bearer-auth.prompt.md`
- **2FA:** `jw-add-2fa-totp.prompt.md`
- **Rate Limiting:** `jw-add-rate-limiting.prompt.md`

## Referenzen

- [ASP.NET Core Identity Email Confirmation](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/accconfirm)
- [IEmailSender<TUser> Interface](https://learn.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.identity.ui.services.iemailsender)
