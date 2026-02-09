//
//  ContactMigrationHelper.swift
//  Keynotes
//
//  Created by Thomas Süssli on 09.02.2026.
//

import Foundation
import SwiftData

/// Helper to migrate from old contact IDs to new KeynoteContact model
@MainActor
class ContactMigrationHelper {
    private let contactsService: ContactsService
    
    init(contactsService: ContactsService) {
        self.contactsService = contactsService
    }
    
    /// Migrate all keynotes that have old contact IDs but no KeynoteContact
    func migrateKeynotes(context: ModelContext) async {
        let descriptor = FetchDescriptor<Keynote>()
        
        do {
            let keynotes = try context.fetch(descriptor)
            var migratedCount = 0
            var cleanedUpCount = 0
            
            for keynote in keynotes {
                // Only migrate if we have old ID but no new contact data
                if let oldContactID = keynote.primaryContactID,
                   keynote.primaryContact == nil {
                    
                    // Try to create KeynoteContact from old ID
                    if let keynoteContact = contactsService.createKeynoteContact(from: oldContactID) {
                        keynote.primaryContact = keynoteContact
                        migratedCount += 1
                    } else {
                        // Kontakt existiert nicht mehr - alte ID entfernen
                        keynote.primaryContactID = nil
                        cleanedUpCount += 1
                    }
                }
            }
            
            if migratedCount > 0 || cleanedUpCount > 0 {
                try context.save()
                if migratedCount > 0 {
                    print("✅ Migration erfolgreich: \(migratedCount) Kontakte migriert")
                }
                if cleanedUpCount > 0 {
                    print("🧹 \(cleanedUpCount) veraltete Kontakt-IDs bereinigt")
                }
            }
        } catch {
            print("❌ Fehler bei Kontakt-Migration: \(error)")
        }
    }
}
