<#
.SYNOPSIS
    GitHub Copilot Skill: Fuegt Markdown-Dateien einen Footer mit Titel und aktuellem Datum hinzu.

.DESCRIPTION
    Dieses Skill-Skript verarbeitet Markdown-Dateien und versieht sie mit einem standardisierten Footer.
    Der Footer enthaelt den Titel der Datei (aus der ersten Ueberschrift) und das aktuelle Datum.

.PARAMETER Path
    Der Pfad zum Verzeichnis mit Markdown-Dateien oder zu einer einzelnen MD-Datei.
    Standard: Aktuelles Verzeichnis (.)

.PARAMETER Force
    Wenn gesetzt, werden existierende Footer aktualisiert. Andernfalls wird eine Datei uebersprungen,
    falls bereits ein Footer vorhanden ist.

.EXAMPLE
    # Alle Markdown-Dateien im aktuellen Verzeichnis verarbeiten
    .\.github\skills\add-md-footer\add-md-footer.ps1

.EXAMPLE
    # Einzelne Datei verarbeiten
    .\.github\skills\add-md-footer\add-md-footer.ps1 -Path "README.md"

.EXAMPLE
    # Footer aktualisieren (Force)
    .\.github\skills\add-md-footer\add-md-footer.ps1 -Path "." -Force
#>
param(
    [string]$Path = ".",
    [switch]$Force
)

$processed = 0
$skipped   = 0
$dateApplied = (Get-Date).ToString("dd.MM.yyyy")

# Projektname aus Git-Repo oder Verzeichnis ermitteln
function Get-ProjectName {
    param([string]$BasePath)
    try {
        $result = & git -C $BasePath rev-parse --show-toplevel 2>$null
        if ($LASTEXITCODE -eq 0 -and $result) {
            return (Split-Path -Leaf $result.Trim())
        }
    } catch {}
    return (Split-Path -Leaf (Resolve-Path $BasePath))
}

# Ersten H1-Titel aus Markdown-Datei extrahieren
function Get-MdTitle {
    param([string]$FilePath)
    $lines = Get-Content $FilePath -Encoding UTF8 -ErrorAction SilentlyContinue
    foreach ($line in $lines) {
        if ($line -match '^#\s+(.+)$') {
            return $Matches[1].Trim()
        }
    }
    return [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
}

# Footer fuer eine Markdown-Datei hinzufuegen oder aktualisieren
function Add-MdFooter {
    param(
        [string]$FilePath,
        [string]$ProjectName,
        [switch]$Force
    )
    $content  = [System.IO.File]::ReadAllText($FilePath, [System.Text.Encoding]::UTF8)
    $hasFooter = $content -match '<!-- Footer -->'

    if ($hasFooter -and -not $Force) {
        Write-Host "  [SKIP]  $FilePath" -ForegroundColor Yellow
        return $false
    }

    $title = Get-MdTitle -FilePath $FilePath
    $year  = (Get-Date).Year
    $date  = $dateApplied

    $footerBlock = @"

---

<!-- Footer -->
<div style="text-align: center; font-size: 0.8em; color: #666; margin-top: 2em;">
  <p style="margin:0;">$title ($ProjectName)</p>
  <p style="margin:0; font-size: 0.9em;">&copy; $year <a href="https://joerg-walkowiak.de/" style="color: inherit; text-decoration: none;">Joerg Walkowiak</a>. Alle Rechte vorbehalten. | Stand: $date</p>
</div>
"@

    if ($hasFooter) {
        $content = [System.Text.RegularExpressions.Regex]::Replace(
            $content,
            '(?s)\r?\n---\r?\n\r?\n<!-- Footer -->.*$',
            ''
        )
    }

    $newContent = $content.TrimEnd() + $footerBlock
    [System.IO.File]::WriteAllText($FilePath, $newContent, [System.Text.Encoding]::UTF8)
    $action = if ($hasFooter) { "UPDATED" } else { "ADDED" }
    Write-Host "  [$action]  $FilePath" -ForegroundColor Green
    return $true
}

# --- Hauptlogik ---
$resolvedPath = Resolve-Path $Path -ErrorAction SilentlyContinue
if (-not $resolvedPath) {
    Write-Error "Pfad nicht gefunden: $Path"
    exit 1
}

$projectName = Get-ProjectName -BasePath $resolvedPath

if (Test-Path $resolvedPath -PathType Leaf) {
    if ($resolvedPath -match '\.md$') {
        if (Add-MdFooter -FilePath $resolvedPath -ProjectName $projectName -Force:$Force) { $processed++ } else { $skipped++ }
    } else {
        Write-Warning "Keine Markdown-Datei: $resolvedPath"
    }
} else {
    $mdFiles = Get-ChildItem -Path $resolvedPath -Filter "*.md" -File
    if ($mdFiles.Count -eq 0) {
        Write-Host "Keine Markdown-Dateien gefunden in: $resolvedPath" -ForegroundColor Yellow
    } else {
        Write-Host "Verarbeite $($mdFiles.Count) Markdown-Datei(en) in: $resolvedPath" -ForegroundColor Cyan
        foreach ($file in $mdFiles) {
            if (Add-MdFooter -FilePath $file.FullName -ProjectName $projectName -Force:$Force) { $processed++ } else { $skipped++ }
        }
    }
}

Write-Host ""
Write-Host "Fertig: $processed verarbeitet, $skipped uebersprungen." -ForegroundColor Cyan