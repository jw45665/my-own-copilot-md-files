# Copilot Instructions for DEL-APP (MAUI)

## Überblick & Architektur
- Dies ist eine .NET MAUI Cross-Plattform-App (Android, iOS, Windows, MacCatalyst, Tizen).
- Hauptlogik und UI befinden sich im Verzeichnis `MauiApp1/`.
- Plattform-spezifische Anpassungen liegen unter `MauiApp1/Platforms/` (z.B. Android, iOS, Windows).
- Einstiegspunkt: `MauiApp1/MauiProgram.cs` (Konfiguration, Dependency Injection), `App.xaml`/`App.xaml.cs` (App-Lifecycle), `AppShell.xaml` (Navigation).
- UI-Seiten: `MainPage.xaml`/`MainPage.xaml.cs` (Beispiel für Page-Pattern).

## Build, Test & Debug
- Standard-Build: Über Visual Studio oder `dotnet build` im Projektverzeichnis.
- Plattform-spezifische Builds: z.B. `dotnet build -f:net10.0-android` für Android.
- APKs und Artefakte: `MauiApp1/bin/Debug/net10.0-android/` (bzw. andere Plattformen).
- Debugging: Meist über Visual Studio, Breakpoints in C#-Dateien.
- Tests: Keine dedizierten Testdateien im Workspace gefunden (Stand: August 2025).

## Projektkonventionen & Patterns
- UI-Logik wird in `.xaml` (UI) und `.xaml.cs` (Code-Behind) getrennt.
- Ressourcen (Bilder, Fonts, Styles) unter `MauiApp1/Resources/`.
- Farben und Styles: `MauiApp1/Resources/Styles/` (z.B. `Colors.xaml`).
- Navigation erfolgt über `AppShell.xaml` (Shell-Navigation-Pattern von MAUI).
- Plattform-spezifische Einstellungen: z.B. `AndroidManifest.xml`, `Info.plist`, `app.manifest`.

## Integration & Abhängigkeiten
- Externe Abhängigkeiten werden über NuGet in der `.csproj` verwaltet.
- Keine offensichtlichen externen Services oder APIs im aktuellen Stand.
- Plattformübergreifende Features werden über MAUI-APIs implementiert.

## Beispiele & Hinweise
- Neue Seiten: Im `MauiApp1/`-Verzeichnis als `.xaml`/`.xaml.cs` anlegen und in `AppShell.xaml` registrieren.
- Ressourcen wie Bilder in `MauiApp1/Resources/Images/` ablegen und im XAML via `{ImageSource ...}` referenzieren.
- Für plattformspezifische Features: Entsprechende Datei in `Platforms/<Plattform>/` anpassen.

## Wichtige Dateien/Verzeichnisse
- `MauiApp1/MauiProgram.cs` – App-Konfiguration, DI
- `MauiApp1/AppShell.xaml` – Navigation
- `MauiApp1/Resources/` – Assets, Styles, Fonts
- `MauiApp1/Platforms/` – Plattform-spezifische Anpassungen

## Projektspezifische Vorgaben
- Interaktionen müssen sowohl über Buttons und Wischgesten (Mobile Geräte) als auch über Tastatureingaben (Desktop-Geräte zusätzlich Pfeiltasten, etc.) erfolgen.
- Die Anwendung muss Light- und Dark-Mode unterstützen.

## Sonstiges
- Halte dich an die MAUI-typischen Patterns und Strukturen.

---

*Bitte Feedback geben, falls wichtige Workflows, Konventionen oder Integrationen fehlen!*