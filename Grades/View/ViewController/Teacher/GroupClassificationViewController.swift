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

final class GroupClassificationViewController: BaseTableViewController, TableDataSource, BindableType, PickerPresentable {
    var pickerView: UIPickerView!
    var pickerTextField: UITextField!

    // MARK: properties

    var viewModel: GroupClassificationViewModel!
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
        loadView(hasTableHeaderView: false)
        loadUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(PickerCell.self, forCellReuseIdentifier: "PickerCell")
//        tableView.register(DynamicValueCell.self, forCellReuseIdentifier: "TextFieldCell")
        setupBindings()
        viewModel.bindOutput()
        viewModel.getData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
        saveButton.rx.action = viewModel.saveAction
        parent!.navigationItem.rightBarButtonItem = saveButton
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.getData()
    }

    // MARK: bindings

    func bindViewModel() {
        let dataSource = viewModel.dataSource.share()

        dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: bag)

        dataSource
            .map { $0.isEmpty ? false : !$0[1].items.isEmpty }
            .asDriver(onErrorJustReturn: true)
            .drive(noContentLabel.rx.isHidden)
            .disposed(by: bag)

        viewModel.options
            .map { options in options.map { $0 } }
            .asDriver(onErrorJustReturn: [])
            .drive(pickerView.rx.itemTitles) { _, element in element }
            .disposed(by: bag)

        let loading = viewModel.isloading.share()

        loading.asDriver(onErrorJustReturn: false)
            .drive(tableView.refreshControl!.rx.isRefreshing)
            .disposed(by: bag)

        loading.asDriver(onErrorJustReturn: false)
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
                guard indexPath.section == 0 else { return }

                self?.viewModel.handleOptionChange(cellIndexPath: indexPath)
                self?.showPicker()
                //				self?.pickerView.selectRow(selectedValueIndex, inComponent: 0, animated: true)
//                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: bag)
    }

    // MARK: UI setup

    func loadUI() {
        pickerView = UIPickerView()
        pickerTextField = UITextField()
        pickerTextField.inputView = pickerView
        pickerTextField.isHidden = true
        view.addSubview(pickerTextField)

        setupPicker(doneAction: pickerDoneAction)

        loadRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)
    }

    private func configurePickerCell(_ cell: inout UITableViewCell, _ title: String, _ options: [String], _ valueIndex: Int) {
        cell.textLabel?.textColor = UIColor.Theme.text

        cell.textLabel?.font = UIFont.Grades.boldBody
        cell.textLabel?.text = title

        let accessoryView = UIView()

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
    }

    // MARK: events

    @objc private func refreshControlPulled(_: UIRefreshControl) {
        viewModel.getData()
    }
}

extension GroupClassificationViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }
}
