//
//  CourseDetailStudentViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 11/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class CourseDetailStudentViewController: BaseTableViewController, BindableType {
    var headerLabel: UILabel!
    var headerGradingOverview: UIGradingOverview!

    var viewModel: CourseDetailStudentViewModel!
    private let bag = DisposeBag()

    private var dataSource: RxTableViewSectionedReloadDataSource<GroupedClassification> {
        return RxTableViewSectionedReloadDataSource<GroupedClassification>(
            configureCell: { _, tableView, indexPath, item in
                // swiftlint:disable force_cast
                let cell = tableView.dequeueReusableCell(withIdentifier: "ClassificationCell", for: indexPath) as! ClassificationCell
                cell.classification = item
                return cell
            },
            titleForHeaderInSection: { dataSource, index in
                let group = dataSource.sectionModels[index]
                var title = group.header ?? L10n.Classification.other

                if let value = group.totalValue {
                    title += " \(value.toString())"
                }
                return title
            }
        )
    }

    // MARK: Lifecycle

    override func loadView() {
        super.loadView()
        loadRefreshControl()

        navigationItem.title = viewModel.courseCode
        tableView.register(ClassificationCell.self, forCellReuseIdentifier: "ClassificationCell")
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)
        navigationController?.navigationBar.addSubview(UIView())

        loadUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeRightButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.bindOutput()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            viewModel.onBack.execute()
        }
    }

    // MARK: Binding

    func bindViewModel() {
        let classificationsObservable = viewModel.classifications.share()

        classificationsObservable
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        classificationsObservable
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: true)
            .drive(noContentLabel.rx.isHidden)
            .disposed(by: bag)

        classificationsObservable
            .map { $0.isEmpty }
            .asDriver(onErrorJustReturn: false)
            .drive(headerLabel.rx.isHidden)
            .disposed(by: bag)

        let sharedFetching = viewModel.isFetching.share()

        sharedFetching
            .asDriver(onErrorJustReturn: false)
            .drive(tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: bag)

        sharedFetching
            .asDriver(onErrorJustReturn: false)
            .drive(view.rx.refreshing)
            .disposed(by: bag)

        viewModel.error.asObserver()
            .subscribe(onNext: { [weak self] error in
                self?.navigationController?.view
                    .makeCustomToast(error?.localizedDescription, type: .danger, position: .center)
            })
            .disposed(by: bag)

        viewModel.totalPoints
            .unwrap()
            .map { "\($0) \(L10n.Courses.points)" }
            .asDriver(onErrorJustReturn: "")
            .drive(headerGradingOverview.pointsLabel.rx.text)
            .disposed(by: bag)

        viewModel.finalGrade
            .unwrap()
            .do(onNext: { [weak self] grade in
                self?.headerGradingOverview.gradeLabel.textColor = UIColor.Theme.setGradeColor(forGrade: grade)
            })
            .asDriver(onErrorJustReturn: "")
            .drive(headerGradingOverview.gradeLabel.rx.text)
            .disposed(by: bag)
    }

    @objc private func refreshControlPulled(_: UIRefreshControl) {
        viewModel.bindOutput()
    }

    private func loadUI() {
        let tableHeader = UIView()
        tableView.tableHeaderView = tableHeader
        tableHeader.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }

        let headerContainer = UIView()
        tableView.tableHeaderView!.addSubview(headerContainer)
        headerContainer.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // Header label
        let header = UILabel()
        header.text = L10n.Classification.total
        header.font = UIFont.Grades.cellTitle
        header.textColor = UIColor.Theme.text
        header.isHidden = true
        headerContainer.addSubview(header)
        header.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        headerLabel = header

        let gradingOverview = UIGradingOverview()
        headerContainer.addSubview(gradingOverview)
        gradingOverview.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        headerGradingOverview = gradingOverview

        headerContainer.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(42)
        }
    }

    override func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection _: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }

        headerView.backgroundColor = UIColor.Theme.lightGrayBackground
        headerView.textLabel?.font = UIFont.Grades.boldBody
        headerView.textLabel?.textColor = UIColor.Theme.text
    }
}
