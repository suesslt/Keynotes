//
//  KeynotePDFGenerator.swift
//  Auftritte
//
//  Created by Thomas Süssli on 10.02.2026.
//

import Foundation
import UIKit
import SwiftUI

/// Service-Klasse zur Generierung von PDF-Dokumenten aus Keynote-Listen
@MainActor
class KeynotePDFGenerator {
    
    /// Generiert ein PDF-Dokument mit einer Liste aller Keynotes
    /// - Parameters:
    ///   - keynotes: Array von Keynotes (wird nach Datum sortiert)
    ///   - title: Titel des Dokuments (z.B. "Auftrittsübersicht 2026")
    ///   - generationDate: Datum der Erstellung (Standard: aktuelles Datum)
    /// - Returns: PDF-Daten als Data-Objekt
    static func generatePDF(
        keynotes: [Keynote],
        title: String = "Auftrittsübersicht",
        generationDate: Date = Date()
    ) -> Data {
        // Keynotes chronologisch sortieren
        let sortedKeynotes = keynotes.sorted { $0.eventDate < $1.eventDate }
        
        // PDF-Format konfigurieren
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let data = renderer.pdfData { context in
            var yPosition: CGFloat = 60
            let margin: CGFloat = 40
            let pageWidth = pageRect.width - (margin * 2)
            var currentPage = 1
            
            // Erste Seite beginnen
            context.beginPage()
            
            // Titel zeichnen
            yPosition = drawTitle(title, at: yPosition, pageWidth: pageWidth, margin: margin)
            
            // Erstellungsdatum zeichnen
            yPosition = drawGenerationDate(generationDate, at: yPosition, pageWidth: pageWidth, margin: margin)
            
            // Trennlinie
            yPosition = drawSeparator(at: yPosition, pageWidth: pageWidth, margin: margin)
            
            // Zusammenfassung
            yPosition = drawSummary(count: sortedKeynotes.count, at: yPosition, pageWidth: pageWidth, margin: margin)
            
            yPosition += 20
            
            // Alle Keynotes durchlaufen
            for (index, keynote) in sortedKeynotes.enumerated() {
                // Neue Seite beginnen, wenn nicht genug Platz
                if yPosition > pageRect.height - 150 {
                    drawFooter(pageNumber: currentPage, pageRect: pageRect, margin: margin)
                    context.beginPage()
                    currentPage += 1
                    yPosition = 60
                }
                
                yPosition = drawKeynote(
                    keynote,
                    index: index + 1,
                    at: yPosition,
                    pageWidth: pageWidth,
                    margin: margin
                )
                
                yPosition += 25
            }
            
            // Fußzeile für die letzte Seite
            drawFooter(pageNumber: currentPage, pageRect: pageRect, margin: margin)
        }
        
        return data
    }
    
    // MARK: - Drawing Functions
    
    private static func drawTitle(_ title: String, at yPosition: CGFloat, pageWidth: CGFloat, margin: CGFloat) -> CGFloat {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.black
        ]
        
        let titleRect = CGRect(x: margin, y: yPosition, width: pageWidth, height: 40)
        title.draw(in: titleRect, withAttributes: titleAttributes)
        
