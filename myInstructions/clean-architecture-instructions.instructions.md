# Clean Architecture Instructions für Promptkatalog

Diese Instruction beschreibt den hier verwendeten Solution-Aufbau und die Projektschichten so genau, dass andere Agenten ihn bei der Projektgenerierung nachbilden können.

## Lösungstyp

Die Solution folgt einem mehrschichtigen Clean-Architecture-ähnlichen Muster mit klar getrennten Schichten:

- `Promptkatalog.Core` – Domäne und Business-Logik
- `Promptkatalog.Data` – Infrastruktur, EF Core, Datenbankzugriff
- `Promptkatalog.Web` – Präsentation, Blazor Server UI, Dependency Injection, HTTP-Endpunkte
- `Promptkatalog.Shared` – wiederverwendbare UI-Komponenten und gemeinsame Razor-Bibliothek

Diese Architektur ist keineswegs ein einfaches Blazor-Template, sondern eine `layered`/`Clean Architecture`-Architektur mit strikter Abwärtsabhängigkeit: Außen liegende Schichten dürfen innen liegende Schichten verwenden, nicht aber umgekehrt.

## Projektrollen und Abhängigkeiten

### Promptkatalog.Core

- Enthält `Entities`, `Enums`, `Interfaces` und reine Domänenklassen.
- Keine Infrastruktur- oder UI-Abhängigkeiten.
- Ziel: `net10.0`.
- Referenzen: keine projektspezifischen Referenzen außer systemischen .NET-Paketen.

### Promptkatalog.Data

- Enthält `Context`, EF Core `DbContext`, `Migrations`, `Seed` und `Services`.
- Implementiert die `Core.Interfaces` mit Repositories/Services wie `UserProfileService`, `PromptService`, `CategoryService` usw.
- Referenziert `Promptkatalog.Core`.
- Enthält `Microsoft.EntityFrameworkCore`, `Microsoft.EntityFrameworkCore.SqlServer`, `Microsoft.EntityFrameworkCore.Design`.
- Verwaltet Datenbankobjekte und Migrationen, aber keine UI-Komponenten.

### Promptkatalog.Shared

- Enthält gemeinsame Razor-Komponenten, CSS, Scripts und Ressourcen, die von der Web-App wiederverwendet werden.
- Beispiel: `PromptRating.razor`, `_Imports.razor`, `wwwroot/exampleJsInterop.js`.
- Referenziert keine Infrastruktur oder Datenzugriff.
- Ziel: `net10.0`.

### Promptkatalog.Web

- Blazor Server App mit UI, Routing, Layout, Page-Komponenten und App-Start.
- Enthält `Program.cs`, `_Host.cshtml`, `App.razor`, `Shared/MainLayout.razor`, `Shared/NavMenu.razor`, Seite `Profil.razor` usw.
- Referenziert `Promptkatalog.Core`, `Promptkatalog.Data`, `Promptkatalog.Shared`.
- Registriert Services, EF Core DbContextFactory, Syncfusion Blazor, Localization, Razor Pages, Blazor Server.
- Hier wird auch die AuthCore-Integration umgesetzt, da sie UI und Service-Integration betrifft.

## Architekturprinzipien für Agenten

1. **Abhängigkeitsrichtung**
   - `Web` -> `Data` -> `Core`
   - `Shared` ist eine einmalige, unabhängige UI-Bibliothek und darf von `Web` genutzt werden.
   - Keiner der inneren Layer darf auf `Web` verweisen.

2. **Domäne in Core**
   - Alle Entities, Value Objects und Interfaces verbleiben in `Core`.
   - Keine `DbContext`- oder UI-Logik in `Core`.

3. **Datenzugriff in Data**
   - EF Core `DbContext` und Services leben in `Data`.
   - `Data` implementiert die Interfaces aus `Core`.
   - `Data` kapselt Migrations, Seed-Daten und Datenbankrelationen.

4. **UI in Web**
   - Blazor-Seiten, Komponenten, Layout, Navigation, Theme-Loader, Authentifizierung und Authorisierungslogik gehören in `Web`.
   - `Web` darf `Shared`-Komponenten nutzen, aber nicht umgekehrt.

5. **Shared-Komponenten**
   - UI-Funktionalität, die in mehreren Apps oder Seiten wiederverwendet werden soll, gehört nach `Shared`.
   - Das können Syncfusion-Komponenten-Hüllen, gemeinsame Styles oder generische Blazor-Komponenten sein.

## Spezifische Hinweise zur aktuellen Solution

- `Program.cs` in `Promptkatalog.Web` verwendet `AddDbContextFactory<PromptDbContext>()` statt `AddDbContext()` für Blazor Server Concurrency-Sicherheit.
- Syncfusion wird zentral über `builder.Services.AddSyncfusionBlazor()` registriert.
- Lokalisierung ist bereits eingerichtet mit `builder.Services.AddLocalization(options => options.ResourcesPath = "")` und `app.UseRequestLocalization(...)`.
- Die App verwendet ein Top-Navigation-Layout mit Syncfusion `SfAppBar` und Theme-Switcher.
- `Promptkatalog.Data` enthält ein eigenes `PromptDbContext`, Seed-Daten und mehrere spezialisierte Services.

## Umsetzungsempfehlung für AuthCore

- Authentifizierung und die Integration der externen AuthCore API gehören in `Promptkatalog.Web`.
- `Promptkatalog.Core` kann weiterhin das `UserProfile`-Domain-Modell liefern, das AuthCore-IDs referenziert.
- `Promptkatalog.Data` bleibt zuständig für lokales Profil-Mapping, Nutzerdaten, Punkte und Badges.
- Die UI-Logik für Login / Registrierung / Profilpflege sollte in `Web` als Blazor-Seiten oder Komponenten implementiert werden.

## Agenten-Leitfaden

Wenn ein Agent diese Solution generiert, soll er:

1. Eine Solution mit vier Projekten anlegen: `Promptkatalog.Core`, `Promptkatalog.Data`, `Promptkatalog.Shared`, `Promptkatalog.Web`.
2. `Promptkatalog.Core` nur mit Domain-Klassen, Interfaces und Enums füllen.
3. `Promptkatalog.Data` so aufbauen, dass es `Core` referenziert und EF Core sowie Migrationen enthält.
4. `Promptkatalog.Shared` als Razor-Komponenten-Bibliothek mit gemeinsamen UI-Bausteinen einrichten.
5. `Promptkatalog.Web` als Blazor Server App einrichten und dort UI, Routing, Theme-System, Syncfusion, Lokalisierung und externen AuthCore-Client implementieren.
6. Sicherstellen, dass nur `Web` Syncfusion-Pakete referenziert.

## Fazit

Diese Solution entspricht einer Clean-Architecture / Layered-Architecture, die für Blazor Server mit EF Core und einem externen Identity-Service geeignet ist. Sie lässt sich reproduzieren, indem man den Fokus auf die klaren Projektgrenzen zwischen Domäne, Infrastruktur, wiederverwendbarer UI und Präsentation legt.
