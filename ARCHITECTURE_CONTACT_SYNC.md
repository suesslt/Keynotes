# 🏗️ Architektur: iCloud Kontakt-Synchronisation

## System-Übersicht

```
┌─────────────────────────────────────────────────────────────┐
│                      Keynotes App                           │
│                                                              │
│  ┌────────────────┐         ┌──────────────────┐           │
│  │   Keynote      │◄────────│ KeynoteContact   │           │
│  │   (Model)      │         │    (Model)       │           │
│  │                │         │                  │           │
│  │ - eventName    │         │ - fullName       │           │
│  │ - eventDate    │         │ - email          │           │
│  │ - ...          │         │ - phone          │           │
│  │                │         │ - localContactID │           │
│  │ primaryContact ├────────►│                  │           │
│  └────────────────┘         └──────────────────┘           │
│         │                            ▲                      │
│         │                            │                      │
│         ▼                            │                      │
│  ┌─────────────────────────────────────────┐               │
│  │        SwiftData + iCloud               │               │
│  │                                          │               │
│  │  ModelContainer(                        │               │
│  │    cloudKitDatabase: .automatic         │               │
│  │  )                                       │               │
│  └─────────────────────────────────────────┘               │
│         │                            ▲                      │
└─────────┼────────────────────────────┼──────────────────────┘
          │                            │
          │         iCloud             │
          ▼                            │
  ┌────────────────────────────────────────┐
  │      CloudKit (Automatic Sync)         │
  │                                         │
  │  ┌──────────────┐  ┌──────────────┐   │
  │  │   Keynote    │  │ KeynoteContact│  │
  │  │   Record     │  │    Record     │   │
  │  └──────────────┘  └──────────────┘   │
  └────────────────────────────────────────┘
          │                            ▲
          │                            │
          ▼                            │
┌────────────────────────────────────────────────┐
│              Andere Geräte                     │
│                                                 │
│  ┌────────────────┐         ┌──────────────┐  │
│  │   Keynote      │◄────────│KeynoteContact│  │
│  │   (Model)      │         │   (Model)    │  │
│  └────────────────┘         └──────────────┘  │
│         │                            │         │
│         ▼                            ▼         │
│  ┌────────────────────────────────────────┐   │
│  │   KeynoteDetailView zeigt Daten an     │   │
│  │   ✅ OHNE Kontaktzugriff!              │   │
│  └────────────────────────────────────────┘   │
└────────────────────────────────────────────────┘
```

## Datenfluss: Kontakt auswählen

```
Benutzer tippt "Kontakt wählen"
         │
         ▼
┌────────────────────────┐
│ ContactPickerView      │ ◄─── UIKit Wrapper
│ (SwiftUI Sheet)        │
└────────────────────────┘
         │
         ▼
┌────────────────────────┐
│ CNContactPicker        │ ◄─── iOS System UI
│ (System UI)            │
└────────────────────────┘
         │
         │ Benutzer wählt Kontakt
         ▼
┌────────────────────────┐
│ Coordinator            │
│ .didSelect(contact)    │
└────────────────────────┘
         │
         ▼
┌────────────────────────┐
│ ContactsService        │
│ .createKeynoteContact()│ ◄─── Extrahiert Daten
└────────────────────────┘
         │
         │ Name, E-Mail, Telefon
         ▼
┌────────────────────────┐
│ KeynoteContact         │ ◄─── Neues Objekt
│ (SwiftData Model)      │
└────────────────────────┘
         │
         │ Assignment
         ▼
┌────────────────────────┐
│ keynote.primaryContact │
└────────────────────────┘
         │
         │ Automatisch
         ▼
┌────────────────────────┐
│ iCloud Sync            │ ◄─── SwiftData Magic
└────────────────────────┘
         │
         ▼
    Andere Geräte erhalten Daten! ✅
```

## Migration Flow

```
App Start
    │
    ▼
┌─────────────────────────┐
│ KeynotesApp             │
│ .task { migrate() }     │
└─────────────────────────┘
    │
    ▼
┌─────────────────────────────┐
│ ContactMigrationHelper      │
└─────────────────────────────┘
    │
    ▼
Lade alle Keynotes
    │
    ▼
Für jede Keynote:
    │
    ├─► Hat primaryContactID? ──NO──► Skip
    │                │
    │               YES
    │                │
    ├─► Hat primaryContact? ──YES──► Skip
    │                │
    │               NO
    │                │
    │                ▼
    │   ┌──────────────────────────┐
    │   │ ContactsService          │
    │   │ .createKeynoteContact()  │
    │   └──────────────────────────┘
    │                │
    │                ▼
    │   ┌──────────────────────────┐
    │   │ Erstelle KeynoteContact  │
    │   │ mit echten Daten         │
    │   └──────────────────────────┘
    │                │
    │                ▼
    └────► keynote.primaryContact = contact
                     │
                     ▼
              Speichern & Sync
                     │
                     ▼
              Migration ✅ Fertig!
```

## Datenschema Vergleich

### Alt (Funktioniert nicht über iCloud)
```
Keynote
├── eventName: String
├── eventDate: Date
├── primaryContactID: String? ❌
└── ...

Gerät 1: primaryContactID = "ABC123"
                                ▼
                           iCloud Sync
                                ▼
Gerät 2: primaryContactID = "ABC123" ❌
         (ID existiert nicht auf Gerät 2!)
```

