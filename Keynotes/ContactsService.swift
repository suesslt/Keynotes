//
//  ContactsService.swift
//  Keynotes
//
//  Created by Thomas Süssli on 08.02.2026.
//

import Foundation
import Combine
import Contacts
import ContactsUI

@MainActor
class ContactsService: ObservableObject {
    private let contactStore = CNContactStore()
    @Published var authorizationStatus: CNAuthorizationStatus
    
    init() {
        self.authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    }
    
    func requestAccess() async -> Bool {
        do {
            let granted = try await contactStore.requestAccess(for: .contacts)
            authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
            return granted
        } catch {
            print("Fehler beim Anfordern des Kontaktzugriffs: \(error)")
            return false
        }
    }
    
    func getContact(identifier: String) -> CNContact? {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactOrganizationNameKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName)
        ]
        
        do {
            return try contactStore.unifiedContact(withIdentifier: identifier, keysToFetch: keysToFetch)
        } catch {
            print("Fehler beim Laden des Kontakts: \(error)")
            return nil
        }
    }
    
    func getContactName(identifier: String) -> String {
        guard let contact = getContact(identifier: identifier) else {
            return "Unbekannt"
        }
        
        let formatter = CNContactFormatter()
        return formatter.string(from: contact) ?? "Unbekannt"
    }
    
    func getContactEmail(identifier: String) -> String? {
        guard let contact = getContact(identifier: identifier),
              let firstEmail = contact.emailAddresses.first else {
            return nil
        }
        
        return firstEmail.value as String
    }
    
    func getContactPhone(identifier: String) -> String? {
        guard let contact = getContact(identifier: identifier),
              let firstPhone = contact.phoneNumbers.first else {
            return nil
        }
        
        return firstPhone.value.stringValue
    }
}
