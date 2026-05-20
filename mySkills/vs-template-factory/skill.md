---
name: vs-template-factory
description: Erstellt robuste Visual-Studio-Projekt- und Item-Templates aus bestehenden Projekten/Lösungen, installiert sie ausschließlich unter V:\Visual Studio 18\Templates\ProjectTemplates und validiert die Funktionsfähigkeit.
---

# VS Template Factory (Skill)

## Zweck
Dieser Skill befähigt Agenten, aus vorhandenen Projekten oder Projektmappen funktionsfähige Visual-Studio-Templates zu erzeugen, zu installieren, zu validieren und zu dokumentieren.

## Verbindliche Systemregeln

### Ablageorte
- **Staging-Verzeichnis:** `V:\2026_Projects\Start-Templates\VS-Template-Output\<TemplateName>\`
- **ZIP-Ausgabe:** `V:\2026_Projects\Start-Templates\VS-Template-Output\<TemplateName>.zip`
- **VS-Systemverzeichnis (alle Benutzer):** `V:\Visual Studio 18\Templates\ProjectTemplates\`
- **VS-Benutzerverzeichnis:** `%USERPROFILE%\Documents\Visual Studio 2026\Templates\ProjectTemplates\`
- **Roaming-Cache (manuell befüllen!):** `%APPDATA%\Microsoft\VisualStudio\18.0_<instanceId>\ProjectTemplatesCache\<TemplateName>.zip\`
- Keine weiteren Template-Verzeichnisse anlegen.

### Kritisch: Roaming-Cache
VS 18 liest Template-Dateien **nicht direkt aus der ZIP**, sondern aus einem **entpackten Cache-Ordner**:

```
%APPDATA%\Microsoft\VisualStudio\18.0_<instanceId>\ProjectTemplatesCache\<TemplateName>.zip\
```

Dieser Ordner hat `.zip` als Erweiterung, ist aber ein **Verzeichnis**. Er wird von `devenv /installvstemplates` **nicht zuverlässig** neu befüllt. Daher muss er **immer manuell** angelegt und befüllt werden:

1. Cache-Ordner anlegen und befüllen (siehe Schritt 5)
2. ZIP zusätzlich in beide Template-Verzeichnisse kopieren (für Neuinstallationen)

VS-Instanz-ID ermitteln:

```powershell
Get-ChildItem "$env:APPDATA\Microsoft\VisualStudio" -Directory | Where-Object { $_.Name -like "18.0_*" }
```

### Kritisch: ProjectType
Nur `<ProjectType>CSharp</ProjectType>` erscheint zuverlässig im NPD-Cache (New Project Dialog).
`CPS`, `JavaScript` und andere Werte werden von VS 18 für benutzerdefinierte Templates ignoriert oder übergangen.
Der `ProjectType` ist reines Kategorisierungs-Metadatum – das eigentliche Projektsystem wird durch die Projektdatei (`.esproj`, `.csproj` etc.) bestimmt.

### Kritisch: Pflichtumfang für alle Projekte
Bei Templates gilt projektübergreifend verbindlich:
- Das Verzeichnis `.github` wird **immer vollständig** übernommen.
- Enthalten sein müssen insbesondere Agenten-Anweisungen und Skills (z. B. `copilot-instructions.md`, `instructions/`, `skills/`).
- F5-Startkonfigurationen für VS Code und VS dürfen nicht entfernt werden (z. B. `.vscode/launch.json`, `.esproj`, `.sln`, `.slnx` wenn vorhanden).
- Skills gelten für alle Projekte; sie werden ausschließlich bedarfsbezogen aufgerufen.

## Icon und Preview-Bild

### Standardnamen
- Icon: `__TemplateIcon.png` (doppelter Unterstrich – VS 18-Konvention, max. 32×32 px empfohlen)
- Vorschaubild: `__PreviewImage.png` (doppelter Unterstrich – VS 18-Konvention, empfohlen 190×130 px)

> **Wichtig:** VS 18 erwartet den doppelten Unterstrich als Präfix (`__`). Dateien ohne dieses Präfix (z. B. `TemplateIcon.png`) werden im New Project Dialog **nicht angezeigt** – auch wenn sie korrekt in der `.vstemplate` referenziert und in der ZIP enthalten sind.

### Verhalten des Agenten
1. **Nutzer fragen**, ob er ein Icon und ein Vorschaubild bereitstellen möchte, und folgende Optionen anbieten:
   - Pfad zu einer vorhandenen Datei beliebigen Namens angeben
   - Template ohne Bilder erstellen (dann `<Icon>` und `<PreviewImage>` weglassen)
2. Bereitgestellte Dateien **umbenennen** und ins Staging kopieren – unabhängig vom Originalnamen:

```powershell
Copy-Item "<NutzerPfadIcon>"   "$staging\__TemplateIcon.png"  -Force
Copy-Item "<NutzerPfadPreview>" "$staging\__PreviewImage.png" -Force
```

3. Im `.vstemplate` mit den festen Zielnamen referenzieren:

```xml
<Icon>__TemplateIcon.png</Icon>
<PreviewImage>__PreviewImage.png</PreviewImage>
```

## Kritische `.vstemplate`-Regeln

### `<CreateInPlace>true</CreateInPlace>` ist Pflicht
Ohne dieses Element schlägt die Projekterstellung bei `.esproj`-Templates fehl (Dateien werden nicht gefunden).

### `<Folder>`-Strategie: Nur Dateiname als Quelle
Innerhalb eines `<Folder>`-Elements darf der `ProjectItem`-Quellpfad **ausschließlich den Dateinamen** enthalten – kein Ordnerpräfix:

```xml
<!-- RICHTIG -->
<Folder Name="src" TargetFolderName="src">
  <ProjectItem TargetFileName="main.tsx">main.tsx</ProjectItem>
