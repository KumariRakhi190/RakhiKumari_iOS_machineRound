//
//  HomeViewController.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 24/09/26.
//


import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: CareTypeCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: CareTypeCollectionViewCell.identifier)
        collectionView.layer.cornerRadius = 16
    }

    //MARK: Language
    @IBAction func languageButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select Language", message: nil, preferredStyle: .actionSheet)
        let selectedLanguage = LanguageManager.shared.selectedLanguage
        for language in AppLanguage.allCases {
            let title = language == selectedLanguage ? "\(language.apiName) ✓" : language.apiName
            alert.addAction(UIAlertAction(title: title, style: .default) { _ in
                LanguageManager.shared.setLanguage(language)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.popoverPresentationController?.sourceView = sender
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView( _ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.careTypes.count
    }
    
    func collectionView( _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CareTypeCollectionViewCell.identifier, for: indexPath) as! CareTypeCollectionViewCell
        let careType = viewModel.careTypes[indexPath.item]
        cell.configure(careType: careType)
        return cell
    }
    
    func collectionView( _ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCare = viewModel.careTypes[indexPath.item]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController( withIdentifier: "CategoryViewController") as! CategoryViewController
        vc.applicationId = selectedCare.applicationId
        vc.screenTitle = "\(selectedCare.name) Care"
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((self.collectionView.frame.width) / 3) - 10, height: 120)
    }
    
}

