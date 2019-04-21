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
        loadView(hasTableHeaderView: false)
        navigationItem.title = L10n.Students.title

        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search student"
        navigationItem.searchController = search
        definesPresentationContext = true

        loadUI()
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

        tableView.rx.itemSelected
            .map { $0.item }
            .bind(to: viewModel.itemSelected)
            .disposed(by: bag)
    }

    // MARK: UI setup

    private func loadUI() {}
}

extension StudentSearchViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }
}

extension StudentSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText.onNext(searchController.searchBar.text!)
    }
}
