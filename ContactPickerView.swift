//
//  ContactPickerView.swift
//  Keynotes
//
//  Created by Thomas Süssli on 09.02.2026.
//

import SwiftUI
import Contacts

/// Native SwiftUI Contact Picker für iOS und macOS
struct ContactPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ContactPickerViewModel
    @Binding var selectedContactID: String?
    
    init(contactsService: ContactsService, selectedContactID: Binding<String?>) {
        self._selectedContactID = selectedContactID
        self._viewModel = StateObject(wrappedValue: ContactPickerViewModel(contactsService: contactsService))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let error = viewModel.errorMessage {
                    ContentUnavailableView {
                        Label("Fehler", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Erneut versuchen") {
                            Task {
                                await viewModel.loadContacts()
                            }
                        }
                    }
                } else if viewModel.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Kontakte werden geladen...")
                            .foregroundStyle(.secondary)
                    }
                } else if viewModel.filteredContacts.isEmpty {
                    if viewModel.searchText.isEmpty {
                        ContentUnavailableView(
                            "Keine Kontakte",
                            systemImage: "person.slash",
                            description: Text("Es wurden keine Kontakte gefunden.")
                        )
                    } else {
                        ContentUnavailableView.search
                    }
                } else {
                    contactList
                }
            }
            .navigationTitle("Kontakt wählen")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "Kontakte durchsuchen...")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await viewModel.loadContacts()
        }
    }
    
    private var contactList: some View {
        List {
            ForEach(viewModel.filteredContacts, id: \.identifier) { contact in
                ContactRowButton(contact: contact) {
                    selectedContactID = contact.identifier
                    dismiss()
                }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Contact Row Button
struct ContactRowButton: View {
    let contact: CNContact
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Avatar oder Initialen
                contactAvatar
                
                // Kontakt-Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(CNContactFormatter.string(from: contact, style: .fullName) ?? "Unbekannt")
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    if !contact.organizationName.isEmpty {
                        Text(contact.organizationName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if let email = contact.emailAddresses.first?.value as? String {
                        Text(email)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var contactAvatar: some View {
        if let imageData = contact.imageData,
           let image = platformImage(from: imageData) {
            Image(platformImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        } else {
            // Initialen
            ZStack {
                Circle()
                    .fill(.tint.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text(initials)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.tint)
            }
        }
    }
    
    private var initials: String {
        let firstName = contact.givenName.prefix(1)
        let lastName = contact.familyName.prefix(1)
        return "\(firstName)\(lastName)".uppercased()
    }
    
    #if os(macOS)
    private func platformImage(from data: Data) -> NSImage? {
        NSImage(data: data)
    }
    #else
    private func platformImage(from data: Data) -> UIImage? {
        UIImage(data: data)
    }
    #endif
}

// MARK: - Platform Image Extension
extension Image {
    #if os(macOS)
    init(platformImage: NSImage) {
        self.init(nsImage: platformImage)
    }
    #else
    init(platformImage: UIImage) {
        self.init(uiImage: platformImage)
    }
    #endif
}

// MARK: - Preview
#Preview("Contact Picker") {
    ContactPickerView(
        contactsService: ContactsService(),
        selectedContactID: .constant(nil)
    )
}
#Preview("Contact Row") {
    let contact = CNMutableContact()
    contact.givenName = "Max"
    contact.familyName = "Mustermann"
    contact.organizationName = "Musterfirma AG"
    contact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: "max@example.com" as NSString)]
    
    return List {
        ContactRowButton(contact: contact) {
            print("Kontakt ausgewählt")
        }
    }
}