### Neu (Funktioniert perfekt!)
```
Keynote
├── eventName: String
├── eventDate: Date
├── primaryContact: KeynoteContact? ✅
│   ├── fullName: "Max Mustermann"
│   ├── email: "max@example.com"
│   ├── phone: "+41 79 123 45 67"
│   └── localContactID: "ABC123" (optional)
└── ...

Gerät 1: primaryContact = KeynoteContact(...)
                                ▼
                           iCloud Sync
                                ▼
Gerät 2: primaryContact = KeynoteContact(...) ✅
         (Alle Daten verfügbar!)
```

## View-Hierarchie

```
KeynoteDetailView
│
├─► Form
│   │
│   ├─► basicInfoSection
│   │   └─► TextField, DatePicker, etc.
│   │
│   ├─► contactSection ◄─── HAUPTÄNDERUNG
│   │   │
│   │   └─► if let contact = keynote.primaryContact
│   │       │
│   │       ├─► VStack
│   │       │   ├─► Text(contact.displayName)
│   │       │   ├─► Label(contact.email)
│   │       │   └─► Label(contact.phone)
│   │       │
│   │       ├─► Button("Ändern")
│   │       │
│   │       └─► if findMatchingContact()
│   │           └─► Button("In Kontakte öffnen")
│   │
│   └─► ... andere Sections
│
└─► .sheet(isPresented: $showingContactPicker)
    └─► ContactPickerView(
            contactsService: contactsService,
            selectedContact: $keynote.primaryContact ◄─── Neues Binding
        )
```

## Service-Architektur

```
ContactsService (@MainActor)
│
├─► Bestehende Methoden:
│   ├─► requestAccess() -> Bool
│   ├─► getContact(identifier:) -> CNContact?
│   ├─► getContactName(identifier:) -> String
│   ├─► getContactEmail(identifier:) -> String?
│   └─► getContactPhone(identifier:) -> String?
│
└─► NEUE Methoden:
    ├─► createKeynoteContact(from: String) -> KeynoteContact?
    │   │
    │   └─► Verwendet:
    │       ├─► getContact(identifier:)
    │       ├─► CNContactFormatter
    │       └─► Extrahiert: Name, Email, Phone
    │
    └─► findMatchingContact(for: KeynoteContact) -> String?
        │
        └─► Strategien:
            ├─► 1. Prüfe localContactID
            ├─► 2. Matche via Email (zuverlässig)
            └─► 3. Matche via Name (best effort)
```

## iCloud Sync Ablauf

```
Gerät 1: Keynote erstellen
    │
    ▼
SwiftData: Keynote.insert()
    │
    ▼
CloudKit: Erstelle CKRecord
    │
    │  Records:
    │  ┌─────────────────────┐
    │  │ Keynote Record      │
    │  ├─────────────────────┤
    │  │ eventName           │
    │  │ eventDate           │
    │  │ primaryContact ─────┼───┐
    │  └─────────────────────┘   │
    │                             │
    │  ┌─────────────────────┐   │
    │  │ KeynoteContact Rec. │◄──┘
    │  ├─────────────────────┤
    │  │ fullName            │
    │  │ email               │
    │  │ phone               │
    │  │ localContactID      │
    │  └─────────────────────┘
    │
    ▼
iCloud Server
    │
    ▼
Push Notification
    │
    ▼
Gerät 2: Empfange Update
    │
    ▼
CloudKit: Lade CKRecords
    │
    ▼
SwiftData: Update Model
    │
    ▼
UI: Automatisches Refresh
    │
    ▼
Benutzer sieht: ✅
    - Max Mustermann
    - max@example.com
    - +41 79 123 45 67
```

## Fehlerbehandlung

```
createKeynoteContact(from:)
    │
    ├─► CNContact nicht gefunden?
    │   └─► return nil
    │
    ├─► Kein Name verfügbar?
    │   └─► fullName = "" (leer)
    │
    └─► Keine Email/Phone?
        └─► Felder leer (OK!)

findMatchingContact(for:)
    │
    ├─► localContactID vorhanden?
    │   ├─► Ja → Existiert Kontakt?
    │   │   ├─► Ja → return ID ✅
    │   │   └─► Nein → Weiter suchen
    │   └─► Nein → Weiter suchen
    │
    ├─► Email vorhanden?
    │   └─► Suche via Email
    │       ├─► Match? → return ID ✅
    │       └─► Kein Match → Weiter
    │
    ├─► Name vorhanden?
    │   └─► Suche via Name
    │       ├─► Match? → return ID ✅
    │       └─► Kein Match → return nil
    │
    └─► return nil (kein Match)
        └─► "In Kontakte öffnen" wird nicht angezeigt
            (Daten werden trotzdem gezeigt!)
```

## Performance-Überlegungen

### Vorteile der neuen Lösung:
✅ **Weniger API-Calls**: Keine CNContactStore-Abfragen auf anderen Geräten  
✅ **Offline-fähig**: Daten immer verfügbar  
✅ **Schneller**: Direkte Anzeige ohne Lookup  
✅ **Zuverlässig**: Keine fehlenden Kontakte  

### Speicher:
- KeynoteContact: ~100-500 Bytes pro Objekt
- Sehr effizient für iCloud Sync
- Minimal zusätzlicher Speicherbedarf

---

**Zusammenfassung**: Die neue Architektur ist robuster, schneller und iCloud-freundlicher! 🚀
