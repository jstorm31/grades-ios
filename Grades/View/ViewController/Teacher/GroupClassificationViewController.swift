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
    private var sortOrderButton: UIButton!
    private var sortButtonsStack: UIStackView!

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
        super.loadView()
        loadUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(PickerCell.self, forCellReuseIdentifier: "PickerCell")
        tableView.register(DynamicValueCell.self, forCellReuseIdentifier: "DynamicValueCell")
        tableView.accessibilityIdentifier = "GroupTable"

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
        bindDataSource()
        bindSorters()

        viewModel.options
            .map { options in options.map { $0 } }
            .asDriver(onErrorJustReturn: [])
            .drive(pickerView.rx.itemTitles) { _, element in element }
            .disposed(by: bag)

        // Loading and error

        let isLoading = viewModel.isloading.share(replay: 2, scope: .whileConnected)
        isLoading.skip(2).asDriver(onErrorJustReturn: false).drive(tableView.refreshControl!.rx.isRefreshing).disposed(by: bag)
        isLoading.take(2).asDriver(onErrorJustReturn: false).drive(view.rx.refreshing).disposed(by: bag)

        viewModel.error.asDriver(onErrorJustReturn: ApiError.general)
            .drive(view.rx.errorMessage)
            .disposed(by: bag)

        viewModel.selectedCellOptionIndex.asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] index in
                self?.pickerView.selectRow(index, inComponent: 0, animated: true)
            })
            .disposed(by: bag)
    }

    func bindDataSource() {
        let dataSource = viewModel.dataSource
            .map { classifications in
                TableSection(header: L10n.Teacher.Group.students, items: classifications.map { DynamicValueCellConfigurator(item: $0) })
            }
            .map { [weak self] itemsSection -> [TableSection] in
                guard let self = self else { return [] }

                return [
                    TableSection(header: "", items: [
                        PickerCellConfigurator(item: self.viewModel.groupsCellViewModel),
                        PickerCellConfigurator(item: self.viewModel.classificationsCellViewModel)
                    ]),
                    itemsSection
                ]
            }
            .share()

        // Datasource

        dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: bag)

        dataSource
            .map { $0.count > 1 ? !$0[1].items.isEmpty : false }
            .asDriver(onErrorJustReturn: true)
            .drive(noContentLabel.rx.isHidden)
            .disposed(by: bag)
    }

    func bindSorters() {
        viewModel.sorters
            .do(onNext: { [weak self] _ in
                guard let self = self, let stack = self.sortButtonsStack?.subviews else { return }

                // Clean filter buttons from StackView (position 1 and more, because there is also a label)
                for view in stack {
                    self.sortButtonsStack.removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
            })
            .map { $0.map { $0.title } }
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] sorters in
                // Add a button for each sorter
                for (index, title) in sorters.enumerated() {
                    let sorterButton = UIButton()
                    sorterButton.setTitleColor(UIColor.Theme.secondary, for: .normal)
                    sorterButton.titleLabel?.font = UIFont.Grades.body
                    sorterButton.setTitle(title, for: .normal)
                    sorterButton.tag = index
                    sorterButton.addTarget(self, action: #selector(self?.sorterButtonTapped(sender:)), for: .touchUpInside)
                    self?.sortButtonsStack.addArrangedSubview(sorterButton)
                }
            })
            .disposed(by: bag)

        // Make the active sorter button bold
        viewModel.activeSorterIndex
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: { [weak self] activeIndex in
                guard let self = self, self.sortButtonsStack.subviews.indices.contains(activeIndex) else { return }

                for (index, view) in self.sortButtonsStack.subviews.enumerated() {
                    if let activeButton = view as? UIButton {
                        activeButton.titleLabel?.font = activeIndex == index ? UIFont.Grades.boldBody : UIFont.Grades.body
                    }
                }
            })
            .disposed(by: bag)

        // Sort order icon
        viewModel.isAscending
            .skip(1)
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] isAscending in
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    self?.sortOrderButton.transform = isAscending ? .identity : CGAffineTransform(rotationAngle: .pi)
                })
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
        tableView.refreshControl?.tintColor = UIColor.Theme.grayText
        tableView.refreshControl?.addTarget(self, action: #selector(refreshControlPulled(_:)), for: .valueChanged)

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: nil, action: nil)
        self.saveButton = saveButton

        loadSorters()
    }

    func loadSorters() {
        let filtersStack = UIStackView()
        filtersStack.axis = .horizontal
        filtersStack.distribution = .fill
        filtersStack.alignment = .center
        filtersStack.spacing = 10
        view.addSubview(filtersStack)
        filtersStack.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }

        // Sort title
        let filtersTitle = UILabel()
        filtersTitle.font = UIFont.Grades.body
        filtersTitle.textColor = UIColor.Theme.text
        filtersTitle.text = L10n.Sorter.title
        filtersStack.addArrangedSubview(filtersTitle)

        // Sort buttons stack
        let sortButtonsStack = UIStackView()
        sortButtonsStack.axis = .horizontal
        sortButtonsStack.spacing = 20
        filtersStack.addArrangedSubview(sortButtonsStack)
        self.sortButtonsStack = sortButtonsStack

        // Fill rest of space -> results in aligning items to left
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        filtersStack.addArrangedSubview(spacer)

        // Asc/desc button
        let orderButton = UIButton()
        orderButton.setImage(UIImage(named: "SortOrder"), for: .normal)
        orderButton.addTarget(self, action: #selector(sortOrderButtonTapped(sender:)), for: .touchUpInside)
        filtersStack.addArrangedSubview(orderButton)
        sortOrderButton = orderButton

        // Remake constraints of table view
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(filtersStack.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
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

    @objc private func sorterButtonTapped(sender: UIButton) {
        viewModel.activeSorterIndex.onNext(sender.tag)
    }

    @objc private func sortOrderButtonTapped(sender _: UIButton) {
        do {
            viewModel.isAscending.onNext(try !viewModel.isAscending.value())
        } catch {
            Log.error("Problem setting asscending")
        }
    }
}

extension GroupClassificationViewController: ModifableInsetsOnKeyboardFrameChanges {
    var scrollViewToModify: UIScrollView { return tableView }
}
