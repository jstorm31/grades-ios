//
//  GroupClassificationViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 24/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import Foundation
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class GroupClassificationViewController: BaseTableViewController & BindableType & PickerPresentable {
    var pickerView: UIPickerView!
    var pickerTextField: UITextField!

    // MARK: properties

    var viewModel: GroupClassificationViewModel!
    private let bag = DisposeBag()

    private var pickerDoneAction: CocoaAction {
        return CocoaAction { [weak self] in
            self?.hidePicker()
            self?.viewModel.submitSelectedValue()
            return Observable.empty()
        }
    }

    private var dataSource: RxTableViewSectionedReloadDataSource<TableSection> {
        return RxTableViewSectionedReloadDataSource<TableSection>(
            configureCell: { [weak self] dataSource, tableView, indexPath, _ in
                let cell = tableView.dequeueReusableCell(withIdentifier: "StudentsClassificationCell", for: indexPath)
                cell.textLabel?.font = UIFont.Grades.boldBody
                cell.textLabel?.textColor = UIColor.Theme.text

                guard let `self` = self else { return cell }

                switch dataSource[indexPath] {
                case let .picker(title, options, valueIndex):
                    cell.textLabel?.text = title

                    self.setupPicker(title: title, doneAction: self.pickerDoneAction)

                    let accessoryView = UIView()
                    accessoryView.addSubview(self.pickerTextField)

                    let pickerLabel = UIPickerLabel()
                    if options.isEmpty == false {
                        pickerLabel.text = options[valueIndex]
                    }
                    accessoryView.addSubview(pickerLabel)
                    pickerLabel.snp.makeConstraints { make in
                        make.trailing.equalToSuperview()
                        make.centerY.equalToSuperview()
                    }

                    cell.accessoryView = accessoryView

                default:
                    return cell
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
        setupBindings()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.bindOutput()
    }

    // MARK: bindings

    func bindViewModel() {
        viewModel.studentsClassification
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        viewModel.options
            .asDriver(onErrorJustReturn: [])
            .drive(pickerView.rx.itemTitles) { _, element in element }
            .disposed(by: bag)

        viewModel.isloading.asDriver(onErrorJustReturn: false)
            .drive(view.rx.refreshing)
            .disposed(by: bag)

        viewModel.error.asDriver(onErrorJustReturn: ApiError.general)
            .drive(view.rx.errorMessage)
            .disposed(by: bag)
    }

    func setupBindings() {
        pickerView.rx.itemSelected
            .map { row, _ in row }
            .bind(to: viewModel.selectedOptionIndex)
            .disposed(by: bag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                let item = self.viewModel.studentsClassification.value[indexPath.section].items[indexPath.item]

                // On table cell selection, set selected cell index in view model to display right options in picker view
                if case let .picker(_, _, selectedValueIndex) = item {
                    self.viewModel.handleOptionChange(cellIndexPath: indexPath, optionIndex: selectedValueIndex)
                    self.showPicker()
                    self.pickerView.selectRow(selectedValueIndex, inComponent: 0, animated: true)
                }

                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: bag)
    }

    // MARK: UI setup

    func loadUI() {
        pickerView = UIPickerView()
        pickerTextField = UITextField()
        pickerTextField.inputView = pickerView
        pickerTextField.isHidden = true
    }
}

extension GroupClassificationViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }
}
