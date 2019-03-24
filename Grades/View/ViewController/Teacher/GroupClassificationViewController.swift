//
//  GroupClassificationViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class GroupClassificationViewController: BaseTableViewController, BindableType {
    // MARK: properties

    var viewModel: GroupClassificationViewModelProtocol!
    private let bag = DisposeBag()

    private var dataSource: RxTableViewSectionedReloadDataSource<StudentsClassificationSection> {
        return RxTableViewSectionedReloadDataSource<StudentsClassificationSection>(
            configureCell: { [weak self] dataSource, tableView, indexPath, _ in
                let cell = tableView.dequeueReusableCell(withIdentifier: "StudentsClassificationCell", for: indexPath)
                cell.textLabel?.font = UIFont.Grades.boldBody
                cell.textLabel?.textColor = UIColor.Theme.text

                switch dataSource[indexPath] {
                case let .picker(title, value):
                    cell.textLabel?.text = title
                }

                return cell
            }
        )
    }

    // MARK: lifecycle

    override func loadView() {
        loadView(hasTableHeaderView: false)
        view.backgroundColor = .yellow
        loadUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StudentsClassificationCell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.bindOutput()
    }

    // MARK: methods

    func bindViewModel() {
        viewModel.studentsClassification
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        viewModel.groupOptions.asObservable()
            .subscribe(onNext: {
                Log.info("Groups: \($0)")
            })
            .disposed(by: bag)

        viewModel.classificationOptions.asObservable()
            .subscribe(onNext: {
                Log.info("Classification: \($0)")
            })
            .disposed(by: bag)

        viewModel.isloading.asDriver(onErrorJustReturn: false)
            .drive(view.rx.refreshing)
            .disposed(by: bag)

        viewModel.error.asDriver(onErrorJustReturn: ApiError.general)
            .drive(view.rx.errorMessage)
            .disposed(by: bag)
    }

    // MARK: UI setup

    func loadUI() {}
}

extension GroupClassificationViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }
}
