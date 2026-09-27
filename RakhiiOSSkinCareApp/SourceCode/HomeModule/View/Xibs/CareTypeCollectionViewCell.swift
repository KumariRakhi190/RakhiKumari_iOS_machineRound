//
//  CareTypeCollectionViewCell.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 24/09/26.
//

import UIKit

class CareTypeCollectionViewCell: UICollectionViewCell {

    static let identifier = "CareTypeCollectionViewCell"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
    }

    func configure(careType: CareType) {
        titleLabel.text = careType.name
        iconImageView.image = UIImage(named: careType.imageName)
        titleLabel.backgroundColor = UIColor(hex: careType.backgroundColorHex)
        titleLabel.textColor = .black
    }
}