</Folder>

<!-- FALSCH – erzeugt src\src\main.tsx -->
<Folder Name="src" TargetFolderName="src">
  <ProjectItem TargetFileName="main.tsx">src\main.tsx</ProjectItem>
</Folder>
```

### Cache-Ordnerstruktur muss der `.vstemplate`-Struktur entsprechen
Der Roaming-Cache-Ordner muss dieselbe Verzeichnisstruktur haben wie das Staging:
- `<cacheDir>\src\main.tsx` ? `<Folder Name="src"><ProjectItem>main.tsx</ProjectItem></Folder>`
- `<cacheDir>\public\web.config` ? `<Folder Name="public"><ProjectItem>web.config</ProjectItem></Folder>`

### Vollständiges `.vstemplate`-Beispiel (`.esproj`-Projekt)

```xml
<VSTemplate Version="3.0.0" xmlns="http://schemas.microsoft.com/developer/vstemplate/2005" Type="Project">
  <TemplateData>
    <Name>Mein Template</Name>
    <Description>Beschreibung des Templates.</Description>
    <ProjectType>CSharp</ProjectType>
    <ProjectSubType></ProjectSubType>
    <SortOrder>1000</SortOrder>
    <CreateNewFolder>true</CreateNewFolder>
    <CreateInPlace>true</CreateInPlace>
    <DefaultName>MeinProjekt</DefaultName>
    <ProvideDefaultName>true</ProvideDefaultName>
    <LocationField>Enabled</LocationField>
    <EnableLocationBrowseButton>true</EnableLocationBrowseButton>
    <Icon>__TemplateIcon.png</Icon>
    <PreviewImage>__PreviewImage.png</PreviewImage>
    <LanguageTag>TypeScript</LanguageTag>
    <PlatformTag>Web</PlatformTag>
  </TemplateData>
  <TemplateContent>
    <Project File="$safeprojectname$.esproj" ReplaceParameters="true">

      <!-- Root-Dateien: Quellpfad = Dateiname (liegt im Cache-Root) -->
      <ProjectItem ReplaceParameters="true" TargetFileName="index.html">index.html</ProjectItem>
      <ProjectItem ReplaceParameters="false" TargetFileName="package.json">package.json</ProjectItem>

      <!-- Unterordner: Quellpfad = nur Dateiname (kein Ordnerpräfix!) -->
      <Folder Name="src" TargetFolderName="src">
        <ProjectItem ReplaceParameters="false" TargetFileName="main.tsx">main.tsx</ProjectItem>
        <ProjectItem ReplaceParameters="true" TargetFileName="App.tsx">App.tsx</ProjectItem>
      </Folder>

      <Folder Name="public" TargetFolderName="public">
        <ProjectItem ReplaceParameters="false" TargetFileName="web.config">web.config</ProjectItem>
      </Folder>

      <!-- Verschachtelte Ordner funktionieren analog -->
      <Folder Name="Properties" TargetFolderName="Properties">
        <Folder Name="PublishProfiles" TargetFolderName="PublishProfiles">
          <ProjectItem ReplaceParameters="true" TargetFileName="FolderProfile.pubxml">FolderProfile.pubxml</ProjectItem>
        </Folder>
      </Folder>

    </Project>
  </TemplateContent>
