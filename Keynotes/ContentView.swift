//
//  ContentView.swift
//  Keynotes
//
//  Created by Thomas Süssli on 08.02.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Keynote.eventDate, order: .forward) private var keynotes: [Keynote]
    
    @State private var searchText = ""
    @State private var showingNewKeynote = false
    @State private var selectedKeynote: Keynote?
    @State private var statusFilter: KeynoteStatus?
    @State private var showingStats = false
    @StateObject private var calendarService = CalendarService()
    @StateObject private var errorHandler = ErrorHandler()

    var filteredKeynotes: [Keynote] {
        var filtered = keynotes
        
        // Status-Filter
        if let status = statusFilter {
            filtered = filtered.filter { $0.status == status }
        }
        
        // Suchtext-Filter
        if !searchText.isEmpty {
            filtered = filtered.filter { keynote in
                keynote.eventName.localizedCaseInsensitiveContains(searchText) ||
                keynote.keynoteTitle.localizedCaseInsensitiveContains(searchText) ||
                keynote.keynoteTheme.localizedCaseInsensitiveContains(searchText) ||
                keynote.clientOrganization.localizedCaseInsensitiveContains(searchText) ||
                keynote.location.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(filteredKeynotes) { keynote in
                    NavigationLink(value: keynote) {
                        KeynoteRowView(keynote: keynote)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteKeynote(keynote)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            selectedKeynote = keynote
                        } label: {
                            Label("Bearbeiten", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    .contextMenu {
                        Button {
                            selectedKeynote = keynote
                        } label: {
                            Label("Bearbeiten", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            deleteKeynote(keynote)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Keynotes")
            .searchable(text: $searchText, prompt: "Suchen...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: { statusFilter = nil }) {
                            Label("Alle", systemImage: statusFilter == nil ? "checkmark" : "")
                        }
                        
                        Divider()
                        
                        ForEach(KeynoteStatus.allCases) { status in
                            Button(action: { statusFilter = status }) {
                                HStack {
                                    Circle()
                                        .fill(status.color)
                                        .frame(width: 12, height: 12)
                                    Text(status.rawValue)
                                    if statusFilter == status {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingStats = true }) {
                        Label("Statistiken", systemImage: "chart.bar.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewKeynote = true }) {
                        Label("Neue Keynote", systemImage: "plus")
                    }
                }
            }
            .navigationDestination(for: Keynote.self) { keynote in
                KeynoteDetailView(keynote: keynote, isNewKeynote: false)
            }
            .sheet(isPresented: $showingNewKeynote) {
                NavigationStack {
                    KeynoteDetailView(keynote: Keynote(), isNewKeynote: true)
                }
            }
            .sheet(item: $selectedKeynote) { keynote in
                NavigationStack {
                    KeynoteDetailView(keynote: keynote, isNewKeynote: false)
                }
            }
            .sheet(isPresented: $showingStats) {
                NavigationStack {
                    KeynoteStatsView()
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Fertig") {
                                    showingStats = false
                                }
                            }
                        }
                }
            }
        } detail: {
            ContentUnavailableView(
                "Wähle eine Keynote",
                systemImage: "mic.fill",
                description: Text("Wähle eine Keynote aus der Liste oder erstelle eine neue.")
            )
        }
        .task {
            _ = await calendarService.requestAccess()
        }
        .errorAlert(errorHandler: errorHandler)
    }

    private func deleteKeynote(_ keynote: Keynote) {
        withAnimation {
            // Kalender-Event löschen, falls vorhanden
            if let eventID = keynote.calendarEventID {
                Task {
                    try? await calendarService.deleteEvent(eventID: eventID)
                }
            }
            modelContext.delete(keynote)
        }
    }
}

// MARK: - Keynote Row View
struct KeynoteRowView: View {
    let keynote: Keynote
    
    var body: some View {
        KeynoteListItemView(
            keynote: keynote,
            contactName: keynote.primaryContact?.fullName
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer())
}
