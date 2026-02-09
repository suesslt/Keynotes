//
//  KeynoteDetailView.swift
//  Keynotes
//
//  Created by Thomas Süssli on 08.02.2026.
//

import SwiftUI
import SwiftData
import ContactsUI
import EventKit

struct KeynoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var keynote: Keynote
    @StateObject private var calendarService = CalendarService()
    @StateObject private var contactsService = ContactsService()
    
    @State private var showingContactPicker = false
    @State private var showingStatusChange = false
    @State private var showingSaveCalendarAlert = false
    @State private var availabilityEvents: [String] = []
    @State private var isCheckingAvailability = false
    @State private var contactPickerCoordinator: ContactPickerCoordinator?
    
    var isNewKeynote: Bool
    
    var body: some View {
        Form {
            basicInfoSection
            detailsSection
            contactSection
            statusSection
            availabilitySection
            notesSection
        }
        .navigationTitle(isNewKeynote ? "Neue Keynote" : keynote.eventName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if isNewKeynote {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                if isNewKeynote {
                    Button("Sichern") {
                        saveNewKeynote()
                    }
                    .disabled(keynote.eventName.isEmpty || keynote.keynoteTitle.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingStatusChange) {
            StatusChangeView(keynote: keynote, calendarService: calendarService)
        }
        .background(ContactPickerPresenter(isPresented: $showingContactPicker, 
                                           selectedContactID: $keynote.primaryContactID,
                                           coordinator: $contactPickerCoordinator))
        .alert("Save the Date erstellt", isPresented: $showingSaveCalendarAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Ein Kalender-Eintrag wurde erfolgreich erstellt.")
        }
    }
    
    private var basicInfoSection: some View {
        Section("Grundinformationen") {
            TextField("Name des Anlasses", text: $keynote.eventName)
            
            DatePicker("Datum und Zeit", selection: $keynote.eventDate)
            
            TextField("Titel der Keynote", text: $keynote.keynoteTitle)
            
            TextField("Thema", text: $keynote.keynoteTheme)
            
            HStack {
                Text("Redezeit")
                Spacer()
                TextField("Minuten", value: $keynote.duration, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                Text("Min.")
            }
        }
    }
    
    private var detailsSection: some View {
        Section("Details") {
            TextField("Firma/Organisation", text: $keynote.clientOrganization)
            
            HStack {
                Text("Honorar")
                Spacer()
                TextField("Betrag", value: $keynote.agreedFee, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 120)
                Text("CHF")
            }
            
            TextField("Zielpublikum", text: $keynote.targetAudience)
            
            TextField("Ort", text: $keynote.location)
            
            DatePicker("Anfragedatum", selection: $keynote.requestDate, displayedComponents: .date)
        }
    }
    
    private var contactSection: some View {
        Section("Kontakt") {
            if let contactID = keynote.primaryContactID {
                HStack {
                    VStack(alignment: .leading) {
                        Text(contactsService.getContactName(identifier: contactID))
                            .font(.headline)
                        if let email = contactsService.getContactEmail(identifier: contactID) {
                            Text(email)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if let phone = contactsService.getContactPhone(identifier: contactID) {
                            Text(phone)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Ändern") {
                        showingContactPicker = true
                    }
                }
            } else {
                Button(action: { showingContactPicker = true }) {
                    Label("Primären Kontakt wählen", systemImage: "person.crop.circle.badge.plus")
                }
            }
        }
    }
    
    private var statusSection: some View {
        Section("Status") {
            HStack {
                Circle()
                    .fill(keynote.status.color)
                    .frame(width: 12, height: 12)
                Text(keynote.status.rawValue)
                Spacer()
            }
            
            if !keynote.status.nextStatus.isEmpty {
                Button("Status ändern") {
                    showingStatusChange = true
                }
            }
            
            if keynote.calendarEventID != nil {
                Label("Kalender-Eintrag vorhanden", systemImage: "calendar.badge.checkmark")
                    .foregroundStyle(.green)
            } else if keynote.status == .dateConfirmedFeeOffered || keynote.status.rawValue > KeynoteStatus.dateConfirmedFeeOffered.rawValue {
                Button("Save the Date erstellen") {
                    Task {
                        do {
                            if let eventID = try await calendarService.createSaveTheDate(for: keynote) {
                                keynote.calendarEventID = eventID
                                showingSaveCalendarAlert = true
                            }
                        } catch {
                            print("Fehler beim Erstellen des Kalender-Eintrags: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    private var availabilitySection: some View {
        Section("Verfügbarkeit") {
            Button(action: checkAvailability) {
                HStack {
                    Label("Verfügbarkeit prüfen", systemImage: "calendar.badge.clock")
                    if isCheckingAvailability {
                        Spacer()
                        ProgressView()
                    }
                }
            }
            .disabled(isCheckingAvailability)
            
            if !availabilityEvents.isEmpty {
                ForEach(availabilityEvents, id: \.self) { event in
                    Label(event, systemImage: "calendar.badge.exclamationmark")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
            } else if isCheckingAvailability == false && !availabilityEvents.isEmpty == false {
                Label("Keine Konflikte gefunden", systemImage: "checkmark.circle")
                    .foregroundStyle(.green)
            }
        }
    }
    
    private var notesSection: some View {
        Section("Notizen") {
            TextEditor(text: $keynote.notes)
                .frame(minHeight: 100)
        }
    }
    
    private func saveNewKeynote() {
        modelContext.insert(keynote)
        dismiss()
    }
    
    private func checkAvailability() {
        isCheckingAvailability = true
        
        Task {
            await calendarService.requestAccess()
            
            let events = calendarService.checkAvailability(
                for: keynote.eventDate,
                duration: keynote.duration,
                excludingEventID: keynote.calendarEventID
            )
            
            availabilityEvents = events.map { event in
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                let timeString = formatter.string(from: event.startDate)
                return "\(timeString): \(event.title ?? "Unbekannt")"
            }
            
            isCheckingAvailability = false
        }
    }
}

// MARK: - Status Change View
struct StatusChangeView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var keynote: Keynote
    var calendarService: CalendarService
    
    @State private var selectedStatus: KeynoteStatus?
    @State private var showingSaveCalendarOption = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Mögliche nächste Status") {
                    ForEach(keynote.status.nextStatus) { status in
                        Button(action: {
                            selectedStatus = status
                            if status == .dateConfirmedFeeOffered && keynote.calendarEventID == nil {
                                showingSaveCalendarOption = true
                            } else {
                                updateStatus(to: status, createCalendarEvent: false)
                            }
                        }) {
                            HStack {
                                Circle()
                                    .fill(status.color)
                                    .frame(width: 12, height: 12)
                                Text(status.rawValue)
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Status ändern")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
            .alert("Save the Date erstellen?", isPresented: $showingSaveCalendarOption) {
                Button("Ja", role: .none) {
                    if let status = selectedStatus {
                        updateStatus(to: status, createCalendarEvent: true)
                    }
                }
                Button("Nein", role: .cancel) {
                    if let status = selectedStatus {
                        updateStatus(to: status, createCalendarEvent: false)
                    }
                }
            } message: {
                Text("Möchtest du einen 'Save the Date' Eintrag im Kalender erstellen?")
            }
        }
    }
    
    private func updateStatus(to status: KeynoteStatus, createCalendarEvent: Bool) {
        keynote.status = status
        
        if createCalendarEvent {
            Task {
                do {
                    if let eventID = try await calendarService.createSaveTheDate(for: keynote) {
                        keynote.calendarEventID = eventID
                    }
                } catch {
                    print("Fehler beim Erstellen des Kalender-Eintrags: \(error)")
                }
            }
        }
        
        dismiss()
    }
}

// MARK: - Contact Picker Coordinator
class ContactPickerCoordinator: NSObject, CNContactPickerDelegate {
    var selectedContactID: Binding<String?>
    var onDismiss: () -> Void
    
    init(selectedContactID: Binding<String?>, onDismiss: @escaping () -> Void) {
        self.selectedContactID = selectedContactID
        self.onDismiss = onDismiss
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        selectedContactID.wrappedValue = contact.identifier
        onDismiss()
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        onDismiss()
    }
    
    func presentPicker(from viewController: UIViewController) {
        let picker = CNContactPickerViewController()
        picker.delegate = self
        viewController.present(picker, animated: true)
    }
}

// MARK: - Contact Picker Presenter
struct ContactPickerPresenter: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedContactID: String?
    @Binding var coordinator: ContactPickerCoordinator?
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Verwende Task, um State-Änderungen außerhalb des View-Updates durchzuführen
        if isPresented && coordinator == nil {
            Task { @MainActor in
                let newCoordinator = ContactPickerCoordinator(
                    selectedContactID: $selectedContactID,
                    onDismiss: {
                        isPresented = false
                        coordinator = nil
                    }
                )
                coordinator = newCoordinator
                
                // Warte kurz, bis der View Controller in der Hierarchie ist
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    var topVC = rootVC
                    while let presented = topVC.presentedViewController {
                        topVC = presented
                    }
                    newCoordinator.presentPicker(from: topVC)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        KeynoteDetailView(keynote: Keynote(), isNewKeynote: true)
    }
    .modelContainer(for: Keynote.self, inMemory: true)
}
