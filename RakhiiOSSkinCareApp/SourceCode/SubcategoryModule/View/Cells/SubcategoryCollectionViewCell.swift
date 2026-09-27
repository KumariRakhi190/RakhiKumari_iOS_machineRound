//
//  SubcategoryCollectionViewCell.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 27/09/26.
//

import UIKit

class SubcategoryCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "SubcategoryCollectionViewCell"

    @IBOutlet weak var mainBackgroundView: UIView!
    @IBOutlet weak var subcategoryImageView: UIImageView!
    @IBOutlet weak var subcategoryTitleLabel: UILabel!
    
    private let imageLoader = UIActivityIndicatorView(style: .medium)
    private var imageURLString = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        subcategoryImageView.setCornerRadius(18)
        mainBackgroundView.setCornerRadius(18)
        setupImageLoader()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageURLString = ""
        subcategoryImageView.image = nil
    }

    private func setupImageLoader() {
        imageLoader.hidesWhenStopped = true
        imageLoader.translatesAutoresizingMaskIntoConstraints = false
        subcategoryImageView.addSubview(imageLoader)
        NSLayoutConstraint.activate([
            imageLoader.centerXAnchor.constraint(equalTo: subcategoryImageView.centerXAnchor),
            imageLoader.centerYAnchor.constraint(equalTo: subcategoryImageView.centerYAnchor)
        ])
    }

    func configure(subcategory: CareSubcategory?) {
        subcategoryTitleLabel.text = subcategory?.displayName()
        let urlString = subcategory?.image ?? ""
        imageURLString = urlString
        subcategoryImageView.image = nil
        imageLoader.startAnimating()
        ImageLoader.shared.loadImage(from: urlString) { [weak self] image in
            guard let self, self.imageURLString == urlString else { return }
            self.imageLoader.stopAnimating()
            self.subcategoryImageView.image = image ?? UIImage(systemName: "photo")
        }
    }

}
