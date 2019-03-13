//
//  ClassificationCell.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import SnapKit
import UIKit

class ClassificationCell: UITableViewCell {
    private var title: UILabel!
    private var value: UILabel!

    var classification: Classification? {
        didSet {
            guard let classification = classification else { return }

            title.text = classification.text.first { $0.identifier == Locale.current.languageCode }?.name ?? classification.text[0].name

            guard let classificationValue = classification.value else { return }

            switch classificationValue {
            case let .number(number):
                value.text = "\(number) \(L10n.Courses.points)"
            case let .string(string):
                value.text = string
            case let .bool(bool):
                value.text = bool ? "✅" : "❌" // TODO: replace with icons
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadUI() {
        let containerView = UIView()
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }

        let title = UILabel()
        title.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.Grades.body)
        title.adjustsFontForContentSizeCategory = true
        title.textColor = UIColor.Theme.text
        containerView.addSubview(title)
		title.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.leading.equalToSuperview()
		}
        self.title = title

        let value = UILabel()
        value.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.Grades.body) // TODO: bold font number, regular points
        value.adjustsFontForContentSizeCategory = true
        value.textColor = UIColor.Theme.grayText
        containerView.addSubview(value)
		value.snp.makeConstraints { make in
			make.centerY.equalToSuperview()
			make.trailing.equalToSuperview()
		}
        self.value = value
    }
}
