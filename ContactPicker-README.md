# Contact Picker - Technische Dokumentation

## Übersicht

Der neue Contact Picker ist eine **komplett native SwiftUI-Lösung**, die auf macOS und iOS performant läuft.

## Wichtige Änderungen

### ❌ Entfernt
- `CNContactPickerViewController` (UIKit/AppKit Wrapper)
- `UIViewControllerRepresentable` / `NSViewControllerRepresentable`
- `ContactPickerCoordinator` (Delegate-basierter Ansatz)
- Alle komplizierten View Controller Hierarchie-Suchen

### ✅ Neu implementiert
- **ContactPickerView**: Native SwiftUI List-basierte Auswahl
- **ContactPickerViewModel**: MVVM Pattern für saubere Trennung
- **ContactRowButton**: Wiederverwendbare Kontakt-Zeile mit Avatar
- **Async/Await**: Moderne Swift Concurrency
- **Platform-agnostisch**: Funktioniert identisch auf macOS und iOS

## Architektur

```
┌─────────────────────────────┐
│   KeynoteDetailView         │
│   .sheet(isPresented:)      │
└──────────┬──────────────────┘
           │
           │ Präsentiert
           ▼
┌─────────────────────────────┐
│   ContactPickerView         │
│   (SwiftUI Native)          │
└──────────┬──────────────────┘
           │
           │ Nutzt
           ▼
┌─────────────────────────────┐
│  ContactPickerViewModel     │
│  @MainActor                 │
│  - loadContacts()           │
│  - filteredContacts         │
└──────────┬──────────────────┘
           │
           │ Verwendet
           ▼
┌─────────────────────────────┐
│   ContactsService           │
│   - Cache mit Actor         │
│   - Async Methods           │
└─────────────────────────────┘
```

## Performance-Optimierungen

### 1. Asynchrones Laden
```swift
Task.detached(priority: .userInitiated) {
    // Kontakte werden auf Background Thread geladen
    try store.enumerateContacts(with: request) { ... }
}
```

### 2. Keine mehrfachen Präsentationen
- Verwendet `.sheet(isPresented:)` statt komplexer View Controller Logik
- SwiftUI managed automatisch den Lifecycle
- Kein manuelles Dismiss/Present-Handling nötig

### 3. Effiziente Filterung
- Suche läuft direkt auf der bereits geladenen Liste
- Keine zusätzlichen API-Calls beim Suchen

### 4. Kontakt-Cache
- `ContactsService` cached bereits geladene Kontakte
- Beim erneuten Öffnen werden gecachte Daten verwendet

## Verwendung

```swift
.sheet(isPresented: $showingContactPicker) {
    ContactPickerView(
        contactsService: contactsService,
        selectedContactID: $keynote.primaryContactID
    )
}
```

## Fehlerbehandlung

- Zeigt benutzerfreundliche Fehlermeldungen
- "Erneut versuchen" Button bei Fehlern
- Prüft Berechtigungen vor dem Laden
- Zeigt leeren Zustand wenn keine Kontakte vorhanden

## Bekannte Limitierungen

1. **Gruppierte Kontakte**: Aktuell wird nur eine flache Liste angezeigt
2. **Sortierung**: Nur nach Vornamen (kann erweitert werden)
3. **Vorschau-Bilder**: Werden geladen, aber können bei vielen Kontakten Speicher verbrauchen

## Zukünftige Verbesserungen

- [ ] Sectioned List (A-Z Gruppierung)
- [ ] Lazy loading für sehr große Kontaktlisten
- [ ] Favoriten-Sektion
- [ ] Letzte verwendete Kontakte
- [ ] Multi-Select Option