</VSTemplate>
```

## Arbeitsablauf

### Schritt 1 – Input erfassen
- Quellprojekt/-lösung
- Template-Name, Beschreibung, DefaultName
- `LanguageTag` / `PlatformTag` (z. B. `TypeScript` / `Web`)
- Icon und Preview (siehe Abschnitt „Icon und Preview-Bild"); Nutzer nach Pfaden fragen – beliebige Dateinamen sind erlaubt, der Agent benennt sie korrekt um
- Parameterliste / CustomParameters falls nötig

### Schritt 2 – Staging aufbauen
Dateien aus dem Quellprojekt kopieren, folgende Artefakte **ausschließen**:
`bin`, `obj`, `node_modules`, `dist`, `.vs`, `.git`, `*.user`, `*.suo`

Zusätzlich verbindlich für alle Projekte:
- `.github` immer vollständig in das Staging kopieren.
- `.vscode` kopieren, wenn vorhanden (insbesondere `launch.json`).
- VS-F5-relevante Dateien nicht ausfiltern (`*.esproj`, `*.sln`, `*.slnx` im Root, falls vorhanden).

Staging-Struktur muss der Zielstruktur entsprechen:

```
<TemplateName>\
  <TemplateName>.vstemplate
  $safeprojectname$.esproj
  index.html
  .github\
    copilot-instructions.md
    instructions\
    skills\
  .vscode\
    launch.json
  src\
    main.tsx
    App.tsx
  public\
    web.config
  Properties\
    PublishProfiles\
      FolderProfile.pubxml
  __TemplateIcon.png          ? falls vorhanden (Präfix __ zwingend!)
  __PreviewImage.png          ? falls vorhanden (Präfix __ zwingend!)
```

### Schritt 3 – `.vstemplate` erstellen
- `ProjectType=CSharp`
- `CreateInPlace=true`
- `<Folder>`-Einträge mit reinem Dateinamen als Quelle
- Icon/Preview nur eintragen wenn Dateien im Staging vorhanden

### Schritt 4 – ZIP bauen
**Immer** `ZipFile.CreateFromDirectory` aus .NET verwenden – **nicht** `Compress-Archive`:

```powershell
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory(
  $staging, $zipOut,
  [System.IO.Compression.CompressionLevel]::Optimal,
  $false  # includeBaseDirectory = false
)
```

`Compress-Archive` kann ZIP64-Format oder inkompatible Strukturen erzeugen, die VS nicht lesen kann.

### Schritt 5 – Deployen

```powershell
# 1. ZIP in beide Template-Verzeichnisse kopieren
Copy-Item $zipOut "V:\Visual Studio 18\Templates\ProjectTemplates\<Name>.zip" -Force
Copy-Item $zipOut "$env:USERPROFILE\Documents\Visual Studio 2026\Templates\ProjectTemplates\<Name>.zip" -Force

# 2. Roaming-Cache-Ordner manuell befüllen (KRITISCH – nicht überspringen!)
$instanceId = (Get-ChildItem "$env:APPDATA\Microsoft\VisualStudio" -Directory |
               Where-Object { $_.Name -like "18.0_*" } |
               Select-Object -First 1).Name
$cacheDir = "$env:APPDATA\Microsoft\VisualStudio\$instanceId\ProjectTemplatesCache\<Name>.zip"
Remove-Item $cacheDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
Copy-Item "$staging\*" $cacheDir -Recurse -Force

