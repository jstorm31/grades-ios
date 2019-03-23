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
        tableView.register(StudentCourseCell.self, forCellReuseIdentifier: "StudentCourseCell")
        tableView.register(TeacherCourseCell.self, forCellReuseIdentifier: "TeacherCourseCell")
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rx.itemSelected.asDriver()
            .drive(onNext: { [weak self] indexPath in
                self?.viewModel.onItemSelection(indexPath)
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
            .map { coursesByRoles in
                [
                    CourseGroup(
                        header: L10n.Courses.studying,
                        items: coursesByRoles.student.map { StudentCourseCellConfigurator(item: $0) }
                    ),
                    CourseGroup(
                        header: L10n.Courses.teaching,
                        items: coursesByRoles.teacher.map { TeacherCourseCellConfigurator(item: $0) }
                    )
                ]
            }
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        let fetchingObservable = viewModel.isFetchingCourses.share()

        fetchingObservable.asDriver(onErrorJustReturn: false)
            .drive(tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: bag)

        fetchingObservable.asDriver(onErrorJustReturn: false)
            .drive(view.rx.refreshing)
            .disposed(by: bag)

        viewModel.coursesError.asDriver(onErrorJustReturn: nil)
            .drive(view.rx.errorMessage)
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
                let cell = tableView.dequeueReusableCell(withIdentifier: type(of: item).reuseId, for: indexPath)
                item.configure(cell: cell)
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
