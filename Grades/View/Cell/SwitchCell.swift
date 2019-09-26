//
//  SwitchCell.swift
//  Grades
//
//  Created by Jiří Zdvomka on 26/09/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

typealias SwitchCellContent = (title: String, isEnabled: Bool)
typealias SwitchCellConfigurator = TableCellConfigurator<SwitchCell, SwitchCellContent>

final class SwitchCell: BasicCell, ConfigurableCell {
    private var enabledSwitch: UIPrimarySwitch!

    var content: SwitchCellContent! {
        didSet {
            titleLabel.text = content.title
            enabledSwitch.isEnabled = content.isEnabled
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadUI()

        selectionStyle = .none
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(data content: SwitchCellContent) {
        self.content = content
    }

    func loadUI() {
        titleLabel.textColor = UIColor.Theme.text

        let enabledSwitch = UIPrimarySwitch()
        contentView.addSubview(enabledSwitch)
        enabledSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
        self.enabledSwitch = enabledSwitch
    }
}
