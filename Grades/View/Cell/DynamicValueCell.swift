//
//  TextFieldCell.swift
//  Grades
//
//  Created by Jiří Zdvomka on 14/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import RxCocoa
import RxSwift
import SnapKit
import UIKit

typealias DynamicValueCellConfigurator = TableCellConfigurator<DynamicValueCell, DynamicValueCellViewModel>

final class DynamicValueCell: BasicCell, ConfigurableCell {
    typealias DataType = DynamicValueCellViewModel

    private var fieldLabel: UILabel!
    private var valueTextField: UITextField!
    private var valueSwitch: UISwitch!

    var viewModel: DynamicValueCellViewModel!
    private(set) var bag = DisposeBag()

    // MARK: initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }

    // MARK: Configuration

    func configure(data cellViewModel: DynamicValueCell.DataType) {
        viewModel = cellViewModel
        bindViewModel()
        viewModel.bindOutput()
        bindOutput()
    }

    // MARK: Binding

    private func bindOutput() {
        valueTextField.rx.text
            .skip(1)
            .unwrap()
            .debounce(0.25, scheduler: MainScheduler.instance)
            .map { text in
                if let number = Double(text) {
                    return DynamicValue.number(number)
                } else {
                    return DynamicValue.string(text)
                }
            }
            .bind(to: viewModel.value)
            .disposed(by: bag)

        valueSwitch.rx.isOn
            .skip(1)
            .map { DynamicValue.bool($0) }
            .bind(to: viewModel.value)
            .disposed(by: bag)
    }

    private func bindViewModel() {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle

        // Bind values to controls

        viewModel.stringValue
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(valueTextField.rx.text)
            .disposed(by: bag)

        viewModel.boolValue
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(valueSwitch.rx.isOn)
            .disposed(by: bag)

        // Keyboard type
        viewModel.value.unwrap()
            .map { type -> Bool in
                if case .number = type {
                    return true
                }
                return false
            }
            .subscribe(onNext: { [weak self] isNumber in
                self?.valueTextField.keyboardType = isNumber ? .numberPad : .default
                self?.valueTextField.attributedPlaceholder = NSAttributedString(
                    string: isNumber ? "0" : "",
                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.Theme.grayText]
                )
            })
            .disposed(by: bag)

        // Show right controls for type
        switch viewModel.valueType {
        case .string:
            valueTextField.isHidden = false
        case .number:
            valueTextField.isHidden = false
            fieldLabel.isHidden = false
        case .bool:
            valueSwitch.isHidden = false
        }
    }

    // MARK: UI setup

    private func loadUI() {
        let fieldLabel = UILabel()
        fieldLabel.font = UIFont.Grades.body
        fieldLabel.textColor = UIColor.Theme.text
        fieldLabel.text = L10n.Courses.points
        fieldLabel.isHidden = true
        contentView.addSubview(fieldLabel)
        fieldLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
        self.fieldLabel = fieldLabel

        let textField = UITextField()
        textField.font = UIFont.Grades.body
        textField.textColor = UIColor.Theme.text
        textField.setBottomBorder(color: UIColor.Theme.borderGray, size: 1.0)
        textField.isHidden = true
        textField.addDoneButton(doneAction: CocoaAction {
            self.contentView.endEditing(false)
            return Observable.empty()
        })
        contentView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(fieldLabel.snp.leading).inset(-8)
        }
        valueTextField = textField

        let valueSwitch = UISwitch()
        valueSwitch.onTintColor = UIColor.Theme.primary
        valueSwitch.tintColor = UIColor.Theme.primary
        valueSwitch.isHidden = true
        contentView.addSubview(valueSwitch)
        valueSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
        self.valueSwitch = valueSwitch
    }
}
