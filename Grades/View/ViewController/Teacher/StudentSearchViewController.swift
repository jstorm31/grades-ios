//
//  StudentSearchViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 21/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
import UIKit

extension UISearchBar {
    var textField: UITextField? {
        return subviews.map { $0.subviews.first(where: { $0 is UITextInputTraits }) as? UITextField }
            .compactMap { $0 }
            .first
    }
}

final class StudentSearchViewController: BaseTableViewController, BindableType, TableDataSource {
    var viewModel: StudentSearchViewModel!
    let dataSource = configureDataSource()
    private let bag = DisposeBag()

    // MARK: Lifecycle

    override func loadView() {
        super.loadView()
        navigationItem.title = L10n.Students.title
        setupSearchBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            viewModel.onBackAction.execute()
        }
    }

    // MARK: binding

    func bindViewModel() {
        viewModel.dataSource.asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        // Bind input to view model

        tableView.rx.itemSelected
            .map { $0.item }
            .bind(to: viewModel.itemSelected)
            .disposed(by: bag)

        navigationItem.searchController!.searchBar.rx.text
            .debounce(0.25, scheduler: MainScheduler.instance)
            .unwrap()
            .bind(to: viewModel.searchText)
            .disposed(by: bag)
    }

    // MARK: UI setup

    private func setupSearchBar() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = L10n.Students.search
        search.searchBar.barStyle = .black
        search.searchBar.searchBarStyle = .default
        search.searchBar.tintColor = .white
        search.searchBar.barTintColor = UIColor.Theme.textFieldWhiteOpaciy
        search.searchBar.textField?.textColor = .white
        search.searchBar.textField?.backgroundColor = UIColor.Theme.textFieldWhiteOpaciy

        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
}

extension StudentSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for _: UISearchController) {}
}
