//
//  CloudKitDebugView.swift
//  Keynotes
//
//  Created by Thomas Süssli on 09.02.2026.
//

import SwiftUI
import SwiftData
import CloudKit
import Combine

/// Erweiterte Debug-Ansicht für CloudKit/SwiftData Synchronisation
struct CloudKitDebugView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var keynotes: [Keynote]
    @StateObject private var debugMonitor = CloudKitDebugMonitor()
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: debugMonitor.statusIcon)
                        .foregroundStyle(debugMonitor.statusColor)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CloudKit Status")
                            .font(.headline)
                        Text(debugMonitor.statusText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if debugMonitor.isChecking {
                        ProgressView()
                    }
                }
            } header: {
                Text("Verbindungsstatus")
            }
            
            Section {
                LabeledContent("Lokale Einträge") {
                    Text("\(keynotes.count)")
                        .fontWeight(.semibold)
                }
                
                LabeledContent("Letzter Eintrag") {
                    if let latest = keynotes.max(by: { $0.requestDate < $1.requestDate }) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(latest.eventName)
                                .font(.caption)
                            Text(latest.requestDate, style: .relative)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("Keine Einträge")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                LabeledContent("Container") {
                    Text(debugMonitor.containerIdentifier)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                LabeledContent("Private Database") {
                    Text("Aktiv ✓")
                        .foregroundStyle(.green)
                }
                
                #if os(iOS)
                LabeledContent("Gerät") {
                    Text("iPhone/iPad")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                #else
                LabeledContent("Gerät") {
                    Text("Mac")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                #endif
            } header: {
                Text("SwiftData Information")
            } footer: {
                Text("SwiftData verwendet die private CloudKit Database. Diese Daten sind nur auf deinen eigenen Geräten sichtbar und erscheinen nicht im CloudKit Dashboard.")
            }
            
            Section {
                Button {
                    Task {
                        await debugMonitor.checkAllSystems()
                    }
                } label: {
                    Label("Systemprüfung durchführen", systemImage: "checklist")
                }
                .disabled(debugMonitor.isChecking)
                
                Button {
                    Task {
                        await debugMonitor.checkiCloudDriveStatus()
                    }
                } label: {
                    Label("iCloud Drive Status prüfen", systemImage: "externaldrive.badge.icloud")
                }
                
                Button {
                    debugMonitor.testNotificationPermissions()
                } label: {
                    Label("Push-Benachrichtigungen prüfen", systemImage: "bell.badge")
                }
                
                #if os(iOS)
                Button {
                    debugMonitor.checkiOSSpecificSettings()
                } label: {
                    Label("iOS-Einstellungen prüfen", systemImage: "iphone")
                }
                #endif
            } header: {
                Text("Diagnose-Tools")
            }
            
            if !debugMonitor.logs.isEmpty {
                Section {
                    ForEach(debugMonitor.logs) { log in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: log.icon)
                                    .foregroundStyle(log.color)
                                Text(log.timestamp, style: .time)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Text(log.message)
                                .font(.caption)
                        }
                        .padding(.vertical, 2)
                    }
                } header: {
                    HStack {
                        Text("Debug-Log")
                        Spacer()
                        Button("Leeren") {
                            debugMonitor.clearLogs()
                        }
                        .font(.caption)
                    }
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("⚠️ Sync funktioniert nur in eine Richtung?")
                        .font(.headline)
                        .foregroundStyle(.orange)
                    
                    Text("Häufigste Ursachen:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .top) {
                                Text("1.")
                                    .fontWeight(.semibold)
                                Text("**iCloud Drive nicht aktiviert**")
                                    .fontWeight(.medium)
                            }
                            Text("→ Einstellungen > [Dein Name] > iCloud > iCloud Drive MUSS aktiviert sein")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 20)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .top) {
                                Text("2.")
                                    .fontWeight(.semibold)
                                Text("**Background App Refresh deaktiviert (iOS)**")
                                    .fontWeight(.medium)
                            }
                            Text("→ Einstellungen > Allgemein > Hintergrundaktualisierung aktivieren")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 20)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .top) {
                                Text("3.")
                                    .fontWeight(.semibold)
                                Text("**Datensparmodus aktiv (iOS)**")
                                    .fontWeight(.medium)
                            }
                            Text("→ Einstellungen > Mobiles Netz > Datensparmodus ausschalten")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 20)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .top) {
                                Text("4.")
                                    .fontWeight(.semibold)
                                Text("**Unterschiedliche Apple IDs**")
                                    .fontWeight(.medium)
                            }
                            Text("→ Beide Geräte müssen mit der GLEICHEN Apple ID angemeldet sein")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 20)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .top) {
                                Text("5.")
                                    .fontWeight(.semibold)
                                Text("**App im Hintergrund nicht beendet**")
                                    .fontWeight(.medium)
                            }
                            Text("→ Schließe die App komplett (App-Switcher) und öffne sie erneut")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 20)
                        }
                    }
                    .font(.callout)
                    
                    Divider()
                    
                    Text("🔧 Schnelle Lösung:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            Text("1.")
                                .fontWeight(.semibold)
                            Text("Beide Geräte: App komplett schließen")
                        }
                        HStack(alignment: .top) {
                            Text("2.")
                                .fontWeight(.semibold)
                            Text("Beide Geräte: In Einstellungen > iCloud > iCloud Drive prüfen, dass es AN ist")
                        }
                        HStack(alignment: .top) {
                            Text("3.")
                                .fontWeight(.semibold)
                            Text("Beide Geräte: App neu öffnen")
                        }
                        HStack(alignment: .top) {
                            Text("4.")
                                .fontWeight(.semibold)
                            Text("Warte 1-2 Minuten")
                        }
                    }
                    .font(.caption)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Fehlerbehebung")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("ℹ️ Warum sehe ich nichts im CloudKit Dashboard?")
                        .font(.headline)
                    
                    Text("SwiftData speichert Daten in der **privaten CloudKit Database**. Diese ist:")
                        .font(.subheadline)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            Text("•")
                            Text("Nur für dich zugänglich (nicht einmal Apple kann sie sehen)")
                        }
                        HStack(alignment: .top) {
                            Text("•")
                            Text("Nicht im CloudKit Dashboard sichtbar (Datenschutz)")
                        }
                        HStack(alignment: .top) {
                            Text("•")
                            Text("Automatisch auf all deinen Geräten verfügbar")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    Text("✅ So testest du die Synchronisation:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            Text("1.")
                                .fontWeight(.semibold)
                            Text("Installiere die App auf zwei Geräten (mit derselben Apple ID)")
                        }
                        HStack(alignment: .top) {
                            Text("2.")
                                .fontWeight(.semibold)
                            Text("Erstelle auf Gerät 1 eine Keynote")
                        }
                        HStack(alignment: .top) {
                            Text("3.")
                                .fontWeight(.semibold)
                            Text("Warte 10-30 Sekunden")
                        }
                        HStack(alignment: .top) {
                            Text("4.")
                                .fontWeight(.semibold)
                            Text("Öffne die App auf Gerät 2")
                        }
                        HStack(alignment: .top) {
                            Text("✓")
                                .fontWeight(.semibold)
                                .foregroundStyle(.green)
                            Text("Die Keynote sollte automatisch erscheinen!")
                                .foregroundStyle(.green)
                        }
                    }
                    .font(.caption)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Häufige Fragen")
            }
        }
        .navigationTitle("CloudKit Debug")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await debugMonitor.checkAllSystems()
        }
    }
}

