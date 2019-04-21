//
//  BasicCell.swift
//  Grades
//
//  Created by Jiří Zdvomka on 21/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

typealias UserCellConfigurator = TableCellConfigurator<UserCell, User>

final class UserCell: BasicCell, ConfigurableCell {
    typealias DataType = User

    func configure(data user: User) {
        titleLabel.text = user.name
        subtitleLabel.text = user.username
    }
}
