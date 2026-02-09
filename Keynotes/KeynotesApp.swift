//
//  KeynotesApp.swift
//  Keynotes
//
//  Created by Thomas Süssli on 08.02.2026.
//

import SwiftUI
import SwiftData

@main
struct KeynotesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Keynote.self,
        ])
        
        // ModelConfiguration für iCloud-Sync aktivieren
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic // Aktiviert iCloud-Synchronisation
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
// MARK: - CloudKit Sync Status (Optional)
// Wenn du den Sync-Status überwachen möchtest, kannst du dies hinzufügen:
/*
import CloudKit

@MainActor
class CloudKitSyncMonitor: ObservableObject {
    @Published var syncStatus: String = "Unbekannt"
    @Published var lastSyncDate: Date?
    
    func checkAccountStatus() {
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self.syncStatus = "iCloud verfügbar"
                case .noAccount:
                    self.syncStatus = "Nicht bei iCloud angemeldet"
                case .restricted:
                    self.syncStatus = "iCloud eingeschränkt"
                case .couldNotDetermine:
                    self.syncStatus = "Status unbekannt"
                case .temporarilyUnavailable:
                    self.syncStatus = "Temporär nicht verfügbar"
                @unknown default:
                    self.syncStatus = "Unbekannt"
                }
            }
        }
    }
}
*/

