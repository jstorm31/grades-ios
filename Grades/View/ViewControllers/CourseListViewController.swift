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
import UIKit

class CourseListViewController: UITableViewController, BindableType {
    var viewModel: CourseListViewModel!
    var bag = DisposeBag()

    let dataSource = RxTableViewSectionedReloadDataSource<CourseGroup>(
        configureCell: { _, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = item.courseCode
            return cell
        }
    )

    override func loadView() {
        super.loadView()

        navigationItem.title = L10n.SubjectList.title
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.titleForHeaderInSection = { dataSource, index in
            dataSource.sectionModels[index].header
        }
    }

    func bindViewModel() {
        viewModel.courses.bind(to: tableView.rx.items(dataSource: dataSource))
    }
}
