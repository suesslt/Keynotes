# ✅ iCloud Setup Checkliste

Nutze diese Checkliste um sicherzustellen, dass alles korrekt konfiguriert ist.

## Code-Konfiguration (✅ Bereits erledigt!)

- [x] `KeynotesApp.swift` enthält `cloudKitDatabase: .automatic`
- [x] `CloudKitStatusView.swift` erstellt für Status-Monitoring
- [x] UI Button in `ContentView.swift` zum Prüfen des Status
- [x] SwiftData Models sind CloudKit-kompatibel

## Xcode Konfiguration (👈 Das musst du noch machen!)

### In Signing & Capabilities:

- [ ] **iCloud** Capability hinzugefügt
  - [ ] **CloudKit** Checkbox aktiviert
  - [ ] CloudKit Container erstellt und ausgewählt
  
- [ ] **Background Modes** Capability hinzugefügt (optional)
  - [ ] **Remote notifications** aktiviert

### In General Settings:

- [ ] **Deployment Target** ist iOS 17.0 oder höher
- [ ] **Signing Team** ist ausgewählt
- [ ] **Bundle Identifier** ist eindeutig

## Testing auf Gerät

- [ ] App auf **echtem Gerät** installiert (nicht Simulator!)
- [ ] Bei **iCloud angemeldet** auf dem Gerät
- [ ] **iCloud Drive aktiviert** in iOS Einstellungen
- [ ] **Internet-Verbindung** vorhanden
- [ ] iCloud Status in der App prüfen (sollte grün sein ✅)
- [ ] Keynote erstellen auf Gerät 1
- [ ] Zweites Gerät mit **gleicher Apple ID** verbinden
- [ ] App auf Gerät 2 öffnen
- [ ] Nach 5-30 Sekunden sollte Keynote erscheinen

## Verifikation

### In der App:
- [ ] Tippe auf das **☁️ iCloud Symbol** (links oben)
- [ ] Status sollte **"iCloud verfügbar"** anzeigen (grün)
- [ ] Erstelle eine Test-Keynote
- [ ] Keynote erscheint auf zweitem Gerät

### Bei Problemen:
- [ ] Alle Checkboxen oben überprüft?
- [ ] Force-Close App auf beiden Geräten
- [ ] App neu öffnen
- [ ] iCloud Status erneut prüfen
- [ ] iOS Einstellungen → [Name] → iCloud → iCloud Drive ist AN
- [ ] Genug iCloud Speicherplatz verfügbar?

## Schnellhilfe bei roten/orangen Status

### 🔴 "Nicht bei iCloud angemeldet"
1. Öffne iOS **Einstellungen**
2. Tippe auf **[Dein Name]** ganz oben
3. Falls nicht angemeldet: **Bei iCloud anmelden**
4. Gib Apple ID und Passwort ein

### 🟠 "iCloud eingeschränkt"
1. iOS **Einstellungen** → **Bildschirmzeit**
2. Prüfe ob **iCloud** eingeschränkt ist
3. Falls ja: Einschränkungen aufheben

### 🟠 "Temporär nicht verfügbar"
1. **Warten** - iCloud Server können überlastet sein
2. **Internet-Verbindung prüfen**
3. Nach ein paar Minuten erneut versuchen

## 🎉 Erfolg!

Wenn der Status ✅ grün ist und Keynotes zwischen Geräten synchronisieren, ist alles perfekt eingerichtet!

---

**Nächste Schritte:**
- Nutze die App normal
- Synchronisation passiert automatisch
- Kein manuelles Sync nötig
- Genieße die Magie von iCloud! ✨
