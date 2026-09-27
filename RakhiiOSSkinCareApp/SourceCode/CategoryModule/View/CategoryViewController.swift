//
//  CategoryViewController.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 25/09/26.
//

import UIKit
import Combine


class CategoryViewController: UIViewController {

    @IBOutlet weak var searchMainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var stateMessageLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    
    var applicationId = ""
    var screenTitle = ""
    private lazy var viewModel = CategoryViewModel(applicationId: applicationId, screenTitle: screenTitle)

    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = screenTitle
        setupTableView()
        setupSearchTextField()
        bindData()
        getCategories()
        searchMainView.setCornerRadius(28)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            Loader.hide()
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 160
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UINib(nibName: CategoryTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: CategoryTableViewCell.identifier)
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        setStateViewHidden(true)
    }

    private func setupSearchTextField() {
        searchTextField.delegate = self
        searchTextField.returnKeyType = .search
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.autocorrectionType = .no
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
    }

    // Filters the list on every character typed.
    @objc private func searchTextChanged() {
        viewModel.search(text: searchTextField.text ?? "")
    }

    //MARK: API Calling
    func getCategories() {
        viewModel.getCategories()
    }

    @objc private func pullToRefresh() {
        getCategories()
    }

    func bindData() {
        viewModel.$state.receive(on: DispatchQueue.main).sink { [weak self] state in
            self?.render(state)
        }.store(in: &viewModel.cancellable)

        viewModel.$categories.receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.reloadTableView()
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
            setStateViewHidden(true)
            if !refreshControl.isRefreshing {
                Loader.show()
            }
        case .loaded:
            Loader.hide()
            refreshControl.endRefreshing()
            setStateViewHidden(true)
        case .empty(let message), .error(let message):
            Loader.hide()
            refreshControl.endRefreshing()
            stateMessageLabel.text = message
            setStateViewHidden(false)
        }
    }

    private func reloadTableView() {
        tableView.reloadData()
        // Search typed but nothing matches.
        if viewModel.categories.isEmpty && !viewModel.searchText.isEmpty {
            tableView.setEmptyMessage("No results found.")
        } else {
            tableView.restore()
        }
    }

    private func setStateViewHidden(_ isHidden: Bool) {
        stateView.isHidden = isHidden
        retryButton.isHidden = isHidden
    }

    @IBAction func retryButtonTapped(_ sender: UIButton) {
        getCategories()
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.identifier, for: indexPath) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        let category = viewModel.category(at: indexPath.row)
        cell.configure(category: category)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedCategory = viewModel.category(at: indexPath.row) else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "SubcategoryViewController") as? SubcategoryViewController else {
            return
        }
        vc.applicationId = viewModel.applicationId
        vc.categoryId = selectedCategory.id ?? ""
        vc.screenTitle = selectedCategory.displayName()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: - UITextFieldDelegate

extension CategoryViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // The clear (x) button does not send editingChanged, so reset the search here.
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.search(text: "")
        return true
    }
}
