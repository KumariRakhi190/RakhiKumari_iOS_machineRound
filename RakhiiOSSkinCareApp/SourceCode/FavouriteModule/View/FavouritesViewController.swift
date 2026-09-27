//
//  FavouritesViewController.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 27/09/26.
//

import UIKit
import Combine

class FavouritesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private let viewModel = FavouritesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        bindData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: SubcategoryCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: SubcategoryCollectionViewCell.identifier)
    }

    func bindData() {
        viewModel.$favourites.receive(on: DispatchQueue.main).sink { [weak self] favourites in
            guard let self else { return }
            self.collectionView.reloadData()
            if favourites.isEmpty {
                self.collectionView.setEmptyMessage("No favourites yet.")
            } else {
                self.collectionView.restore()
            }
        }.store(in: &viewModel.cancellable)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension FavouritesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.favourites.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubcategoryCollectionViewCell.identifier, for: indexPath) as? SubcategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(subcategory: viewModel.favourite(at: indexPath.item))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedTip = viewModel.favourite(at: indexPath.item) else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            return
        }
        vc.subcategory = selectedTip
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2) - 10, height: 180)
    }
}
