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
import SwiftSVG
import UIKit

// TODO: add UI test
class CourseListViewController: UITableViewController, BindableType {
    var viewModel: CourseListViewModel!
    var bag = DisposeBag()

    let dataSource = RxTableViewSectionedReloadDataSource<CourseGroup>(
        configureCell: { _, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = item.code
            return cell
        }
    )

    override func loadView() {
        super.loadView()

        navigationItem.title = L10n.Courses.title

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl!.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.refreshControl!.beginRefreshing() // TODO: find out better solution for initial load
        viewModel.bindOutput()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        dataSource.titleForHeaderInSection = { dataSource, index in
            dataSource.sectionModels[index].header
        }
    }

    func bindViewModel() {
        let courses = viewModel.courses.monitorLoading().share()

        viewModel.coursesError.asObservable()
            .subscribe(onNext: { [weak self] error in
                DispatchQueue.main.async {
                    self?.navigationController?.view.makeCustomToast(error?.localizedDescription, type: .danger, position: .center)
                }
            })
            .disposed(by: bag)

        courses
            .data()
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        courses
            .loading()
            .bind(to: tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: bag)
    }

    @objc private func refreshControlPulled(_: UIRefreshControl) {
        viewModel.bindOutput()
    }
}
