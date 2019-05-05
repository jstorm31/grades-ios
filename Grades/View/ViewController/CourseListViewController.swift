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

class CourseListViewController: BaseTableViewController, TableDataSource, BindableType {
    var viewModel: CourseListViewModel!
    private let bag = DisposeBag()

    internal var dataSource = configureDataSource()

    // MARK: Lifecycle

    override func loadView() {
        super.loadView()
        loadRefreshControl()

        navigationItem.title = L10n.Courses.title
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(StudentCourseCell.self, forCellReuseIdentifier: "StudentCourseCell")
        tableView.register(TeacherCourseCell.self, forCellReuseIdentifier: "TeacherCourseCell")

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

    // MARK: Bidning

    func bindViewModel() {
        let coursesObservable = viewModel.courses.share()

        coursesObservable
            .map { coursesByRoles in
                [
                    TableSection(
                        header: L10n.Courses.studying,
                        items: coursesByRoles.student.map { StudentCourseCellConfigurator(item: $0) }
                    ),
                    TableSection(
                        header: L10n.Courses.teaching,
                        items: coursesByRoles.teacher.map { TeacherCourseCellConfigurator(item: $0) }
                    )
                ]
            }
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        coursesObservable
            .map { !($0.student.isEmpty && $0.teacher.isEmpty) }
            .bind(to: noContentLabel.rx.isHidden)
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
