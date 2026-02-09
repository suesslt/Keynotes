# Keynotes App - Setup und Konfiguration

## Übersicht
Die Keynotes App ist eine umfassende iOS-Anwendung zur professionellen Verwaltung von Keynote-Auftritten als Speaker. Sie bietet vollständige CRUD-Funktionalität, Status-Management, Kalender- und Kontakt-Integration sowie Statistiken.

## ✨ Features
- ✅ **Vollständige CRUD-Funktionalität** für Keynotes mit swipe actions und context menus
- ✅ **Status-Lifecycle** mit 9 Stufen + Abbruch-Option
- ✅ **Apple Kalender Integration** (EventKit) für "Save the Date" Einträge
- ✅ **Apple Kontakte Integration** zur Verknüpfung von Ansprechpartnern
- ✅ **Suche und Filter** nach Text und Status
- ✅ **Verfügbarkeitsprüfung** anhand des Kalenders
- ✅ **Statistiken** für Übersicht über alle Auftritte und Finanzen
- ✅ **SwiftData Persistenz** mit automatischer iCloud Sync-Unterstützung
- ✅ **Modern SwiftUI** mit NavigationSplitView für iPad-Optimierung
- ✅ **Error Handling** mit benutzerfreundlichen Fehlermeldungen

## 📋 Dateien-Übersicht

### Models
- **Keynote.swift** - Hauptdatenmodell mit allen Attributen
- **KeynoteStatus.swift** - Status-Enum mit Lifecycle-Logik

### Services
- **CalendarService.swift** - EventKit Integration für Kalender
- **ContactsService.swift** - Contacts Framework Integration

### Views
- **ContentView.swift** - Hauptliste mit Suche, Filter und Navigation
- **KeynoteDetailView.swift** - Detail/Edit View für einzelne Keynotes
- **KeynoteStatsView.swift** - Statistiken und Übersicht
- **KeynoteListItemView.swift** - Wiederverwendbare List Item Komponente

### Utilities
- **ErrorHandler.swift** - Zentrale Fehlerbehandlung
- **SampleData.swift** - Test- und Preview-Daten

## 🚀 Setup

### 1. Info.plist Einträge (WICHTIG!)
Du **musst** folgende Privacy-Beschreibungen in deine `Info.plist` einfügen:

#### Über Xcode UI:
1. Wähle dein Projekt im Navigator
2. Wähle dein Target
3. Gehe zum Tab "Info"
4. Klicke auf "+" um neue Einträge hinzuzufügen

#### Keys und Werte:

```
Privacy - Calendars Usage Description
→ Die App benötigt Zugriff auf deinen Kalender, um Save-the-Date Einträge für Keynotes zu erstellen und deine Verfügbarkeit zu prüfen.

Privacy - Calendars Full Access Usage Description  
→ Die App benötigt vollen Kalenderzugriff, um Save-the-Date Einträge für deine Keynotes zu verwalten.

Privacy - Contacts Usage Description
→ Die App benötigt Zugriff auf deine Kontakte, um primäre Ansprechpartner für Keynotes zu verknüpfen.
```

Alternativ kannst du die Werte aus `Info.plist.example` kopieren.

### 2. Minimum iOS Version
- **iOS 17.0+** erforderlich (wegen SwiftData)

### 3. Build Settings
Keine besonderen Build Settings erforderlich. Die Standard-Einstellungen genügen.

## 📱 Verwendung

### Neue Keynote erstellen
1. Tippe auf das **"+"** Icon in der Toolbar
2. Fülle alle Felder aus:
   - Name des Anlasses (erforderlich)
   - Datum und Zeit
   - Titel der Keynote (erforderlich)
   - Thema, Redezeit, Organisation, etc.
3. Optional: Wähle einen **primären Kontakt** aus deinen Kontakten
4. Tippe auf **"Sichern"**

### Keynote bearbeiten
- **Swipe nach rechts** → Bearbeiten
- **Swipe nach links** → Löschen
- **Langes Drücken** → Context Menu mit Optionen
- **Antippen** → Detail-Ansicht

### Status ändern
1. Öffne eine Keynote in der Detail-Ansicht
2. Tippe auf **"Status ändern"**
3. Wähle den nächsten Status aus den erlaubten Optionen
4. Bei "Termin bestätigt" → Optional "Save the Date" erstellen

### "Save the Date" Kalender-Eintrag
- Wird automatisch angeboten beim Status-Wechsel zu "Termin bestätigt"
- Kann auch manuell in der Detail-Ansicht erstellt werden
- Enthält alle wichtigen Informationen (Titel, Zeit, Ort, Honorar)
- Wird automatisch gelöscht wenn Keynote gelöscht wird

### Verfügbarkeit prüfen
1. Öffne eine Keynote in der Detail-Ansicht
2. Tippe auf **"Verfügbarkeit prüfen"**
3. Alle Kalender-Konflikte am gewählten Datum werden angezeigt
4. Eigener "Save the Date" wird ausgeblendet

### Suchen und Filtern
- **Suchleiste**: Sucht in Name, Titel, Thema, Organisation und Ort
- **Filter-Menu** (≡): Filtere nach Status oder zeige alle

