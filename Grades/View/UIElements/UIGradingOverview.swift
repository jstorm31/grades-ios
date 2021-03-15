//
//  UIGradingOverview.swift
//  Grades
//
//  Created by Jiří Zdvomka on 18/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class UIGradingOverview: UIView {
    var pointsLabel: UILabel!
    private var gradeLabel: UILabel!

    var grade = PublishSubject<String>()
    private let bag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutSubviews()

        grade.asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] grade in
                self?.gradeLabel.text = grade
                self?.gradeLabel.textColor = UIColor.Theme.getGradeColor(forGrade: grade)
            })
            .disposed(by: bag)
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Grade label
        let grade = UILabel()
        grade.font = UIFont.Grades.display
        grade.textColor = UIColor.Theme.text
        grade.textAlignment = .right
        addSubview(grade)
        grade.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(40)
        }
        gradeLabel = grade

        // Points label
        let points = UILabel()
        points.font = UIFont.Grades.body
        points.textColor = UIColor.Theme.text
        points.textAlignment = .right
        addSubview(points)
        points.snp.makeConstraints { make in
            make.width.equalTo(140)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(gradeLabel.snp.leading).offset(-13)
        }
        pointsLabel = points
    }
}
