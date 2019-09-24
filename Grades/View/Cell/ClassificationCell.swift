//
//  ClassificationCell.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class ClassificationCell: UITableViewCell {
    private var containerView: UIView!
    private var title: UILabel!
    private var value: UILabel!
    private var iconView: UIImageView!

    private let isIconHidden = BehaviorSubject<Bool>(value: true)
    private let bag = DisposeBag()

    var classification: Classification? {
        didSet {
            guard let classification = classification else { return }
            isIconHidden.onNext(true)

            title.text = classification.getLocalizedText()

            guard let classificationValue = classification.value else {
                let text = NSAttributedString(string: L10n.Classification.notRated,
                                              attributes: [
                                                  NSAttributedString.Key.font: UIFont.Grades.smallText,
                                                  NSAttributedString.Key.foregroundColor: UIColor.Theme.grayText
                                              ])
                value.attributedText = text
                return
            }

            switch classificationValue {
            case let .number(number):
                if let number = number {
                    let text = NSMutableAttributedString()
                    let boldAttr = [NSAttributedString.Key.font: UIFont.Grades.boldBody]
                    let boldText = NSMutableAttributedString(string: "\(number.cleanValue)", attributes: boldAttr)
                    text.append(boldText)
                    text.append(NSAttributedString(string: " \(L10n.Courses.points)"))
                    value.attributedText = text
                }

            case let .string(string):
                if let string = string {
                    value.text = string
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadUI() {
        // Container
        let containerView = UIView()
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview()
        }
        self.containerView = containerView

        // Title
        let title = UILabel()
        title.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.Grades.body)
        title.adjustsFontForContentSizeCategory = true
        title.textColor = UIColor.Theme.text
        containerView.addSubview(title)
        title.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        self.title = title

        // Text
        let value = UILabel()
        value.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.Grades.body)
        value.adjustsFontForContentSizeCategory = true
        value.textColor = UIColor.Theme.text
        containerView.addSubview(value)
        value.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        self.value = value

        isIconHidden.asDriver(onErrorJustReturn: true)
            .map { !$0 }
            .drive(self.value.rx.isHidden)
            .disposed(by: bag)

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
