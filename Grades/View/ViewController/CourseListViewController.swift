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

final class CourseListViewController: BaseTableViewController, TableDataSource, BindableType {
    var viewModel: CourseListViewModel!
    private let isEditingSubject = BehaviorSubject<Bool>(value: false)
    private let bag = DisposeBag()

    internal var dataSource = configureDataSource()

    // MARK: Lifecycle

    override func loadView() {
        super.loadView()

        navigationItem.title = L10n.Courses.title
        navigationItem.rightBarButtonItem = editButtonItem

        loadRefreshControl()
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(StudentCourseCell.self, forCellReuseIdentifier: "StudentCourseCell")
        tableView.register(TeacherCourseCell.self, forCellReuseIdentifier: "TeacherCourseCell")

        dataSource.canEditRowAtIndexPath = { _, _ in
            true
        }

        tableView.rx.itemSelected.asDriver()
            .drive(onNext: { [weak self] indexPath in
                if let editing = self?.tableView.isEditing, !editing {
                    self?.viewModel.onItemSelection(indexPath)
                } else {
                    self?.viewModel.showCourse(for: indexPath)
                }
            })
            .disposed(by: bag)

        tableView.rx.itemDeselected.asDriver()
            .drive(onNext: { [weak self] indexPath in
                if let editing = self?.tableView.isEditing, editing {
                    self?.viewModel.hideCourse(for: indexPath)
                }
            })
            .disposed(by: bag)

        viewModel.bindOutput()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let icon = UIImage(named: "Settings")
        var settingsButton = UIButton()
        settingsButton.accessibilityIdentifier = "Settings button"
        settingsButton.setImage(icon, for: .normal)
        settingsButton.rx.action = viewModel.openSettings
        navigationController?.navigationBar.addSubview(settingsButton)
        settingsButton.tag = 1
        settingsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(13)
        }
    }

    // MARK: Bidning

    func bindViewModel() {
        let filteredCourses = viewModel.filteredCourses.share(replay: 1, scope: .whileConnected)
        let isEditingShared = isEditingSubject.share()

        isEditingShared
            .flatMap { [weak self] isEditing -> Observable<CoursesByRoles> in
                guard let self = self else { return Observable.empty() }

                return Observable.combineLatest(self.viewModel.courses, filteredCourses) { courses, filteredCourses in
                    isEditing ? courses : filteredCourses
                }
            }
            .map { coursesByRoles in
                var courses = [TableSection]()

                if !coursesByRoles.student.isEmpty {
                    courses.append(TableSection(
                        header: L10n.Courses.studying,
                        items: coursesByRoles.student.map { StudentCourseCellConfigurator(item: $0) }
                    ))
                }

                if !coursesByRoles.teacher.isEmpty {
                    courses.append(TableSection(
                        header: L10n.Courses.teaching,
                        items: coursesByRoles.teacher.map { TeacherCourseCellConfigurator(item: $0) }
                    ))
                }

                return courses
            }
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        // Select unhidden cells
        isEditingShared
            .filter { $0 == true }
            .flatMap { [weak self] _ in
                self?.viewModel.hiddenCourses
                    .map { [weak self] hidden in
                        hidden.map { [weak self] course in
                            self?.viewModel.courses.value.indexPath(for: course)
                        }
                    }
                    .asObservable() ?? Observable.just([])
            }
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] hiddenCourses in
                guard let self = self else { return }

                for cell in self.tableView.visibleCells {
                    let indexPath = self.tableView.indexPath(for: cell)!

                    if !hiddenCourses.contains(indexPath) {
                        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    }
                }
            })
            .disposed(by: bag)

        filteredCourses
            .map { !($0.student.isEmpty && $0.teacher.isEmpty) }
            .bind(to: noContentLabel.rx.isHidden)
            .disposed(by: bag)

        let fetchingObservable = viewModel.isFetchingCourses.share(replay: 2, scope: .whileConnected)

        fetchingObservable
            .skip(2)
            .asDriver(onErrorJustReturn: false)
            .drive(tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: bag)

        fetchingObservable
            .take(2)
            .asDriver(onErrorJustReturn: false)
            .drive(view.rx.refreshing)
            .disposed(by: bag)

        viewModel.coursesError.asDriver(onErrorJustReturn: nil)
            .drive(view.rx.errorMessage)
            .disposed(by: bag)
    }

    // MARK: methods

    override func setEditing(_: Bool, animated _: Bool) {
        // Takes care of toggling the button's title.
        super.setEditing(!isEditing, animated: true)

        // Toggle table view editing.
        tableView.setEditing(!tableView.isEditing, animated: true)
        isEditingSubject.onNext(tableView.isEditing)
    }

    // MARK: actions

    @objc private func refreshControlPulled(_: UIRefreshControl) {
        viewModel.refresh.onNext(())
    }
}
