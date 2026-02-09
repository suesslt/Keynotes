//
//  Keynote.swift
//  Keynotes
//
//  Created by Thomas Süssli on 08.02.2026.
//

import Foundation
import SwiftData

@Model
final class Keynote {
    var eventName: String
    var eventDate: Date
    var keynoteTitle: String
    var keynoteTheme: String
    var duration: TimeInterval // in Minuten
    var clientOrganization: String
    var primaryContactID: String? // CNContact Identifier
    var agreedFee: Decimal
    var targetAudience: String
    var location: String
    var statusRaw: String
    var requestDate: Date
    var calendarEventID: String? // EventKit Event Identifier
    var notes: String
    
    // Computed property für Status
    var status: KeynoteStatus {
        get {
            KeynoteStatus(rawValue: statusRaw) ?? .requested
        }
        set {
            statusRaw = newValue.rawValue
        }
    }
    
    init(
        eventName: String = "",
        eventDate: Date = Date(),
        keynoteTitle: String = "",
        keynoteTheme: String = "",
        duration: TimeInterval = 60,
        clientOrganization: String = "",
        primaryContactID: String? = nil,
        agreedFee: Decimal = 0,
        targetAudience: String = "",
        location: String = "",
        status: KeynoteStatus = .requested,
        requestDate: Date = Date(),
        calendarEventID: String? = nil,
        notes: String = ""
    ) {
        self.eventName = eventName
        self.eventDate = eventDate
        self.keynoteTitle = keynoteTitle
        self.keynoteTheme = keynoteTheme
        self.duration = duration
        self.clientOrganization = clientOrganization
        self.primaryContactID = primaryContactID
        self.agreedFee = agreedFee
        self.targetAudience = targetAudience
        self.location = location
        self.statusRaw = status.rawValue
        self.requestDate = requestDate
        self.calendarEventID = calendarEventID
        self.notes = notes
    }
}
