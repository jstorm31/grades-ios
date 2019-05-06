//
//  LinkCell.swift
//  Grades
//
//  Created by Jiří Zdvomka on 06/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

typealias LinkCellConfigurator = TableCellConfigurator<LinkCell, String>

final class LinkCell: BasicCell, ConfigurableCell {
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(data title: String) {
        self.title = title
    }

    func loadUI() {
        titleLabel.textColor = UIColor.Theme.secondary
    }
}
