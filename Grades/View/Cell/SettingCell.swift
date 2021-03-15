//
//  SettingCell.swift
//  Grades
//
//  Created by Jiří Zdvomka on 05/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

typealias SettingsCellContent = (title: String, content: String?)
typealias SettingsCellConfigurator = TableCellConfigurator<SettingsCell, SettingsCellContent>

final class SettingsCell: BasicCell, ConfigurableCell {
    var content: SettingsCellContent! {
        didSet {
            titleLabel.text = content.title
            rightTextLabel.text = content.content
        }
    }

    private var rightTextLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadUI()

        selectionStyle = .none
    }

    func configure(data content: SettingsCellContent) {
        self.content = content
    }

    func loadUI() {
        titleLabel.font = UIFont.Grades.body
        titleLabel.textColor = UIColor.Theme.text

        let text = UILabel()
        text.font = UIFont.Grades.body
        text.textColor = UIColor.Theme.text
        text.textAlignment = .right
        contentView.addSubview(text)
        text.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
        rightTextLabel = text
    }
}
