//
//  CourseListViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 05/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import RxSwiftExt
import UIKit

// TODO: add UI test
class CourseListViewController: UITableViewController, BindableType {
    var viewModel: CourseListViewModel!
    var bag = DisposeBag()

    let dataSource = RxTableViewSectionedReloadDataSource<CourseGroup>(
        configureCell: { _, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = item.courseCode
            return cell
        }
    )

    override func loadView() {
        super.loadView()

        navigationItem.title = L10n.Courses.title
		
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.refreshControl?.beginRefreshing()
        viewModel.bindOutput()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        dataSource.titleForHeaderInSection = { dataSource, index in
            dataSource.sectionModels[index].header
        }
    }

    func bindViewModel() {
        let courses = viewModel.courses.monitorLoading().share()

        courses
            .data()
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        courses
            .loading()
            .subscribe(onNext: { [weak self] isLoading in
				// TODO: create Rx extension for refreshControl
                if isLoading {
                    self?.tableView.refreshControl?.beginRefreshing()
                } else {
                    self?.tableView.refreshControl?.endRefreshing()
                }
            })
            .disposed(by: bag)
    }

    @objc private func refreshControlPulled(_: UIRefreshControl) {
        viewModel.bindOutput()
    }
}
