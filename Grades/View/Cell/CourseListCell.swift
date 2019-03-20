//
//  CourseListCell.swift
//  Grades
//
//  Created by Jiří Zdvomka on 10/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class CourseListCell: UITableViewCell {
    private var title: UILabel!
    private var subtitle: UILabel!
    private var rightLabel: UILabel!
    private var iconView: UIImageView!

    private let isIconHidden = BehaviorSubject<Bool>(value: true)
    private let bag = DisposeBag()

    var course: Course? {
        didSet {
            guard let course = course else { return }
            isIconHidden.onNext(true)

            title.text = course.code
            subtitle.text = course.name

            // Reset
            rightLabel.text = ""
            rightLabel.textColor = UIColor.Theme.grayText

            if let finalValue = course.finalValue {
                switch finalValue {
                case let .number(number):
                    if let number = number {
                        let text = NSMutableAttributedString()
                        let boldAttr = [NSAttributedString.Key.font: UIFont.Grades.boldBody]
                        let boldText = NSMutableAttributedString(string: "\(number.cleanValue)", attributes: boldAttr)
                        text.append(boldText)
                        text.append(NSAttributedString(string: " \(L10n.Courses.points)"))
                        rightLabel.attributedText = text
                    }

                case let .string(string):
                    if let string = string {
                        rightLabel.textColor = UIColor.Theme.setGradeColor(forGrade: string, defaultColor: UIColor.Theme.grayText)
                        rightLabel.text = string
                    }

                case let .bool(bool):
                    if let bool = bool {
                        let icon = UIImage(named: bool ? "icon_success" : "icon_failure")!
                        iconView.image = icon
                        isIconHidden.onNext(false)
                    }
                }
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

        // Icon
        let iconView = UIImageView()
        containerView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        self.iconView = iconView

        isIconHidden.asDriver(onErrorJustReturn: true)
            .drive(self.iconView.rx.isHidden)
            .disposed(by: bag)
    }
}
