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
                var cell = tableView.dequeueReusableCell(withIdentifier: "StudentsClassificationCell", for: indexPath)
                guard let `self` = self else { return cell }

                switch dataSource[indexPath] {
                case let .picker(title, options, valueIndex):
                    self.configurePickerCell(&cell, title, options, valueIndex)
                    return cell

                case let .textField(title, subtitle, value):
                    // swiftlint:disable force_cast
                    var textFieldCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
                    self.configureTextFieldCell(&textFieldCell, title, subtitle, value)
                    return textFieldCell

                default:
                    return cell
                }
            },
            titleForHeaderInSection: { dataSource, index in
                dataSource.sectionModels[index].header
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
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: "TextFieldCell")
        setupBindings()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.bindOutput()
    }

    // MARK: bindings

    func bindViewModel() {
        let studentsClassification = viewModel.studentsClassification.share()

        studentsClassification
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        studentsClassification
            .map { $0[1].items.isEmpty }
            .asDriver(onErrorJustReturn: true)
            .drive(showNoContent)
            .disposed(by: bag)

        viewModel.options
            .map { options in options.map { $0.value } }
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

        setupPicker(doneAction: pickerDoneAction)
    }

    private func configurePickerCell(_ cell: inout UITableViewCell, _ title: String, _ options: [PickerOption], _ valueIndex: Int) {
        cell.textLabel?.textColor = UIColor.Theme.text

        cell.textLabel?.font = UIFont.Grades.boldBody
        cell.textLabel?.text = title

        let accessoryView = UIView()
        accessoryView.addSubview(pickerTextField)

        let pickerLabel = UIPickerLabel()
        if options.isEmpty == false {
            pickerLabel.text = options[valueIndex].value
        }
        accessoryView.addSubview(pickerLabel)
        pickerLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        cell.accessoryView = accessoryView
    }

    private func configureTextFieldCell(_ cell: inout TextFieldCell, _ title: String, _ subtitle: String, _: DynamicValue) {
        cell.titleLabel.text = title
        cell.subtitleLabel.text = subtitle
    }
}

extension GroupClassificationViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }
}
