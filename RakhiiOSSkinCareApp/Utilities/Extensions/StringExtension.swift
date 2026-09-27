//
//  StringExtension.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 25/09/26.
//

import Foundation

extension String {

    /// Converts the HTML sent by the API into readable plain text:
    /// block tags become line breaks, list items become bullets, the remaining
    /// tags are removed, entities are decoded and extra blank lines are collapsed.
    /// Plain text keeps the label's own font, so Dynamic Type and Dark Mode keep working.
    var htmlToPlainText: String {
        var text = self
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")

        let replacements: [(pattern: String, template: String)] = [
            ("<\\s*br\\s*/?\\s*>", "\n"),
            ("<\\s*li[^>]*>", "\n• "),
            ("<\\s*/\\s*(ul|ol)\\s*>", "\n\n"),
            ("<\\s*/\\s*(p|div|pre|h[1-6])\\s*>", "\n"),
            ("<\\s*(p|div|ul|ol|pre|h[1-6])(\\s[^>]*)?>", "\n"),
            ("<[^>]+>", "")
        ]
        for replacement in replacements {
            text = text.replacingOccurrences(of: replacement.pattern, with: replacement.template, options: [.regularExpression, .caseInsensitive])
        }

        text = text.decodingHTMLEntities

        let lines = text
            .components(separatedBy: "\n")
            .map { $0.replacingOccurrences(of: "[ \\t\\u{00A0}]+", with: " ", options: .regularExpression).trimmingCharacters(in: .whitespaces) }

        // Collapse runs of empty lines into a single blank line.
        var result: [String] = []
        for line in lines {
            if line.isEmpty && (result.last?.isEmpty ?? true) {
                continue
            }
            result.append(line)
        }
        return result.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var decodingHTMLEntities: String {
        let namedEntities: [String: String] = [
            "&nbsp;": " ", "&amp;": "&", "&lt;": "<", "&gt;": ">",
            "&quot;": "\"", "&apos;": "'", "&#39;": "'"
        ]
        var text = self
        for (entity, value) in namedEntities {
            text = text.replacingOccurrences(of: entity, with: value, options: .caseInsensitive)
        }

        // Numeric entities such as &#8217; or &#x2019;
        guard let regex = try? NSRegularExpression(pattern: "&#(x?)([0-9a-fA-F]+);") else { return text }
        let nsText = text as NSString
        var decoded = ""
        var lastLocation = 0
        for match in regex.matches(in: text, range: NSRange(location: 0, length: nsText.length)) {
            decoded += nsText.substring(with: NSRange(location: lastLocation, length: match.range.location - lastLocation))
            let isHex = !nsText.substring(with: match.range(at: 1)).isEmpty
            let number = nsText.substring(with: match.range(at: 2))
            if let code = UInt32(number, radix: isHex ? 16 : 10), let scalar = Unicode.Scalar(code) {
                decoded += String(Character(scalar))
            } else {
                decoded += nsText.substring(with: match.range)
            }
            lastLocation = match.range.location + match.range.length
        }
        decoded += nsText.substring(from: lastLocation)
        return decoded
    }
}
