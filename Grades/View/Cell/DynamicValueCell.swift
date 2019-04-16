//
//  TextFieldCell.swift
//  Grades
//
//  Created by Jiří Zdvomka on 14/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class DynamicValueCell: UITableViewCell {
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    private var valueTextField: UITextField!
    private var valueSwitch: UISwitch!

    let input = BehaviorSubject<DynamicValue>(value: .string(""))
    let output = BehaviorSubject<DynamicValue>(value: .string(""))
    private let bag = DisposeBag()

    // MARK: initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadUI()
        bindInput()
        bindOutput()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bindOutput() {
        valueTextField.rx.text
            .unwrap()
            .map { text in
                if let number = Double(text) {
                    return DynamicValue.number(number)
                } else {
                    return DynamicValue.string(text)
                }
            }
            .bind(to: output)
            .disposed(by: bag)

        valueSwitch.rx.isOn
            .map { DynamicValue.bool($0) }
            .bind(to: output)
            .disposed(by: bag)
    }

    func bindInput() {
        let sharedValue = input.share()

        let stringValue = sharedValue
            .map { (value: DynamicValue) -> String? in
                switch value {
                case let .string(value):
                    return value
                case let .number(value):
                    return value != nil ? String(value!) : nil
                default:
                    return nil
                }
            }
            .share()

        stringValue
            .map { $0 == nil }
            .asDriver(onErrorJustReturn: false)
            .drive(valueTextField.rx.isHidden)
            .disposed(by: bag)

        stringValue
            .unwrap()
            .asDriver(onErrorJustReturn: "")
            .drive(valueTextField.rx.text)
            .disposed(by: bag)

        let boolValue = sharedValue
            .map { (value: DynamicValue) -> Bool? in
                if case let .bool(boolValue) = value {
                    return boolValue
                }
                return nil
            }
            .share()

        boolValue
            .map { $0 == nil }
            .asDriver(onErrorJustReturn: true)
            .drive(valueSwitch.rx.isHidden)
            .disposed(by: bag)

        boolValue
            .unwrap()
            .asDriver(onErrorJustReturn: false)
            .drive(valueSwitch.rx.isOn)
            .disposed(by: bag)
    }

    // MARK: UI setup

    func loadUI() {
        let title = UILabel()
        title.font = UIFont.Grades.body
        title.textColor = UIColor.Theme.text
        contentView.addSubview(title)
        title.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
        }
        titleLabel = title

        let subtitle = UILabel()
        subtitle.font = UIFont.Grades.smallText
        subtitle.textColor = UIColor.Theme.grayText
        contentView.addSubview(subtitle)
        subtitle.snp.makeConstraints { make in
            make.bottom.equalTo(title.snp.bottom)
            make.leading.equalTo(title.snp.trailing).offset(8)
        }
        subtitleLabel = subtitle

        let fieldLabel = UILabel()
        fieldLabel.font = UIFont.Grades.body
        fieldLabel.textColor = UIColor.Theme.text
        fieldLabel.text = L10n.Courses.points
        contentView.addSubview(fieldLabel)
        fieldLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }

        let textField = UITextField()
        textField.font = UIFont.Grades.body
        textField.textColor = UIColor.Theme.text
        textField.setBottomBorder(color: UIColor.Theme.borderGray, size: 1.0)
        textField.attributedPlaceholder = NSAttributedString(
            string: "0",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.Theme.grayText]
        )
        contentView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(fieldLabel.snp.leading).inset(-8)
        }
        valueTextField = textField

        let valueSwitch = UISwitch()
        valueSwitch.tintColor = UIColor.Theme.primary
        contentView.addSubview(valueSwitch)
        valueSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
        valueSwitch.isHidden = true
        self.valueSwitch = valueSwitch
    }
}
