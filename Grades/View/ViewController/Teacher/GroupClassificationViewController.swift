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

final class GroupClassificationViewController: BaseTableViewController, BindableType, TableDataSource, PickerPresentable {
    var pickerView: UIPickerView!
    var pickerTextField: UITextField!
    private var saveButton: UIBarButtonItem!

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
        tableView.register(DynamicValueCell.self, forCellReuseIdentifier: "DynamicValueCell")

        viewModel.bindOutput()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent!.navigationItem.rightBarButtonItem = saveButton
        addKeyboardFrameChangesObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeKeyboardFrameChangesObserver()
    }

    // MARK: bindings

    func bindViewModel() {
        let dataSource = viewModel.dataSource.share()

        dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: bag)

        dataSource
            .map { $0.count > 1 ? !$0[1].items.isEmpty : false }
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

        viewModel.selectedCellOptionIndex.asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] index in
                self?.pickerView.selectRow(index, inComponent: 0, animated: true)
            })
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
//                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: bag)

        // Save action
        saveButton.rx.action = viewModel.saveAction

        saveButton.rx.action!.elements
            .asDriver(onErrorJustReturn: ())
            .map { L10n.Students.updateSuccess }
            .do(onNext: { [weak self] _ in self?.view.endEditing(false) })
            .drive(view.rx.successMessage)
            .disposed(by: bag)

        saveButton.rx.action!.underlyingError
            .do(onNext: { [weak self] _ in self?.view.endEditing(false) })
            .asDriver(onErrorJustReturn: ApiError.general)
            .drive(view.rx.errorMessage)
            .disposed(by: bag)

        saveButton.rx.action!.executing
            .asDriver(onErrorJustReturn: false)
            .drive(view.rx.refreshing)
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

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
        self.saveButton = saveButton
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
        viewModel.refreshData.onNext(())
    }
}

extension GroupClassificationViewController: UITableViewDelegate {
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 60
    }
}

extension GroupClassificationViewController: ModifableInsetsOnKeyboardFrameChanges {
    var scrollViewToModify: UIScrollView { return tableView }
}
