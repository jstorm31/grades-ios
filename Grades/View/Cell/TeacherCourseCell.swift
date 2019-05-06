//
//  TeacherCourseCell.swift
//  Grades
//
//  Created by Jiří Zdvomka on 23/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

typealias TeacherCourseCellConfigurator = TableCellConfigurator<TeacherCourseCell, TeacherCourse>

final class TeacherCourseCell: CourseListCell, ConfigurableCell {
    var course: TeacherCourse? {
        didSet {
            guard let course = course else { return }

            title.text = course.code
            subtitle.text = course.name
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(data course: TeacherCourse) {
        self.course = course
    }
}
