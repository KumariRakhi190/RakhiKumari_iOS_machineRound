//
//  CategoryTableViewCell.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 25/09/26.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    static let identifier = "CategoryTableViewCell"

    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!

    private let imageLoader = UIActivityIndicatorView(style: .medium)
    private var imageURLString = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        categoryImageView.setBorderAndCornerRadiusOfImage(borderWidth: 1, color: .white, cornerRadius: 18)
        mainContentView.setCornerRadius(18)
        setupImageLoader()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageURLString = ""
        categoryImageView.image = nil
    }

    private func setupImageLoader() {
        imageLoader.hidesWhenStopped = true
        imageLoader.translatesAutoresizingMaskIntoConstraints = false
        categoryImageView.addSubview(imageLoader)
        NSLayoutConstraint.activate([
            imageLoader.centerXAnchor.constraint(equalTo: categoryImageView.centerXAnchor),
            imageLoader.centerYAnchor.constraint(equalTo: categoryImageView.centerYAnchor)
        ])
    }

    func configure(category: CareCategory?) {
        categoryNameLabel.text = category?.displayName()
        let urlString = category?.image ?? ""
        imageURLString = urlString
        categoryImageView.image = nil
        imageLoader.startAnimating()
        ImageLoader.shared.loadImage(from: urlString) { [weak self] image in
            guard let self, self.imageURLString == urlString else { return }
            self.imageLoader.stopAnimating()
            self.categoryImageView.image = image ?? UIImage(systemName: "photo")
        }
    }
}
