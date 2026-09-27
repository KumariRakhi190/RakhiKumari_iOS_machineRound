//
//  SubcategoryViewController.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 25/09/26.
//

import UIKit
import Combine

class SubcategoryViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var stateMessageLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!

    var applicationId = ""
    var categoryId = ""
    var screenTitle = ""
    private lazy var viewModel = SubcategoryViewModel(applicationId: applicationId, categoryId: categoryId, screenTitle: screenTitle)
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = screenTitle
        setupCollectionView()
        bindData()
        getSubcategories()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            Loader.hide()
        }
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        stateView.isHidden = true
        retryButton.isHidden = true
        collectionView.register(UINib(nibName: "SubcategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SubcategoryCollectionViewCell")
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.alwaysBounceVertical = true
    }

    //MARK: API Calling
    func getSubcategories() {
        viewModel.getSubcategories()
    }

    @objc private func pullToRefresh() {
        getSubcategories()
    }

    func bindData() {
        viewModel.$state.receive(on: DispatchQueue.main).sink { [weak self] state in
            self?.render(state)
        }.store(in: &viewModel.cancellable)

        viewModel.$infoMessage.sink { message in
            if let message {
                Toast.show(message: message)
            }
        }.store(in: &viewModel.cancellable)
    }

    private func render(_ state: ViewState) {
        switch state {
        case .idle:
            break
        case .loading:
            stateView.isHidden = true
            retryButton.isHidden = true
            if !refreshControl.isRefreshing {
                Loader.show()
            }
        case .loaded:
            Loader.hide()
            refreshControl.endRefreshing()
            stateView.isHidden = true
            retryButton.isHidden = true
            collectionView.reloadData()
        case .empty(let message), .error(let message):
            Loader.hide()
            refreshControl.endRefreshing()
            collectionView.reloadData()
            stateMessageLabel.text = message
            stateView.isHidden = false
            retryButton.isHidden = false
        }
    }

    @IBAction func retryButtonTapped(_ sender: UIButton) {
        getSubcategories()
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension SubcategoryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.subcategories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubcategoryCollectionViewCell", for: indexPath) as? SubcategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let subcategory = viewModel.subcategory(at: indexPath.item)
        cell.configure(subcategory: subcategory)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedSubcategory = viewModel.subcategory(at: indexPath.item) else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            return
        }
        vc.subcategory = selectedSubcategory
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((self.collectionView.frame.width) / 2) - 10, height: 180)
    }
}
