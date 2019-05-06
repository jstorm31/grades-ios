//
//  TextViewController.swift
//  Grades
//
//  Created by Jiří Zdvomka on 06/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

final class TextViewController: BaseViewController, BindableType {
    var viewModel: TextViewModel!
    private var textLabel: UILabel!

    override func loadView() {
        super.loadView()
        navigationItem.title = "Text"
        loadUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent {
            viewModel.onBackAction.execute()
        }
    }

    func bindViewModel() {
        textLabel.text = viewModel.text
    }

    private func loadUI() {
        view.backgroundColor = .white

        let contentView = UIScrollView()
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        let textLabel = UILabel()
        textLabel.font = UIFont.Grades.body
        textLabel.textColor = UIColor.Theme.text
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(20)
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        self.textLabel = textLabel
    }
}
