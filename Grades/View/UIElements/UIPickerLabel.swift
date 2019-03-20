//
//  UIPickerLabel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 20/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

/// Label with icon indicating picker view trigger
class UIPickerLabel: UIView {
    private var textLabel: UILabel!

    var text: String {
        get {
            return textLabel.text ?? ""
        }
        set {
            textLabel.text = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        let iconArrow = UIImage(named: "icon_arrow_down")!
        let imageView = UIImageView(image: iconArrow)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.equalTo(6)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        let textLabel = UILabel()
        textLabel.font = UIFont.Grades.body
        textLabel.textColor = UIColor.Theme.text
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.trailing.equalTo(imageView.snp.leading).offset(-4)
            make.centerY.equalToSuperview()
        }
        self.textLabel = textLabel
    }
}
