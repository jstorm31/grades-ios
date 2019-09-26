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

final class SettingsViewController: BaseTableViewController,
    BindableType,
    TableDataSource,
    ConfirmationModalPresentable,
    PickerPresentable {
    var pickerView: UIPickerView!
    var pickerTextField: UITextField!

    var viewModel: SettingsViewModel!
    private let bag = DisposeBag()

    let dataSource = configureDataSource()

    private var pickerDoneAction: CocoaAction {
        return CocoaAction { [weak self] in
            self?.hidePicker()
            self?.viewModel.submitSelectedValue()
            return Observable.empty()
        }
    }

    // MARK: lifecycle

    override func loadView() {
        super.loadView()

        tableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.register(PickerCell.self, forCellReuseIdentifier: "PickerCell")
        tableView.register(LinkCell.self, forCellReuseIdentifier: "LinkCell")
        tableView.register(SwitchCell.self, forCellReuseIdentifier: "SwitchCell")

        navigationItem.title = L10n.Settings.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.Settings.logout,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(logOutButtonTapped(_:)))

        loadUI()
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

        let selected = tableView.rx.itemSelected
            .do(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .share()

        selected.filter { $0.section == 1 }
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.handleOptionChange(cellIndexPath: indexPath)
                self?.showPicker()
            })
            .disposed(by: bag)

        selected.filter { $0.section == 2 }
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.onLinkSelectedAction.execute(indexPath.item)
            })
            .disposed(by: bag)
    }

    func bindViewModel() {
        bindSettings()

        viewModel.options
            .map { options in options.map { $0 } }
            .asDriver(onErrorJustReturn: [])
            .drive(pickerView.rx.itemTitles) { _, element in element }
            .disposed(by: bag)

        viewModel.selectedCellOptionIndex.asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] index in
                self?.pickerView.selectRow(index, inComponent: 0, animated: true)
            })
            .disposed(by: bag)
    }

    func bindSettings() {
        viewModel.settings
            .unwrap()
            .map { settings in
                [
                    TableSection(header: L10n.Settings.user, items: [
                        SettingsCellConfigurator(item: (title: L10n.Settings.User.name, content: settings.name)),
                        SettingsCellConfigurator(item: (title: L10n.Settings.User.roles, content: settings.roles))
                    ]),
                    TableSection(header: L10n.Settings.options, items: [
                        PickerCellConfigurator(item: settings.options),
                        SwitchCellConfigurator(item: (title: L10n.Settings.Teacher.sendNotifications,
                                                      isEnabled: settings.sendingNotificationsEnabled))
                    ]),
                    TableSection(header: L10n.Settings.other, items: [
                        LinkCellConfigurator(item: L10n.Settings.about),
                        LinkCellConfigurator(item: L10n.Settings.license)
                    ])
                ]
            }
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }

    // MARK: UI setup

    private func loadUI() {
        pickerView = UIPickerView()
        pickerTextField = UITextField()
        pickerTextField.inputView = pickerView
        pickerTextField.isHidden = true
        view.addSubview(pickerTextField)

        setupPicker(doneAction: pickerDoneAction)
    }

    // MARK: events

    @objc func logOutButtonTapped(_: UIBarButtonItem) {
        displayConfirmation(title: L10n.Settings.logoutConfirmTitle) { [weak self] in
            self?.viewModel.logoutAction.execute()
        }
    }
}
