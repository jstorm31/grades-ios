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
class CourseListViewController: BaseViewController, BindableType {
    private var tableView: UITableView!

    var viewModel: CourseListViewModel!
    private let bag = DisposeBag()

    private let dataSource = CourseListViewController.dataSource()

    override func loadView() {
        super.loadView()

        navigationItem.title = L10n.Courses.title

        let tableView = UITableView()
        tableView.register(CourseListCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.tableView = tableView

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    override func viewWillAppear(_: Bool) {
        if let index = self.tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.view.makeToastActivity(.center)
        viewModel.bindOutput()
    }

    func bindViewModel() {
        let courses = viewModel.courses.monitorLoading().share()

        viewModel.coursesError.asObservable()
            .subscribe(onNext: { [weak self] error in
                DispatchQueue.main.async {
                    self?.navigationController?.view.makeCustomToast(error?.localizedDescription,
                                                                     type: .danger,
                                                                     position: .center)
                }
            })
            .disposed(by: bag)

        courses.data()
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        // Initial activity
        courses.loading()
            .take(1)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isLoading in
                if !isLoading {
                    self?.navigationController?.view.hideToastActivity()
                }
            })
            .disposed(by: bag)

        courses.loading()
            .asDriver(onErrorJustReturn: false)
            .drive(tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: bag)

        tableView.rx.itemSelected.asDriver()
            .drive(onNext: { [weak self] indexPath in
                self?.viewModel.onItemSelection(section: indexPath.section, item: indexPath.item)
            })
            .disposed(by: bag)
    }

    @objc private func refreshControlPulled(_: UIRefreshControl) {
        viewModel.bindOutput()
    }
}

extension CourseListViewController {
    static func dataSource() -> RxTableViewSectionedReloadDataSource<CourseGroup> {
        return RxTableViewSectionedReloadDataSource<CourseGroup>(
            configureCell: { _, tableView, indexPath, item in
                // swiftlint:disable force_cast
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CourseListCell
                cell.course = item
                return cell
            },
            titleForHeaderInSection: { dataSource, index in
                dataSource.sectionModels[index].header
            }
        )
    }
}

extension CourseListViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 90
    }
}
