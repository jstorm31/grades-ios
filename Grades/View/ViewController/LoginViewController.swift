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

class LoginViewController: BaseViewController, BindableType {
    // MARK: UI elements

    var loginButton: UIButton!

    // MARK: properties

    var viewModel: LoginViewModel!
    private let activityIndicator = ActivityIndicator()
    private let bag = DisposeBag()

    // MARK: lifecycle methods

    override func loadView() {
        super.loadView()

        // Logo
        let logo = UIImage(named: "FullTextLogo")
        let logoView = UIImageView(image: logo)
        view.addSubview(logoView)
        logoView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(view.frame.height * 0.2) // Relative inset
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
            make.bottom.equalToSuperview().inset(view.frame.height * 0.2)
        }
        loginButton = button
    }

    // MARK: methods

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.asDriver()
            .drive(view.rx.refreshing)
            .disposed(by: bag)
    }

    func bindViewModel() {}

    // MARK: events

    @objc private func authButtonTapped(_: UIButton) {
        viewModel.authenticate(viewController: self)
            .trackActivity(activityIndicator)
            .subscribe(onError: { [weak self] error in
                self?.view.makeCustomToast(error.localizedDescription, type: .danger)
            })
            .disposed(by: bag)
    }
}