# 3. devenv /installvstemplates (aktualisiert NPD-Cache-Metadaten)
& "C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\devenv.exe" /installvstemplates
```

### Schritt 6 – VS neu starten
Visual Studio **komplett schließen und neu starten**. Der NPD-Cache wird beim Start neu aufgebaut und das Template erscheint im Dialog „Neues Projekt erstellen".

### Schritt 7 – Validieren

```powershell
# Cache-Ordner korrekt befüllt?
Get-ChildItem $cacheDir -Recurse | Select-Object FullName

# vstemplate im Cache korrekt?
Get-Content "$cacheDir\<Name>.vstemplate" | Select-String "ProjectType|CreateInPlace"

# NPD-Cache enthält Template?
$bytes = [System.IO.File]::ReadAllBytes(
  "$env:LOCALAPPDATA\Microsoft\VisualStudio\$instanceId\NpdProjectTemplateCache_de-DE")
$text = [System.Text.Encoding]::UTF8.GetString($bytes)
if ($text -match "<TemplateName>") { "IM NPD-CACHE" } else { "FEHLT" }
```

In VS: „Neues Projekt erstellen" ? Template auswählen ? Projekt anlegen ? alle Dateien und Ordner prüfen.

## Validierungs-Checkliste

| Prüfung | Erwartetes Ergebnis |
|---|---|
| `.vstemplate` vorhanden und lesbar | Ja |
| `<ProjectType>CSharp</ProjectType>` gesetzt | Ja |
| `<CreateInPlace>true</CreateInPlace>` gesetzt | Ja |
| Icon-Datei im Staging vorhanden (falls referenziert) | Ja |
| Preview-Datei im Staging vorhanden (falls referenziert) | Ja |
| Alle `ProjectItem`-Quellen im Cache-Ordner vorhanden | Ja |
| `.github` im erzeugten Projekt vollständig vorhanden | Ja |
| `.vscode/launch.json` vorhanden (falls im Quellprojekt vorhanden) | Ja |
| VS-/VS-Code-F5-Startdateien (`.esproj`, `.sln`, `.slnx`) nicht versehentlich entfernt | Ja |
| Kein `src\src\`-Doppelpfad im erzeugten Projekt | Ja |
| Template nach VS-Neustart im NPD-Cache | Ja |
| Erzeugtes Projekt enthält alle Pflichtdateien | Ja |

## Fehlerbehandlung

| Fehlermeldung | Ursache | Maßnahme |
|---|---|---|
| `STG_E_FILENOTFOUND (0x80030002)` | Roaming-Cache-Ordner fehlt oder ist leer | Cache-Ordner manuell anlegen und befüllen (Schritt 5) |
| „Datei X wurde in den Projektvorlagen nicht gefunden" | Quellpfad in `ProjectItem` falsch | Bei `<Folder>`-Einträgen nur Dateiname, kein Ordnerpräfix |
| `src\src\main.tsx` doppelt erzeugt | Ordnerpräfix im `ProjectItem`-Quellpfad innerhalb `<Folder>` | Pfad auf reinen Dateinamen kürzen |
| Template nicht im Neu-Projekt-Dialog | `ProjectType` nicht `CSharp` oder Cache nicht befüllt | `ProjectType=CSharp` setzen, Cache-Ordner prüfen |
| „Projektname nicht angegeben" | Fehler in `<Project File="...">` | `File`-Attribut auf `$safeprojectname$.esproj` setzen |
| Template sichtbar, Dateien fehlen | `<CreateInPlace>` fehlt | `<CreateInPlace>true</CreateInPlace>` in `<TemplateData>` einfügen |

## Versionierung & Changelog (optional)
- ZIP mit Version benennen: `MyTemplate.v2.zip`
- `CHANGELOG.md` im Staging pflegen: Datum, Version, Änderungen, Validierungsstatus

## Hinweise für Agenten
- Bei jeder Unklarheit zuerst Microsoft Learn konsultieren (Themen: `ProjectItem element`, `Folder element`, `Template parameters`).
- Bei wiederkehrenden Fehlern nicht blind neue Varianten erzeugen – Ursache anhand `.vstemplate` + Cache-Ordner-Struktur verifizieren.
- Fokus: **funktionierendes Template beim ersten Versuch**, nicht nachträgliches Reparieren.
