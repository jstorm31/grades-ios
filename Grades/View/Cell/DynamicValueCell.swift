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

    private var valueTextField: UITextField!
    private var valueSwitch: UISwitch!
    private var incrementButton: UIButton!
    private var decrementButton: UIButton!

    var viewModel: DynamicValueCellViewModel!
    private(set) var bag = DisposeBag()

    var incrementValue: CocoaAction!
    var decrementValue: CocoaAction!

    // MARK: initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        incrementValue = CocoaAction { [weak self] _ in
            self?.changeValue(increment: true)
            return Observable.empty()
        }

        decrementValue = CocoaAction { [weak self] _ in
            self?.changeValue(increment: false)
            return Observable.empty()
        }

        loadUI()
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
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .map { [weak self] text in
                guard let type = self?.viewModel.valueType else { return DynamicValue.string(nil) }

                switch type {
                case .number:
                    return DynamicValue.number(Double(text.replacingOccurrences(of: ",", with: ".")) ?? nil)
                default:
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
        displayControl()
        disableControl()

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
        var isNumber: Bool!
        if case .number = viewModel.valueType {
            isNumber = true
        } else {
            isNumber = false
        }
        valueTextField.keyboardType = isNumber ? .numberPad : .default
        valueTextField.attributedPlaceholder = NSAttributedString(
            string: isNumber ? "0" : "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.Theme.grayText]
        )
    }

    private func changeValue(increment: Bool) {
        let value = valueTextField.text

        if value != nil, let newValue = Double(value!) {
            valueTextField.text = "\(increment ? newValue + 1 : newValue - 1)"
        }

        if value == nil || value == "" {
            valueTextField.text = "\(increment ? 1 : -1)"
        }

        valueTextField.sendActions(for: .valueChanged)
    }

    /// Show right controls for type
    private func displayControl() {
        switch viewModel.valueType {
        case .string:
            valueTextField.isHidden = false
            valueSwitch.isHidden = true
            incrementButton.isHidden = true
            decrementButton.isHidden = true
        case .number:
            valueTextField.isHidden = false
            valueSwitch.isHidden = true
            incrementButton.isHidden = false
            decrementButton.isHidden = false
        case .bool:
            valueSwitch.isHidden = false
            valueTextField.isHidden = true
            incrementButton.isHidden = true
            decrementButton.isHidden = true
        }
    }

    /// Disable non-manual values
    private func disableControl() {
        let disabledPrimary = UIColor.Theme.primary.withAlphaComponent(0.8)

        switch viewModel.evaluationType {
        case .manual:
            valueTextField.isUserInteractionEnabled = true
            valueSwitch.isUserInteractionEnabled = true
            incrementButton.isUserInteractionEnabled = true
            decrementButton.isUserInteractionEnabled = true
            valueTextField.textColor = UIColor.Theme.text
            valueSwitch.onTintColor = UIColor.Theme.primary
            valueSwitch.tintColor = UIColor.Theme.primary
        default:
            valueTextField.isUserInteractionEnabled = false
            valueSwitch.isUserInteractionEnabled = false
            incrementButton.isUserInteractionEnabled = false
            decrementButton.isUserInteractionEnabled = false
            valueTextField.textColor = UIColor.Theme.grayText
            valueSwitch.onTintColor = disabledPrimary
            valueSwitch.tintColor = disabledPrimary
        }
    }

    // MARK: UI setup

    // swiftlint:disable function_body_length
    private func loadUI() {
        selectionStyle = .none

        // Increment button
        var incrementButton = UIButton()
        incrementButton.titleLabel?.font = UIFont.Grades.boldLarge
        incrementButton.setTitleColor(UIColor.Theme.primary, for: .normal)
        incrementButton.setTitle("+", for: .normal)
        incrementButton.titleEdgeInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        incrementButton.rx.action = incrementValue
        contentView.addSubview(incrementButton)
        incrementButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
        self.incrementButton = incrementButton

        // Textfield
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
            make.trailing.equalTo(incrementButton.snp.leading).offset(-4)
        }
        valueTextField = textField

        // Decrement button
        var decrementButton = UIButton()
        decrementButton.titleLabel?.font = UIFont.Grades.boldLarge
        decrementButton.setTitleColor(UIColor.Theme.primary, for: .normal)
        decrementButton.setTitle("−", for: .normal)
        decrementButton.titleEdgeInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        decrementButton.rx.action = decrementValue
        contentView.addSubview(decrementButton)
        decrementButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(textField.snp.leading).offset(-4)
        }
        self.decrementButton = decrementButton

        // Switch
        let valueSwitch = UIPrimarySwitch()
        valueSwitch.isHidden = true
        contentView.addSubview(valueSwitch)
        valueSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
        self.valueSwitch = valueSwitch
    }
}
