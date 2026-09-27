//  UIImageViewExtension.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 24/09/26.


import Foundation
import UIKit

extension UIImageView {
    
    // Sets the corner radius of the image view.
    func setCornerRadiusOfImage(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    // Sets the border width and color of the image view.
    func setBorderOfImage(width: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    // Combines setting both the border and corner radius for the image view.
    func setBorderAndCornerRadiusOfImage(borderWidth: CGFloat, color: UIColor, cornerRadius: CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
    
    // Shows the placeholder, then loads the remote image (cached by ImageLoader).
    func loadImage(from urlString: String, placeholder: UIImage? = UIImage(systemName: "photo")) {
        image = placeholder
        ImageLoader.shared.loadImage(from: urlString) { [weak self] loadedImage in
            self?.image = loadedImage ?? placeholder
        }
    }
}
