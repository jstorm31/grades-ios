//
//  ViewController.swift
//  Classification
//
//  Created by Jiří Zdvomka on 25/02/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
import SnapKit
import UIKit

class LoginViewController: BaseViewController {
    // MARK: UI elements

    weak var loginButton: UIButton!

    // MARK: properties

    let viewModel = LoginViewModel()
    let bag = DisposeBag()

    // MARK: lifecycle methods

    override func loadView() {
        super.loadView()

        // Logo
        let logo = UIImage(named: "FullTextLogo")
        let logoView = UIImageView(image: logo)
        view.addSubview(logoView)
        logoView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(160)
        }

        // Login button
        let button = UIPrimaryButton()
        button.setTitle(L10n.Button.login, for: .normal)
        button.addTarget(self, action: #selector(authButtonTapped(_:)), for: .primaryActionTriggered)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.width.equalTo(180)
            make.height.equalTo(60)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(190)
        }
        loginButton = button
    }

    // MARK: events

    @objc private func authButtonTapped(_: UIButton) {
        viewModel.authenticate(viewController: self)
            .subscribe(onError: { error in
                print(error.localizedDescription)
            }, onCompleted: {
                print("Authenticated!")
            })
            .disposed(by: bag)
    }
}
