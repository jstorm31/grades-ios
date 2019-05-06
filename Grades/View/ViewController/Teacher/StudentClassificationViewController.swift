//
//  StudentClassificationViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class StudentClassificationViewController: BaseTableViewController, TableDataSource, BindableType {
    // MARK: Properties

    private var studentNameLabel: UILabel!
    private var changeStudentButton: UISecondaryButton!
    private var gradingOverview: UIGradingOverview!
    private var saveButton: UIBarButtonItem!

    var viewModel: StudentClassificationViewModel!
    private let bag = DisposeBag()

    let dataSource = configureDataSource()

    // MARK: lifecycle methods

    override func loadView() {
        super.loadView()
        loadUI()
    }

    override func viewDidLoad() {
        tableView.register(DynamicValueCell.self, forCellReuseIdentifier: "DynamicValueCell")
        viewModel.bindOutput()
        bindOutput()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent!.navigationItem.rightBarButtonItem = saveButton
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addKeyboardFrameChangesObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardFrameChangesObserver()
    }

    // MARK: binding

    func bindViewModel() {
        bindOverview()

        let dataSource = viewModel.dataSource.share()

        dataSource.asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: bag)

        let isLoading = viewModel.isloading.share(replay: 2, scope: .whileConnected)
        isLoading.skip(2).asDriver(onErrorJustReturn: false).drive(tableView.refreshControl!.rx.isRefreshing).disposed(by: bag)
        isLoading.take(3).asDriver(onErrorJustReturn: false).drive(view.rx.refreshing).disposed(by: bag)

        viewModel.error.asDriver(onErrorJustReturn: ApiError.general)
            .drive(view.rx.errorMessage)
            .disposed(by: bag)

        dataSource
            .map { $0.isEmpty ? true : !$0[0].items.isEmpty }
            .asDriver(onErrorJustReturn: true)
            .drive(noContentLabel.rx.isHidden)
            .disposed(by: bag)

        // Save action

        saveButton.rx.action!.elements
            .asDriver(onErrorJustReturn: ())
            .map { L10n.Students.updateSuccess }
            .do(onNext: { [weak self] _ in self?.view.endEditing(false) })
            .drive(view.rx.successMessage)
            .disposed(by: bag)

        saveButton.rx.action!.underlyingError
            .do(onNext: { [weak self] _ in self?.view.endEditing(false) })
            .asDriver(onErrorJustReturn: ApiError.general)
            .drive(view.rx.errorMessage)
            .disposed(by: bag)

        saveButton.rx.action!.executing
            .asDriver(onErrorJustReturn: false)
            .drive(view.rx.refreshing)
            .disposed(by: bag)
    }

    private func bindOverview() {
        viewModel.studentName
            .asDriver(onErrorJustReturn: "")
            .drive(studentNameLabel.rx.text)
            .disposed(by: bag)

        viewModel.totalPoints
            .map { $0 != nil ? "\(L10n.Classification.total) \($0!) \(L10n.Courses.points)" : "" }
            .asDriver(onErrorJustReturn: "")
            .drive(gradingOverview.pointsLabel.rx.text)
            .disposed(by: bag)

        viewModel.finalGrade
            .map { $0 ?? "" }
            .do(onNext: { [weak self] grade in
                self?.gradingOverview.gradeLabel.textColor = UIColor.Theme.setGradeColor(forGrade: grade)
            })
            .asDriver(onErrorJustReturn: "")
            .drive(gradingOverview.gradeLabel.rx.text)
            .disposed(by: bag)
    }

    private func bindOutput() {
        saveButton.rx.action = viewModel.saveAction
        changeStudentButton.rx.action = viewModel.changeStudentAction

        // Table cell seleciton

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            })
            .disposed(by: bag)

        // Save action

        saveButton.rx.action!.elements
            .asDriver(onErrorJustReturn: ())
            .map { L10n.Students.updateSuccess }
            .do(onNext: { [weak self] _ in self?.view.endEditing(false) })
            .drive(view.rx.successMessage)
            .disposed(by: bag)

        saveButton.rx.action!.underlyingError
            .do(onNext: { [weak self] _ in self?.view.endEditing(false) })
            .asDriver(onErrorJustReturn: ApiError.general)
            .drive(view.rx.errorMessage)
            .disposed(by: bag)

        saveButton.rx.action!.executing
            .asDriver(onErrorJustReturn: false)
            .drive(view.rx.refreshing)
            .disposed(by: bag)
    }

    // MARK: UI setup

    private func loadUI() {
        loadRefreshControl()
        tableView.refreshControl?.tintColor = UIColor.Theme.grayText
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
        self.saveButton = saveButton

        loadTableHeader()
    }

    private func loadTableHeader() {
        let headerView = UIView()
        tableView.tableHeaderView = headerView
        headerView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(90)
        }

        let containerView = UIView()
        headerView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalToSuperview()
        }

        let titleLabel = UILabel()
        titleLabel.font = UIFont.Grades.displaySmall
        titleLabel.textColor = UIColor.Theme.text
        titleLabel.text = L10n.Teacher.Students.title
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
        }
        tableView.tableHeaderView = headerView

        let studentName = UILabel()
        studentName.font = UIFont.Grades.body
        studentName.textColor = UIColor.Theme.text
        containerView.addSubview(studentName)
        studentName.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        studentNameLabel = studentName

        let button = UISecondaryButton()
        button.setTitle(L10n.Teacher.Students.changeButton, for: [])
        containerView.addSubview(button)
        button.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
        changeStudentButton = button

        let gradingView = UIGradingOverview()
        containerView.addSubview(gradingView)
        gradingView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(studentName.snp.centerY)
        }
        gradingOverview = gradingView
    }

    // MARK: events

    @objc private func refreshControlPulled(_: UIRefreshControl) {
        viewModel.bindOutput()
    }
}

extension StudentClassificationViewController: ModifableInsetsOnKeyboardFrameChanges {
    var scrollViewToModify: UIScrollView { return tableView }
}
