//
//  CloudKitStatusView.swift
//  Keynotes
//
//  Created by Thomas Süssli on 08.02.2026.
//

import SwiftUI
import CloudKit
import Combine

/// View zur Anzeige des iCloud/CloudKit Sync-Status
struct CloudKitStatusView: View {
    @StateObject private var monitor = CloudKitSyncMonitor()
    @State private var showingDebugView = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: monitor.statusIcon)
                        .foregroundStyle(monitor.statusColor)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("iCloud Status")
                            .font(.headline)
                        Text(monitor.syncStatus)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if monitor.isChecking {
                        ProgressView()
                    }
                }
                .padding(.vertical, 4)
                
                if let lastSync = monitor.lastSyncDate {
                    LabeledContent("Letzte Überprüfung") {
                        Text(lastSync, style: .relative)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Synchronisation")
            } footer: {
                Text(monitor.statusDescription)
            }
            
            Section {
                Button {
                    Task {
                        await monitor.checkAccountStatus()
                    }
                } label: {
                    Label("Status aktualisieren", systemImage: "arrow.clockwise")
                }
                .disabled(monitor.isChecking)
                
                NavigationLink {
                    CloudKitDebugView()
                } label: {
                    Label("Erweiterte Diagnose", systemImage: "stethoscope")
                }
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Über iCloud Sync")
                        .font(.headline)
                    
                    Text("Deine Keynotes werden automatisch über iCloud auf all deinen Geräten synchronisiert. Stelle sicher, dass du bei iCloud angemeldet bist und iCloud Drive aktiviert ist.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                
                Link(destination: URL(string: "App-prefs:CASTLE")!) {
                    Label("iCloud Einstellungen öffnen", systemImage: "gear")
                }
            } header: {
                Text("Information")
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("⚠️ Hinweis zum CloudKit Dashboard")
                        .font(.headline)
                    
                    Text("SwiftData verwendet die **private CloudKit Database**. Diese ist aus Datenschutzgründen im CloudKit Dashboard nicht sichtbar.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    Text("So testest du die Synchronisation:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Verwende zwei Geräte mit derselben Apple ID", systemImage: "1.circle.fill")
                            .font(.caption)
                        Label("Erstelle auf Gerät 1 eine Keynote", systemImage: "2.circle.fill")
                            .font(.caption)
                        Label("Warte 10-30 Sekunden", systemImage: "3.circle.fill")
                            .font(.caption)
                        Label("Öffne die App auf Gerät 2", systemImage: "4.circle.fill")
                            .font(.caption)
                        Label("Die Keynote sollte erscheinen!", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Debugging")
            } footer: {
                Text("CloudKit synchronisiert automatisch im Hintergrund. Die private Database schützt deine Daten und ist nur auf deinen eigenen Geräten sichtbar.")
            }
        }
        .navigationTitle("iCloud Status")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await monitor.checkAccountStatus()
        }
    }
}

// MARK: - CloudKit Sync Monitor
@MainActor
class CloudKitSyncMonitor: ObservableObject {
    @Published var syncStatus: String = "Wird überprüft..."
    @Published var lastSyncDate: Date?
    @Published var isChecking: Bool = false
    @Published private var accountStatus: CKAccountStatus = .couldNotDetermine
    
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
    
    var statusDescription: String {
        switch accountStatus {
        case .available:
            return "Deine Keynotes werden automatisch mit iCloud synchronisiert."
        case .noAccount:
            return "Du bist nicht bei iCloud angemeldet. Melde dich in den Einstellungen an, um die Synchronisation zu aktivieren."
        case .restricted:
            return "Dein iCloud Zugriff ist eingeschränkt. Überprüfe die Einstellungen."
        case .couldNotDetermine:
            return "Der iCloud Status konnte nicht ermittelt werden. Bitte versuche es erneut."
        case .temporarilyUnavailable:
            return "iCloud ist vorübergehend nicht verfügbar. Die Synchronisation wird fortgesetzt, sobald die Verbindung wiederhergestellt ist."
        @unknown default:
            return "Unbekannter Status. Bitte versuche es erneut."
        }
    }
    
    func checkAccountStatus() async {
        isChecking = true
        
        do {
            let status = try await CKContainer.default().accountStatus()
            accountStatus = status
            
            switch status {
            case .available:
                syncStatus = "iCloud verfügbar"
            case .noAccount:
                syncStatus = "Nicht bei iCloud angemeldet"
            case .restricted:
                syncStatus = "iCloud eingeschränkt"
            case .couldNotDetermine:
                syncStatus = "Status unbekannt"
            case .temporarilyUnavailable:
                syncStatus = "Temporär nicht verfügbar"
            @unknown default:
                syncStatus = "Unbekannt"
            }
            
            lastSyncDate = Date()
        } catch {
            syncStatus = "Fehler: \(error.localizedDescription)"
            accountStatus = .couldNotDetermine
        }
        
        isChecking = false
    }
}

#Preview {
    NavigationStack {
        CloudKitStatusView()
    }
}
