# Keynotes App - Quick Start Guide

## 🚀 In 3 Minuten einsatzbereit

### Schritt 1: Info.plist konfigurieren
**WICHTIG!** Ohne diese Einträge funktioniert die App nicht korrekt.

1. Öffne dein Xcode Projekt
2. Wähle dein Target → Tab "Info"
3. Füge diese 3 Einträge hinzu:

| Key | Value |
|-----|-------|
| Privacy - Calendars Usage Description | Die App benötigt Zugriff auf deinen Kalender, um Save-the-Date Einträge für Keynotes zu erstellen und deine Verfügbarkeit zu prüfen. |
| Privacy - Calendars Full Access Usage Description | Die App benötigt vollen Kalenderzugriff, um Save-the-Date Einträge für deine Keynotes zu verwalten. |
| Privacy - Contacts Usage Description | Die App benötigt Zugriff auf deine Kontakte, um primäre Ansprechpartner für Keynotes zu verknüpfen. |

### Schritt 2: Deployment Target prüfen
- Mindestens **iOS 17.0** (für SwiftData)

### Schritt 3: Build & Run
- Das war's! Die App ist sofort einsatzbereit 🎉

---

## 📱 Erste Schritte

### Deine erste Keynote erstellen
1. **Tippe auf "+"** in der rechten oberen Ecke
2. **Pflichtfelder ausfüllen:**
   - Name des Anlasses
   - Titel der Keynote
3. **Optional ausfüllen:**
   - Datum, Zeit, Ort
   - Honorar, Organisation
   - Kontakt auswählen
4. **"Sichern" tippen**

### Status einer Keynote ändern
1. **Keynote öffnen** (antippen)
2. **"Status ändern" tippen**
3. **Neuen Status wählen**
4. Bei "Termin bestätigt" → Option für Kalender-Eintrag

### Verfügbarkeit prüfen
1. **Keynote öffnen**
2. **"Verfügbarkeit prüfen" tippen**
3. Konflikte werden automatisch angezeigt

---

## 🎯 Hauptfunktionen auf einen Blick

| Aktion | Wie? |
|--------|------|
| **Neue Keynote** | "+" Button oben rechts |
| **Bearbeiten** | Swipe nach rechts ODER Keynote antippen |
| **Löschen** | Swipe nach links |
| **Suchen** | Suchleiste benutzen |
| **Filtern** | Filter-Icon (≡) oben links |
| **Statistiken** | Diagramm-Icon oben rechts |
| **Kontakt wählen** | In Detail-View → "Primären Kontakt wählen" |
| **Kalender-Eintrag** | Automatisch bei Status-Wechsel oder manuell in Detail-View |

---

## 🎨 Status-Übersicht

Die App verfolgt den Lifecycle deiner Keynotes:

```
1. Angefragt (Blau)
   ↓
2. Termin bestätigt, Honorar offeriert (Cyan)
   ↓
3. Honorar bestätigt (Mint)
   ↓
4. Thema, Inhalt und Zielpublikum vereinbart (Teal)
   ↓
5. Vertrag erstellt und Zustande gekommen (Grün)
   ↓
6. Durchgeführt und in Rechnung gestellt (Gelb)
   ↓
7. Bezahlt (Orange)
   ↓
8. Feedback angefragt (Lila)
   ↓
9. Abgeschlossen (Grau)

Von jedem Status: → Abgebrochen (Rot)
```

---

## 💡 Pro-Tipps

### Effizientes Arbeiten
- **Swipe-Gesten** nutzen für schnelles Bearbeiten/Löschen
- **Context Menu** (langes Drücken) für alle Optionen
- **Filter** nach Status für fokussiertes Arbeiten
- **Suchfunktion** für schnelles Finden

### Kalender-Integration
- "Save the Date" wird automatisch angeboten bei Termin-Bestätigung
- Einträge enthalten alle wichtigen Infos (Titel, Ort, Honorar)
- Beim Löschen einer Keynote wird auch der Kalender-Eintrag gelöscht
- Verfügbarkeitsprüfung erkennt Konflikte automatisch

### Kontakte-Integration
- Kontakte können direkt aus deinem Adressbuch ausgewählt werden
- Name, E-Mail und Telefon werden automatisch angezeigt
- Keine Duplikate - Verknüpfung mit existierendem Kontakt

### Statistiken
- Übersicht über alle Keynotes (gesamt, dieses Jahr, anstehend)
- Finanz-Tracking (bestätigt, offen, bezahlt)
- Status-Verteilung für schnellen Überblick

---

## 🔍 Suche & Filter

### Was wird durchsucht?
- Name des Anlasses
- Titel der Keynote
- Thema
- Organisation/Firma
- Ort

### Filter-Optionen
- Alle anzeigen
- Nach Status filtern (beliebiger Status)
- Kombination mit Suche möglich

---

## 📊 Beispiel-Workflow

### Typischer Keynote-Lifecycle

**Tag 1:** Anfrage erhalten
- ✅ Neue Keynote erstellen
- ✅ Status: "Angefragt"
- ✅ Verfügbarkeit prüfen

**Tag 3:** Termin bestätigt
- ✅ Status ändern → "Termin bestätigt, Honorar offeriert"
- ✅ "Save the Date" im Kalender erstellen (automatisch angeboten)

**Tag 5:** Honorar vereinbart
- ✅ Status ändern → "Honorar bestätigt"
- ✅ Honorar-Betrag eintragen

**Tag 10:** Inhalt abgestimmt
- ✅ Status ändern → "Thema, Inhalt und Zielpublikum vereinbart"
- ✅ Details ergänzen (Zielpublikum, Notizen)

**Tag 15:** Vertrag unterzeichnet
- ✅ Status ändern → "Vertrag erstellt und Zustande gekommen"

**Event-Tag:** Keynote durchgeführt
- ✅ Status ändern → "Durchgeführt und in Rechnung gestellt"

**1 Woche später:** Bezahlung erhalten
- ✅ Status ändern → "Bezahlt"

**2 Wochen später:** Feedback eingeholt
- ✅ Status ändern → "Feedback angefragt"
- ✅ Feedback in Notizen eintragen

**Abschluss:**
- ✅ Status ändern → "Abgeschlossen"
- ✅ Statistiken aktualisieren sich automatisch

---

## ⚠️ Häufige Probleme

| Problem | Lösung |
|---------|--------|
| App fragt nicht nach Berechtigungen | Info.plist Einträge prüfen |
| Kontakt-Name wird nicht angezeigt | Berechtigung in iOS Einstellungen erteilen |
| Kalender-Event wird nicht erstellt | Berechtigung in iOS Einstellungen erteilen |
| Daten werden nicht gespeichert | iOS 17+ als Deployment Target prüfen |

---

## 📞 Support

Bei Fragen oder Problemen:
1. README.md für detaillierte Dokumentation lesen
2. Sample Data in `SampleData.swift` für Beispiele ansehen
3. Code-Kommentare beachten

---

**Viel Erfolg mit deinen Keynotes! 🎤✨**
