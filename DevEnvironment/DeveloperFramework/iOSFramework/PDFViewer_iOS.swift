//
//  PDFViewer_iOS.swift
//  DevEnvironment
//
//  Created by Poovarasi, Deeksha on 05/03/25.
//

#if os(iOS)
import SwiftUI
import UIKit
import PDFKit
import PhotosUI
public func DrawTable(headers: [String], dataSets: [[String]], startY: inout CGFloat, landScape:Bool = false, currentContext: UIGraphicsPDFRendererContext?) {
    guard let ctx = currentContext else {
        print("❌ No current graphics context.")
        return
    }
    var pageSize = CGSize(width: 595.2, height: 841.8)
    if landScape {
        pageSize = CGSize(width: 841.8, height: 595.2)
    }
    let margin: CGFloat = 40
    var tableY: CGFloat = startY
    let rowHeight: CGFloat = 50
    let maxTableHeight = pageSize.height - (2 * margin)

    func drawText(_ text: String, in rect: CGRect, attributes: [NSAttributedString.Key: Any], alignment: NSTextAlignment = .center) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = .byWordWrapping

        var newAttributes = attributes
        newAttributes[.paragraphStyle] = paragraphStyle

        let attributedString = NSAttributedString(string: text, attributes: newAttributes)
        let maxTextRect = rect.insetBy(dx: 5, dy: 5)
        let boundingRect = attributedString.boundingRect(
            with: CGSize(width: maxTextRect.width, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        let textY = maxTextRect.origin.y + (maxTextRect.height - boundingRect.height) / 2
        let drawRect = CGRect(x: maxTextRect.origin.x, y: textY, width: maxTextRect.width, height: boundingRect.height)
        attributedString.draw(with: drawRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
    }

    func startNewPage() {
        ctx.beginPage()
        tableY = margin
    }

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    let headerAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 14, weight: .bold),
        .paragraphStyle: paragraphStyle
    ]
    let cellAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 14),
        .paragraphStyle: paragraphStyle
    ]
    let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]

    var columnWidths = [CGFloat](repeating: 0, count: headers.count)

    for (index, headerText) in headers.enumerated() {
        let size = NSString(string: headerText).size(withAttributes: attributes)
        columnWidths[index] = max(columnWidths[index], size.width)
    }

    for row in dataSets {
        for (index, text) in row.enumerated() where index < columnWidths.count {
            let size = NSString(string: text).size(withAttributes: attributes)
            columnWidths[index] = max(columnWidths[index], size.width)
        }
    }

    columnWidths = columnWidths.map { $0 + 20 }
    let totalColumnWidth = columnWidths.reduce(0, +)
    let startX = (pageSize.width - totalColumnWidth) / 2

    for index in 0..<headers.count {
        let x = startX + columnWidths.prefix(index).reduce(0, +)
        let cellRect = CGRect(x: x, y: tableY, width: columnWidths[index], height: rowHeight)
        ctx.cgContext.stroke(cellRect)
        drawText(headers[index], in: cellRect, attributes: headerAttributes)
    }
    tableY += rowHeight

    for row in dataSets {
        if tableY + rowHeight > maxTableHeight {
            startNewPage()
            for index in 0..<headers.count {
                let x = startX + columnWidths.prefix(index).reduce(0, +)
                let cellRect = CGRect(x: x, y: tableY, width: columnWidths[index], height: rowHeight)
                ctx.cgContext.stroke(cellRect)
                drawText(headers[index], in: cellRect, attributes: headerAttributes)
            }
            tableY += rowHeight
        }

        for index in 0..<min(row.count, columnWidths.count) {
            let value = row[index]
            let x = startX + columnWidths.prefix(index).reduce(0, +)
            let cellRect = CGRect(x: x, y: tableY, width: columnWidths[index], height: rowHeight)
            ctx.cgContext.stroke(cellRect)
            let alignment: NSTextAlignment = (index == 1) ? .left : .center
            drawText(value, in: cellRect, attributes: cellAttributes, alignment: alignment)
        }
        tableY += rowHeight
    }
    startY = tableY
}


#endif
