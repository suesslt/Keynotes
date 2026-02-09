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
            KeynoteContact.self, // Neues Model für iCloud-Sync
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
    
    @StateObject private var contactsService = ContactsService()
    @State private var hasMigrated = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // Einmalige Migration alter Kontakt-IDs zu neuen KeynoteContact-Objekten
                    if !hasMigrated {
                        await migrateContacts()
                        hasMigrated = true
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    @MainActor
    private func migrateContacts() async {
        let migrationHelper = ContactMigrationHelper(contactsService: contactsService)
        await migrationHelper.migrateKeynotes(context: sharedModelContainer.mainContext)
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

