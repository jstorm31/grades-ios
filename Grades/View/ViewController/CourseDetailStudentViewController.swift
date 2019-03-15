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
    var headerPointsLabel: UILabel!
    var headerGradeLabel: UILabel!

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
                dataSource.sectionModels[index].header
            }
        )
    }

    override func loadView() {
        super.loadView()

        navigationItem.title = viewModel.courseCode
        tableView.register(ClassificationCell.self, forCellReuseIdentifier: "ClassificationCell")
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)

        loadUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.bindOutput()

        headerPointsLabel.text = "54 b"
        headerGradeLabel.text = "A"
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            viewModel.onBack.execute()
        }
    }

    func bindViewModel() {
        viewModel.classifications
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        viewModel.isFetching.asDriver()
            .drive(tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: bag)

        viewModel.error.asObserver()
            .subscribe(onNext: { [weak self] error in
                self?.navigationController?.view
                    .makeCustomToast(error?.localizedDescription, type: .danger, position: .center)
            })
            .disposed(by: bag)
    }

    @objc private func refreshControlPulled(_: UIRefreshControl) {
        viewModel.bindOutput()
    }

    private func loadUI() {
        let container = UIView()
        tableView.tableHeaderView = container
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(45)
        }

        // Header label
        let header = UILabel()
        header.text = L10n.Classification.total
        header.font = UIFont.Grades.cellTitle
        header.textColor = UIColor.Theme.text
        container.addSubview(header)
        header.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        headerLabel = header

        // Grade label
        let grade = UILabel()
        grade.font = UIFont.Grades.display
        grade.textColor = UIColor.Theme.text
        grade.textAlignment = .right
        container.addSubview(grade)
        grade.snp.makeConstraints { make in
            make.width.equalTo(25)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        headerGradeLabel = grade

        // Points label
        let points = UILabel()
        points.font = UIFont.Grades.body
        points.textColor = UIColor.Theme.text
        points.textAlignment = .right
        container.addSubview(points)
        points.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(headerGradeLabel.snp.leading).offset(-13)
        }
        headerPointsLabel = points
    }
}

extension CourseDetailStudentViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }
}
