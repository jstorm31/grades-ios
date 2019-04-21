//
//  SettingsViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 18/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class SettingsViewController: BaseTableViewController & BindableType & ConfirmationModalPresentable & PickerPresentable {
    var pickerView: UIPickerView!
    var pickerTextField: UITextField!

    var viewModel: SettingsViewModel!
    private let bag = DisposeBag()

    private var pickerDoneAction: CocoaAction {
        return CocoaAction { [weak self] in
            self?.hidePicker()
            self?.viewModel.submitSelectedValue()
            return Observable.empty()
        }
    }

    // MARK: data source

    private var dataSource: RxTableViewSectionedReloadDataSource<TableSectionPolymorphic> {
        return RxTableViewSectionedReloadDataSource<TableSectionPolymorphic>(
            configureCell: { [weak self] dataSource, tableView, indexPath, _ in

                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
                cell.textLabel?.font = UIFont.Grades.boldBody
                cell.textLabel?.textColor = UIColor.Theme.text

                guard let `self` = self else { return cell }

                switch dataSource[indexPath] {
                    // MARK: text cell

                case let .text(title, text):
                    cell.textLabel?.text = title

                    let label = UILabel()
                    label.font = UIFont.Grades.body
                    label.textColor = UIColor.Theme.text
                    label.text = text

                    cell.accessoryView = label
                    return cell

                    // MARK: picker cell

                case let .picker(title, options, valueIndex):
                    cell.textLabel?.text = title

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
                    return cell

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
        super.loadView()
        loadView(hasTableHeaderView: false)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        navigationItem.title = L10n.Settings.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.Settings.logout,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(logOutButtonTapped(_:)))

        pickerView = UIPickerView()
        pickerTextField = UITextField()
        pickerTextField.inputView = pickerView
        pickerTextField.isHidden = true

        setupPicker(doneAction: pickerDoneAction)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeRightButton()
        viewModel.bindOutput()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            viewModel.onBackAction.execute()
        }
    }

    // MARK: binding

    func setupBindings() {
        pickerView.rx.itemSelected
            .map { row, _ in row }
            .bind(to: viewModel.selectedOptionIndex)
            .disposed(by: bag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                let item = self.viewModel.settings.value[indexPath.section].items[indexPath.item]

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

    func bindViewModel() {
        viewModel.settings
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        viewModel.options
            .map { options in options.map { $0 } }
            .asDriver(onErrorJustReturn: [])
            .drive(pickerView.rx.itemTitles) { _, element in element }
            .disposed(by: bag)
    }

    // MARK: events

    @objc func logOutButtonTapped(_: UIBarButtonItem) {
        displayConfirmation(title: L10n.Settings.logoutConfirmTitle) { [weak self] in
            self?.viewModel.logoutAction.execute()
        }
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }
}
