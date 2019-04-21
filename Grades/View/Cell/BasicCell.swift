//
//  BasicCell.swift
//  Grades
//
//  Created by Jiří Zdvomka on 21/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

/// Cell with title, subtitle and accessory view
class BasicCell: UITableViewCell {
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func loadUI() {
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
    }
}
