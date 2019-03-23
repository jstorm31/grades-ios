//
//  StudentCourseCell.swift
//  Grades
//
//  Created by Jiří Zdvomka on 23/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class StudentCourseCell: CourseListCell, ConfigurableCell {
    private let isIconHidden = BehaviorSubject<Bool>(value: true)
    private let bag = DisposeBag()

    var course: StudentCourse? {
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

        isIconHidden.asDriver(onErrorJustReturn: true)
            .drive(iconView.rx.isHidden)
            .disposed(by: bag)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(data course: StudentCourse) {
        self.course = course
    }
}
