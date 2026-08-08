# Sinn und Zweck

Die Datei `jw.copilot-instructions.md` dient dazu, KI-gestützten Tools wie GitHub Copilot projektspezifische Anweisungen zu geben. Sie hilft, die Qualität und Konsistenz der generierten Vorschläge zu verbessern, indem sie klare Vorgaben zu Technologien, Stil und Architektur macht.

# Formulierungsempfehlungen

- Verwende kurze, prägnante Sätze.
- Pro Zeile oder Absatz nur eine Anweisung.
- Nutze möglichst wenig Fließtext, sondern klar strukturierte Bullet-Points.
- Verwende einheitliche Überschriften: Nutze H2 (`##`) für Hauptabschnitte, H3 (`###`) für Unterpunkte.
- Gib den technologischen Kontext an, z. B. „Wir verwenden .NET MAUI, nicht Xamarin Forms“.
- Lege Code-Konventionen fest, z. B. „JavaScript immer mit doppelten Anführungszeichen“.
- Nenne explizit Ausschlüsse, z. B. „Kein TypeScript verwenden“.
- Formuliere Anweisungen eindeutig und ohne Mehrdeutigkeiten.
- Schreibe keine Erklärungen, sondern immer konkrete Anweisungen.
- Ergänze bei Bedarf Beispiele für erwünschte oder unerwünschte Vorschläge.
- Halte die Datei aktuell, wenn sich Projektvorgaben ändern.

## Beispiele für Anweisungen

- Wenn du neuen Shared-Code vorschlägst, lege ihn **immer** in `MauiBlazorWeb.Shared/Components` (bzw. `Services`, `Models`) ab.
- Platziere platform-spezifische Assets **nur** im jeweiligen Zielprojekt.
