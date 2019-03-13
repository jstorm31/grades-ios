//
//  CourseListCell.swift
//  Grades
//
//  Created by Jiří Zdvomka on 10/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import SnapKit
import UIKit

class CourseListCell: UITableViewCell {
    var title: UILabel!
    var subtitle: UILabel!
    var rightLabel: UILabel!

    var course: Course? {
        didSet {
            guard let course = course else { return }

            title.text = course.code
            subtitle.text = course.name

            if let points = course.totalPoints {
                rightLabel.text = "\(points) \(L10n.Courses.points)"
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

    /// Set and load appearance
    func loadUI() {
        let containerView = UIView()
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }

        let title = UILabel()
        title.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.Grades.cellTitle)
        title.adjustsFontForContentSizeCategory = true
        title.textColor = UIColor.Theme.text
        containerView.addSubview(title)
        title.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
        }
        self.title = title

        let subtitle = UILabel()
        subtitle.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.Grades.body)
        subtitle.adjustsFontForContentSizeCategory = true
        subtitle.textColor = UIColor.Theme.grayText
        containerView.addSubview(subtitle)
        subtitle.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(6)
            make.bottom.left.equalToSuperview()
        }
        self.subtitle = subtitle

        let rightLabel = UILabel()
        rightLabel.text = ""
        rightLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.Grades.body)
        rightLabel.adjustsFontForContentSizeCategory = true
        rightLabel.textColor = UIColor.Theme.grayText
        containerView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
        }
        self.rightLabel = rightLabel
    }
}