        return yPosition + 40
    }
    
    private static func drawGenerationDate(_ date: Date, at yPosition: CGFloat, pageWidth: CGFloat, margin: CGFloat) -> CGFloat {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "de_DE")
        
        let dateString = "Erstellt am: \(dateFormatter.string(from: date))"
        
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.darkGray
        ]
        
        let dateRect = CGRect(x: margin, y: yPosition, width: pageWidth, height: 20)
        dateString.draw(in: dateRect, withAttributes: dateAttributes)
        
        return yPosition + 25
    }
    
    private static func drawSeparator(at yPosition: CGFloat, pageWidth: CGFloat, margin: CGFloat) -> CGFloat {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        context?.setStrokeColor(UIColor.lightGray.cgColor)
        context?.setLineWidth(1)
        context?.move(to: CGPoint(x: margin, y: yPosition))
        context?.addLine(to: CGPoint(x: margin + pageWidth, y: yPosition))
        context?.strokePath()
        
        context?.restoreGState()
        
        return yPosition + 20
    }
    
    private static func drawSummary(count: Int, at yPosition: CGFloat, pageWidth: CGFloat, margin: CGFloat) -> CGFloat {
        let summaryText = "Anzahl Auftritte: \(count)"
        
        let summaryAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        
        let summaryRect = CGRect(x: margin, y: yPosition, width: pageWidth, height: 20)
        summaryText.draw(in: summaryRect, withAttributes: summaryAttributes)
        
        return yPosition + 25
    }
    
    private static func drawKeynote(
        _ keynote: Keynote,
        index: Int,
        at yPosition: CGFloat,
        pageWidth: CGFloat,
        margin: CGFloat
    ) -> CGFloat {
        var currentY = yPosition
        
        // Hintergrund für jeden Eintrag
        let backgroundRect = CGRect(x: margin, y: currentY - 5, width: pageWidth, height: 95)
        let backgroundColor = index % 2 == 0 ? UIColor(white: 0.95, alpha: 1.0) : UIColor.white
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.setFillColor(backgroundColor.cgColor)
        
        let path = UIBezierPath(roundedRect: backgroundRect, cornerRadius: 8)
        path.fill()
        
        context?.restoreGState()
        
        // Nummerierung und Event-Name
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "de_DE")
        
        let headerText = "\(index). \(keynote.eventName)"
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
            .foregroundColor: UIColor.black
        ]
        
        let headerRect = CGRect(x: margin + 10, y: currentY, width: pageWidth - 20, height: 20)
        headerText.draw(in: headerRect, withAttributes: headerAttributes)
        currentY += 22
        
        // Datum und Status
        let dateString = dateFormatter.string(from: keynote.eventDate)
        let statusText = "\(dateString) • \(keynote.status.rawValue)"
        
        let statusAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.darkGray
        ]
        
        let statusRect = CGRect(x: margin + 10, y: currentY, width: pageWidth - 20, height: 18)
        statusText.draw(in: statusRect, withAttributes: statusAttributes)
        currentY += 18
        
        // Keynote-Titel
        if !keynote.keynoteTitle.isEmpty {
            let titleText = "Thema: \(keynote.keynoteTitle)"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11, weight: .regular),
                .foregroundColor: UIColor.black
            ]
            
            let titleRect = CGRect(x: margin + 10, y: currentY, width: pageWidth - 20, height: 16)
            titleText.draw(in: titleRect, withAttributes: titleAttributes)
            currentY += 16
        }
        
        // Ort und Organisation
        var detailsText = ""
        if !keynote.location.isEmpty {
            detailsText += "📍 \(keynote.location)"
        }
        if !keynote.clientOrganization.isEmpty {
            if !detailsText.isEmpty {
                detailsText += " • "
            }
            detailsText += "🏢 \(keynote.clientOrganization)"
        }
        
        if !detailsText.isEmpty {
            let detailsAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor.darkGray
            ]
            
            let detailsRect = CGRect(x: margin + 10, y: currentY, width: pageWidth - 20, height: 16)
            detailsText.draw(in: detailsRect, withAttributes: detailsAttributes)
            currentY += 16
        }
        
        // Dauer und Honorar
        let durationText = String(format: "⏱️ %.0f Min.", keynote.duration)
        let feeFormatter = NumberFormatter()
        feeFormatter.numberStyle = .currency
        feeFormatter.currencyCode = "CHF"
        let feeString = feeFormatter.string(from: keynote.agreedFee as NSDecimalNumber) ?? "CHF 0.00"
        
        let infoText = "\(durationText) • 💰 \(feeString)"
        let infoAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: UIColor.darkGray
        ]
        
        let infoRect = CGRect(x: margin + 10, y: currentY, width: pageWidth - 20, height: 16)
        infoText.draw(in: infoRect, withAttributes: infoAttributes)
        currentY += 16
        
        return currentY
    }
    
    private static func drawFooter(pageNumber: Int, pageRect: CGRect, margin: CGFloat) {
        let footerText = "Seite \(pageNumber)"
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: UIColor.darkGray
        ]
        
        let footerSize = footerText.size(withAttributes: footerAttributes)
        let footerRect = CGRect(
            x: (pageRect.width - footerSize.width) / 2,
            y: pageRect.height - margin / 2,
            width: footerSize.width,
            height: footerSize.height
        )
        
        footerText.draw(in: footerRect, withAttributes: footerAttributes)
    }
}
