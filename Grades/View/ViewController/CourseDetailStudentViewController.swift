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

class CourseDetailStudentViewController: UITableViewController, BindableType {
    var viewModel: CourseDetailStudentViewModel!
    private let bag = DisposeBag()

    private var dataSource: RxTableViewSectionedReloadDataSource<GroupedClassification> {
        return RxTableViewSectionedReloadDataSource<GroupedClassification>(
            configureCell: { [weak self] _, _, indexPath, item in
                // swiftlint:disable force_cast
                let cell = self?.tableView.dequeueReusableCell(withIdentifier: "ClassificationCell", for: indexPath) as! ClassificationCell
                cell.classification = item
                return cell
            }
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = viewModel.courseCode
        tableView.register(ClassificationCell.self, forCellReuseIdentifier: "ClassificationCell")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            viewModel.onBack.execute()
        }
    }

    func bindViewModel() {
        viewModel.classifications
            .map { [GroupedClassification(header: "Klasifikace", items: $0)] }
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        viewModel.error.asObserver()
            .subscribe(onNext: { [weak self] error in
                self?.navigationController?.view
                    .makeCustomToast(error?.localizedDescription, type: .danger, position: .center)
            })
            .disposed(by: bag)
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 40
    }
}
