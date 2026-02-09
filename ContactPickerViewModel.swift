//
//  ContactPickerViewModel.swift
//  Keynotes
//
//  Created by Thomas Süssli on 09.02.2026.
//

import Foundation
import Contacts
import SwiftUI
import Combine

/// ViewModel für den Contact Picker mit optimierter Performance
@MainActor
class ContactPickerViewModel: ObservableObject {
    @Published var contacts: [CNContact] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let contactsService: ContactsService
    private let contactStore = CNContactStore()
    
    init(contactsService: ContactsService) {
        self.contactsService = contactsService
    }
    
    var filteredContacts: [CNContact] {
        if searchText.isEmpty {
            return contacts
        }
        
        return contacts.filter { contact in
            let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? ""
            let organization = contact.organizationName
            let emails = contact.emailAddresses.map { $0.value as String }.joined()
            
            return fullName.localizedCaseInsensitiveContains(searchText) ||
                   organization.localizedCaseInsensitiveContains(searchText) ||
                   emails.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func loadContacts() async {
        isLoading = true
        errorMessage = nil
        
        // Berechtigung prüfen
        let hasAccess = await contactsService.requestAccess()
        
        guard hasAccess else {
            errorMessage = "Keine Berechtigung für Kontakte. Bitte erlaube den Zugriff in den Systemeinstellungen."
            isLoading = false
            return
        }
        
        // Kontakte laden
        do {
            contacts = try await fetchAllContacts()
        } catch {
            errorMessage = "Fehler beim Laden der Kontakte: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func fetchAllContacts() async throws -> [CNContact] {
        try await withCheckedThrowingContinuation { continuation in
            // Lade auf Background Thread für bessere Performance
            Task.detached(priority: .userInitiated) {
                let store = CNContactStore()
                let keysToFetch: [CNKeyDescriptor] = [
                    CNContactGivenNameKey as CNKeyDescriptor,
                    CNContactFamilyNameKey as CNKeyDescriptor,
                    CNContactOrganizationNameKey as CNKeyDescriptor,
                    CNContactEmailAddressesKey as CNKeyDescriptor,
                    CNContactPhoneNumbersKey as CNKeyDescriptor,
                    CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                    CNContactImageDataKey as CNKeyDescriptor
                ]
                
                let request = CNContactFetchRequest(keysToFetch: keysToFetch)
                request.sortOrder = .givenName
                
                var fetchedContacts: [CNContact] = []
                
                do {
                    try store.enumerateContacts(with: request) { contact, _ in
                        fetchedContacts.append(contact)
                    }
                    continuation.resume(returning: fetchedContacts)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