### Statistiken anzeigen
1. Tippe auf das **Diagramm-Symbol** in der Toolbar
2. Sieh dir an:
   - Anzahl Keynotes (gesamt, dieses Jahr, anstehend)
   - Finanz-Übersicht (bestätigt, offen, bezahlt)
   - Status-Verteilung

## 📊 Datenmodell

### Keynote Attribute
```swift
- eventName: String              // Name des Anlasses
- eventDate: Date                // Datum und Zeit der Durchführung
- keynoteTitle: String           // Titel der Keynote
- keynoteTheme: String           // Thema der Keynote
- duration: TimeInterval         // Redezeit in Minuten
- clientOrganization: String     // Firma/Organisation Auftraggeber
- primaryContactID: String?      // CNContact Identifier
- agreedFee: Decimal            // Vereinbartes Honorar
- targetAudience: String        // Zielpublikum
- location: String              // Ort der Durchführung
- status: KeynoteStatus         // Aktueller Status
- requestDate: Date             // Datum der Anfrage
- calendarEventID: String?      // EventKit Event Identifier
- notes: String                 // Notizen
```
### Status Lifecycle
Der Status folgt einem definierten Lifecycle. Von jedem Status kann nur zu bestimmten nächsten Status gewechselt werden:

1. **Angefragt** → (2 oder Abbruch)
2. **Termin bestätigt, Honorar offeriert** → (3 oder Abbruch)
3. **Honorar bestätigt** → (4 oder Abbruch)
4. **Thema, Inhalt und Zielpublikum vereinbart** → (5 oder Abbruch)
5. **Vertrag erstellt und Zustande gekommen** → (6 oder Abbruch)
6. **Durchgeführt und in Rechnung gestellt** → (7 oder Abbruch)
7. **Bezahlt** → (8 oder 9)
8. **Feedback angefragt** → (9)
9. **Abgeschlossen** → (Ende)
- **Abgebrochen** → (Ende)

Jeder Status hat eine eigene Farbe für visuelle Unterscheidung.

## 🏗 Architektur

### Technologien
- **SwiftUI** - Modernes, deklaratives UI Framework
- **SwiftData** - Moderne Datenpersistenz mit automatischem iCloud Sync
- **EventKit** - Integration mit Apple Kalender
- **Contacts/ContactsUI** - Integration mit Apple Kontakte
- **Swift Concurrency** - async/await für asynchrone Operationen

### Design Patterns
- **MVVM-ähnlich** mit SwiftData's @Model und @Query
- **Service Pattern** für Kalender und Kontakte
- **Composition** mit wiederverwendbaren View-Komponenten
- **Coordinator Pattern** für Navigation via NavigationStack

### Best Practices
- ✅ Type-safe Navigation mit NavigationPath
- ✅ Proper Error Handling mit async/await
- ✅ Observable Services mit @MainActor
- ✅ Efficient List Rendering mit wiederverwendbaren Komponenten
- ✅ iPad-optimiert mit NavigationSplitView
- ✅ Accessibility-freundlich mit nativen Labels

## 🧪 Testing

### Sample Data
Die App enthält Beispieldaten in `SampleData.swift`:
- 8 vorgefertigte Keynotes mit verschiedenen Status
- Preview Container für SwiftUI Previews
- Hilfreich für Testing und Entwicklung

### Verwendung in Tests
```swift
let container = previewContainer()
// Container enthält jetzt Sample-Daten
```

## 🔮 Zukünftige Erweiterungen

Mögliche Features für zukünftige Versionen:

- [ ] **E-Mail-Import mit Claude AI** für automatische Keynote-Erfassung
- [ ] **PDF Export** von Keynote-Details und Verträgen
- [ ] **CSV Export** für Buchhaltung
- [ ] **Statistiken Charts** mit Swift Charts
- [ ] **Erinnerungen** für Follow-ups und Deadlines
- [ ] **Wiederkehrende Keynotes** / Templates
- [ ] **Dokumente-Anhänge** (Verträge, Präsentationen)
- [ ] **Reiseplanung-Integration** (Flüge, Hotels)
- [ ] **Expense Tracking** für Spesen
- [ ] **Widget** mit anstehenden Keynotes
- [ ] **Apple Watch App** für Quick-View
- [ ] **Siri Shortcuts** für schnelle Abfragen
- [ ] **SharePlay** für gemeinsame Planung mit Team

## 🐛 Troubleshooting

### "App fragt nicht nach Kalender/Kontakte-Berechtigung"
→ Prüfe, ob die Info.plist Einträge korrekt gesetzt sind

### "SwiftData speichert nicht"
→ Stelle sicher, dass iOS 17+ als Deployment Target gesetzt ist
→ Prüfe ob modelContainer korrekt in der App gesetzt ist

### "Kontakt-Name wird nicht angezeigt"
→ Erteile Kontakte-Berechtigung in iOS Einstellungen
→ Stelle sicher, dass der Kontakt noch existiert

### "Kalender-Event wird nicht erstellt"
→ Erteile Kalender-Berechtigung in iOS Einstellungen
→ Prüfe ob ein Standard-Kalender existiert

## 📄 Lizenz

Dieses Projekt wurde für Thomas Süssli erstellt.

## 👤 Autor

**Thomas Süssli**  
Erstellung: 08.02.2026