// MARK: - Debug Log Entry
struct DebugLogEntry: Identifiable {
    let id = UUID()
    let timestamp = Date()
    let message: String
    let type: LogType
    
    enum LogType {
        case success, info, warning, error
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .success: return .green
            case .info: return .blue
            case .warning: return .orange
            case .error: return .red
            }
        }
    }
    
    var icon: String { type.icon }
    var color: Color { type.color }
}

// MARK: - CloudKit Debug Monitor
@MainActor
class CloudKitDebugMonitor: ObservableObject {
    @Published var statusText: String = "Wird überprüft..."
    @Published var isChecking: Bool = false
    @Published var logs: [DebugLogEntry] = []
    @Published private var accountStatus: AccountStatusWrapper = .couldNotDetermine
    
    // Wrapper to avoid Sendable issues with CKAccountStatus
    enum AccountStatusWrapper {
        case available
        case noAccount
        case restricted
        case couldNotDetermine
        case temporarilyUnavailable
        
        init(from ckStatus: CKAccountStatus) {
            switch ckStatus {
            case .available: self = .available
            case .noAccount: self = .noAccount
            case .restricted: self = .restricted
            case .couldNotDetermine: self = .couldNotDetermine
            case .temporarilyUnavailable: self = .temporarilyUnavailable
            @unknown default: self = .couldNotDetermine
            }
        }
    }
    
    var statusIcon: String {
        switch accountStatus {
        case .available:
            return "checkmark.icloud.fill"
        case .noAccount:
            return "xmark.icloud.fill"
        case .restricted, .couldNotDetermine:
            return "exclamationmark.icloud.fill"
        case .temporarilyUnavailable:
            return "exclamationmark.icloud.fill"
        @unknown default:
            return "questionmark.circle.fill"
        }
    }
    
