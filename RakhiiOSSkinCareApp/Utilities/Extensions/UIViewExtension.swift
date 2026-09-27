//  StringExtension.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 24/09/26.

import Foundation
import UIKit

extension UIView {
    
    // - Parameter radius: The radius to set for the corners.
    func setCornerRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    // Sets the border width and color of the view.
    func setBorder(width: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    func setBorderColourAndConerRadiusOfView(borderWidth: CGFloat, color: UIColor, cornerRadius: CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
    
    
}



