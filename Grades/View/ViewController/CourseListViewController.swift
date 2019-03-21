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
import SnapKit
import UIKit

class CourseListViewController: BaseTableViewController, BindableType {
    var viewModel: CourseListViewModel!
    private let bag = DisposeBag()

    private let dataSource = CourseListViewController.dataSource()

    override func loadView() {
        super.loadView()
        loadView(hasTableHeaderView: false)
        loadRefreshControl()

        navigationItem.title = L10n.Courses.title
        tableView.register(CourseListCell.self, forCellReuseIdentifier: "CourseCell")
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rx.itemSelected.asDriver()
            .drive(onNext: { [weak self] indexPath in
                self?.viewModel.onItemSelection(section: indexPath.section, item: indexPath.item)
            })
            .disposed(by: bag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let icon = UIImage(named: "icon_settings")
        var settingsButton = UIButton()
        settingsButton.setImage(icon, for: .normal)
        settingsButton.rx.action = viewModel.openSettings
        navigationController?.navigationBar.addSubview(settingsButton)
        settingsButton.tag = 1
        settingsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(13)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.bindOutput()
    }

    func bindViewModel() {
        viewModel.courses
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        viewModel.isFetchingCourses.asDriver()
            .drive(tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: bag)

        viewModel.coursesError.asObservable()
            .subscribe(onNext: { [weak self] error in
                DispatchQueue.main.async {
                    self?.navigationController?.view.makeCustomToast(error?.localizedDescription,
                                                                     type: .danger,
                                                                     position: .center)
                }
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseListCell
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
