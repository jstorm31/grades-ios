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

class SettingsViewController: BaseTableViewController, BindableType {
    var pickerView: UIPickerView!
    var pickerTextField: UITextField!

    var viewModel: SettingsViewModel!
    private let bag = DisposeBag()

    private var dataSource: RxTableViewSectionedReloadDataSource<SettingsSection> {
        return RxTableViewSectionedReloadDataSource<SettingsSection>(
            configureCell: { [weak self] dataSource, tableView, indexPath, _ in
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
                cell.textLabel?.font = UIFont.Grades.boldBody
                cell.textLabel?.textColor = UIColor.Theme.text

                guard let `self` = self else { return cell }

                switch dataSource[indexPath] {
                case let .text(title, text):
                    cell.textLabel?.text = title

                    let label = UILabel()
                    label.font = UIFont.Grades.body
                    label.textColor = UIColor.Theme.text
                    label.text = text

                    cell.accessoryView = label
                    return cell

                case let .picker(title, options, text):
                    cell.textLabel?.text = title

                    let accessoryView = UIView()
                    self.pickerTextField.backgroundColor = .red
                    self.pickerTextField.inputView = self.pickerView

                    let doneAction = CocoaAction { [weak self] in
                        guard let `self` = self else { return Observable.empty() }

                        self.pickerTextField.resignFirstResponder()
                        self.viewModel.submitCurrentValue()
                        return Observable.empty()
                    }

                    self.pickerTextField.addDoneButtonOnKeyboard(title: title, doneAction: doneAction)
                    self.pickerTextField.isHidden = true
                    accessoryView.addSubview(self.pickerTextField)

                    let valueLabel = UILabel()
                    valueLabel.text = text
                    valueLabel.textColor = UIColor.Theme.text
                    accessoryView.addSubview(valueLabel)
                    valueLabel.snp.makeConstraints { make in
                        make.trailing.equalToSuperview()
                        make.centerY.equalToSuperview()
                    }

                    cell.accessoryView = accessoryView

                    return cell
                }
            },
            titleForHeaderInSection: { dataSource, index in
                dataSource.sectionModels[index].header
            }
        )
    }

    override func loadView() {
        super.loadView()
        loadView(hasTableHeaderView: false)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        navigationItem.title = L10n.Settings.title

        pickerView = UIPickerView()
        pickerTextField = UITextField()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.rx.itemSelected
            .map { row, _ in row }
            .bind(to: viewModel.selectedOptionIndex)
            .disposed(by: bag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                let item = self.viewModel.settings.value[indexPath.section].items[indexPath.item]

                if case .picker = item {
                    self.viewModel.selectedIndex.accept(indexPath)
                    self.pickerTextField.becomeFirstResponder()
                }

                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: bag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeRightButton()
        viewModel.bindOutput()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            viewModel.onBack.execute()
        }
    }

    func bindViewModel() {
        viewModel.settings
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        viewModel.options
            .asDriver(onErrorJustReturn: [])
            .drive(pickerView.rx.itemTitles) { _, element in element }
            .disposed(by: bag)
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }
}
