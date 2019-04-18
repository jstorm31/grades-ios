//
//  StudentClassificationViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class StudentClassificationViewController: BaseTableViewController, BindableType {
    private var studentNameLabel: UILabel!
    private var changeStudentButton: UISecondaryButton!

    var viewModel: StudentClassificationViewModel!
    private let bag = DisposeBag()

    // MARK: lifecycle methods

    override func loadView() {
        loadView(hasTableHeaderView: false)
        loadUI()
    }

    override func viewDidLoad() {
        viewModel.bindOutput()
    }

    // MARK: binding

    func bindViewModel() {
        viewModel.studentName.bind(to: studentNameLabel.rx.text).disposed(by: bag)

        let loading = viewModel.isloading.share(replay: 1, scope: .whileConnected)

        loading.asDriver(onErrorJustReturn: false)
            .drive(tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: bag)

        loading.asDriver(onErrorJustReturn: false)
            .debug()
            .drive(view.rx.refreshing)
            .disposed(by: bag)

        viewModel.error.asDriver(onErrorJustReturn: ApiError.general)
            .drive(view.rx.errorMessage)
            .disposed(by: bag)
    }

    // MARK: UI setup

    private func loadUI() {
        loadRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)
        loadTableHeader()
    }

    private func loadTableHeader() {
        let headerView = UIView()
        let containerView = UIView()
        headerView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
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
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        tableView.tableHeaderView = headerView
        headerView.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(90)
        }
    }

    // MARK: events

    @objc private func refreshControlPulled(_: UIRefreshControl) {
        viewModel.bindOutput()
    }
}
