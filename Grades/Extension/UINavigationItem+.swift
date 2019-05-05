//
//  UINavigationItem+.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

extension UINavigationItem {
    func setTitle(_ title: String, subtitle: String) {
        let appearance = UINavigationBar.appearance()
        let textColor = appearance.titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor ?? .black

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: UIFont.TextStyle.headline)
        titleLabel.textColor = textColor

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        subtitleLabel.textColor = textColor.withAlphaComponent(0.75)

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.axis = .vertical

        if case .always = largeTitleDisplayMode {}

        stackView.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(60)
        }

        titleView = stackView
    }
}
