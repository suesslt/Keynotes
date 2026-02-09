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
