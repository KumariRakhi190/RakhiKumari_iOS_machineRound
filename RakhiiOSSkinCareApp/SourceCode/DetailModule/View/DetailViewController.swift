//
//  DetailViewController.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 25/09/26.
//

import UIKit
import Combine

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tipImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mainBackgroundView: UIView!

    var subcategory: CareSubcategory?
    private var viewModel: DetailViewModel?

    private let favouriteButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)
    private var cancellable = Set<AnyCancellable>()
    private let imageLoader = UIActivityIndicatorView(style: .medium)
    private var imageURLString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let subcategory else { return }
        let viewModel = DetailViewModel(subcategory: subcategory)
        self.viewModel = viewModel
        setupImageLoader()
        configure(with: viewModel)
        tipImageView.setCornerRadius(18)
        mainBackgroundView.setCornerRadius(18)
        setupHeaderButtons()
        bindData()
    }

    private func configure(with viewModel: DetailViewModel) {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.descriptionText
        let urlString = viewModel.imageURLString
        imageURLString = urlString
        tipImageView.image = nil
        imageLoader.startAnimating()
        ImageLoader.shared.loadImage(from: urlString) { [weak self] image in
            guard let self, self.imageURLString == urlString else { return }
            self.imageLoader.stopAnimating()
            self.tipImageView.image = image ?? UIImage(systemName: "photo")
        }
    }

    // Small spinner in the middle of the image, visible until the image is loaded.
    private func setupImageLoader() {
        imageLoader.hidesWhenStopped = true
        imageLoader.translatesAutoresizingMaskIntoConstraints = false
        tipImageView.addSubview(imageLoader)
        NSLayoutConstraint.activate([
            imageLoader.centerXAnchor.constraint(equalTo: tipImageView.centerXAnchor),
            imageLoader.centerYAnchor.constraint(equalTo: tipImageView.centerYAnchor)
        ])
    }

    // Favourite and Share buttons on the right side of the title.
    private func setupHeaderButtons() {
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22)
        favouriteButton.setPreferredSymbolConfiguration(symbolConfiguration, forImageIn: .normal)
        shareButton.setPreferredSymbolConfiguration(symbolConfiguration, forImageIn: .normal)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        favouriteButton.tintColor = .systemPink
        shareButton.tintColor = .label
        favouriteButton.addTarget(self, action: #selector(favouriteButtonTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [favouriteButton, shareButton])
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        // Long titles shrink with "..." instead of pushing the buttons off screen.
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: stackView.leadingAnchor, constant: -10)
        ])
    }

    func bindData() {
        viewModel?.$isFavourite.receive(on: DispatchQueue.main).sink { [weak self] isFavourite in
            self?.favouriteButton.setImage(UIImage(systemName: isFavourite ? "heart.fill" : "heart"), for: .normal)
        }.store(in: &cancellable)
    }

    @objc private func favouriteButtonTapped() {
        guard let viewModel else { return }
        viewModel.toggleFavourite()
        Toast.show(message: viewModel.isFavourite ? "Added to favourites" : "Removed from favourites")
    }

    @objc private func shareButtonTapped() {
        guard let viewModel else { return }
        let activityViewController = UIActivityViewController(activityItems: [viewModel.shareText], applicationActivities: nil)
        // Needed on iPad, where the share sheet is shown as a popover.
        activityViewController.popoverPresentationController?.sourceView = shareButton
        present(activityViewController, animated: true)
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
