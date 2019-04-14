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

class TextFieldCell: UITableViewCell {
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var valueTextField: UITextField!

    // MARK: properties

    //	let title = BehaviorRelay<String>(value: "")
    //	let subtitle = BehaviorRelay<String>(value: "")
    //	let value = BehaviorRelay<DynamicValue>(value: DynamicValue.string(""))

    // MARK: initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: bindings

    //	func bind(title: String, subtitle: String, ) {
//
    //	}

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
    }
}
