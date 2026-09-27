//
//  UIColorExtension.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 24/09/26.
//

import UIKit

extension UIColor {

    convenience init(hex: String) {
        let hexString = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var hexNumber: UInt64 = 0

        Scanner(string: hexString).scanHexInt64(&hexNumber)

        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat

        switch hexString.count {
        case 6:
            red = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
            green = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
            blue = CGFloat(hexNumber & 0x0000FF) / 255

        case 8:
            red = CGFloat((hexNumber & 0xFF000000) >> 24) / 255
            green = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255
            blue = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255

        default:
            red = 0
            green = 0
            blue = 0
        }

        self.init(
            red: red,
            green: green,
            blue: blue,
            alpha: 1.0
        )
    }
}