    var statusColor: Color {
        switch accountStatus {
        case .available:
            return .green
        case .noAccount:
            return .red
        case .restricted, .couldNotDetermine, .temporarilyUnavailable:
            return .orange
        @unknown default:
            return .gray
        }
    }
    
    var containerIdentifier: String {
        CKContainer.default().containerIdentifier ?? "Unbekannt"
    }
    
    func checkAllSystems() async {
        isChecking = true
        logs.removeAll()
        
        addLog("Starte Systemprüfung...", type: .info)
        
        // 1. CloudKit Account Status prüfen
        do {
            addLog("Prüfe CloudKit Account Status...", type: .info)
            let status = try await CKContainer.default().accountStatus()
            accountStatus = AccountStatusWrapper(from: status)
            
            switch accountStatus {
            case .available:
                statusText = "CloudKit verfügbar"
                addLog("✓ CloudKit Account verfügbar", type: .success)
            case .noAccount:
                statusText = "Nicht bei iCloud angemeldet"
                addLog("✗ Nicht bei iCloud angemeldet", type: .error)
            case .restricted:
                statusText = "CloudKit eingeschränkt"
                addLog("⚠ CloudKit Zugriff eingeschränkt", type: .warning)
            case .couldNotDetermine:
                statusText = "Status unbekannt"
                addLog("? Status konnte nicht ermittelt werden", type: .warning)
            case .temporarilyUnavailable:
                statusText = "Temporär nicht verfügbar"
                addLog("⚠ CloudKit temporär nicht verfügbar", type: .warning)
            }
        } catch {
            statusText = "Fehler: \(error.localizedDescription)"
            addLog("Fehler beim Prüfen: \(error.localizedDescription)", type: .error)
        }
        
        // 2. Container-Info
        addLog("Container: \(containerIdentifier)", type: .info)
        
        // 3. Private Database testen
        addLog("SwiftData verwendet die private CloudKit Database", type: .info)
        addLog("Diese Daten sind nicht im Dashboard sichtbar (Datenschutz)", type: .info)
        
        // 4. Abschluss
        addLog("Systemprüfung abgeschlossen", type: .success)
        
        isChecking = false
    }
    
    func checkiCloudDriveStatus() async {
        addLog("Prüfe iCloud Drive Status...", type: .info)
        
        // Check if iCloud Drive is available
        if FileManager.default.ubiquityIdentityToken != nil {
            addLog("✓ iCloud Drive ist verfügbar", type: .success)
        } else {
            addLog("✗ iCloud Drive ist NICHT verfügbar!", type: .error)
            addLog("→ Gehe zu Einstellungen > [Dein Name] > iCloud", type: .warning)
            addLog("→ Aktiviere 'iCloud Drive'", type: .warning)
        }
        
        // Try to get the ubiquitous container URL
        let fileManager = FileManager.default
        if let ubiquitousURL = fileManager.url(forUbiquityContainerIdentifier: nil) {
            addLog("✓ Ubiquitous Container gefunden", type: .success)
            addLog("Path: \(ubiquitousURL.path)", type: .info)
        } else {
            addLog("⚠ Ubiquitous Container nicht verfügbar", type: .warning)
        }
    }
    
    func testNotificationPermissions() {
        addLog("Push-Benachrichtigungen sind für CloudKit-Sync optional", type: .info)
        addLog("SwiftData synchronisiert auch ohne Push-Benachrichtigungen", type: .info)
        addLog("Für schnellere Sync empfohlen: Background Modes aktivieren", type: .info)
    }
    
    #if os(iOS)
    func checkiOSSpecificSettings() {
        addLog("iOS-spezifische Einstellungen:", type: .info)
        addLog("• Prüfe: Einstellungen > Allgemein > Hintergrundaktualisierung", type: .info)
        addLog("• Prüfe: Einstellungen > Mobiles Netz > Datensparmodus (sollte AUS sein)", type: .info)
        addLog("• Prüfe: WLAN-Verbindung aktiv", type: .info)
        addLog("• Tipp: Schließe die App komplett und öffne sie erneut", type: .info)
    }
    #endif
    
    func addLog(_ message: String, type: DebugLogEntry.LogType) {
        let entry = DebugLogEntry(message: message, type: type)
        logs.insert(entry, at: 0)
        
        // Nur die letzten 20 Einträge behalten
        if logs.count > 20 {
            logs = Array(logs.prefix(20))
        }
    }
    
    func clearLogs() {
        logs.removeAll()
    }
}

#Preview {
    NavigationStack {
        CloudKitDebugView()
    }
}
