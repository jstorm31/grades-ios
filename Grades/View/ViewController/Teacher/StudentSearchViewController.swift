//
//  StudentSearchViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 21/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
import UIKit

final class StudentSearchViewController: BaseTableViewController, BindableType, TableDataSource {
    var viewModel: StudentSearchViewModel!
    let dataSource = configureDataSource()
    private let bag = DisposeBag()

    // MARK: Lifecycle

    override func loadView() {
        super.loadView()
        navigationItem.title = L10n.Students.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
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
            .do(onNext: { [weak self] _ in
                self?.navigationItem.searchController?.searchBar.endEditing(true)
            })
            .bind(to: viewModel.itemSelected)
            .disposed(by: bag)

        navigationItem.searchController!.searchBar.rx.text
            .debounce(.milliseconds(250), scheduler: MainScheduler.instance)
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

        if #available(iOS 13.0, *) {
            search.searchBar.searchTextField.backgroundColor = .white
            search.searchBar.searchTextField.textColor = UIColor.Theme.text
        }

        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
}

extension StudentSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for _: UISearchController) {}
}
