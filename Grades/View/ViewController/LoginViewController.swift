//
//  ViewController.swift
//  Classification
//
//  Created by Jiří Zdvomka on 25/02/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Action
import RxSwift
import SnapKit
import UIKit

class LoginViewController: BaseViewController, BindableType, ConfirmationModalPresentable {
    // MARK: UI elements

    var loginButton: UIButton!
    var privacyButton: UIButton!

    // MARK: properties

    var viewModel: LoginViewModel!
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
            make.top.equalToSuperview().inset(view.frame.height * 0.25) // Relative inset
        }

        // Login button
        let button = UIPrimaryButton()
        button.accessibilityIdentifier = "Login"
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

        let privacyButton = UIButton()
        privacyButton.setTitle(L10n.Button.privacy, for: .normal)
        privacyButton.setTitleColor(UIColor.Theme.secondary, for: .normal)
        privacyButton.titleLabel?.font = UIFont.Grades.body
        privacyButton.titleLabel?.textAlignment = .center
        view.addSubview(privacyButton)
        privacyButton.snp.makeConstraints { make in
            make.top.equalTo(button.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        self.privacyButton = privacyButton
    }

    // MARK: methods

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchRemoteConfig()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func bindViewModel() {
        guard let viewModel = viewModel else { return }

        let fetching = viewModel.fetching.distinctUntilChanged().share()
        fetching.asDriver(onErrorJustReturn: false).drive(view.rx.refreshing).disposed(by: bag)
        fetching.map { !$0 }.asDriver(onErrorJustReturn: false).drive(loginButton.rx.isEnabled).disposed(by: bag)

        viewModel.authenticateWithRefresToken()
            .subscribeOn(MainScheduler.instance)
            .subscribe(onError: { [weak self] error in
                Log.report(error)

                DispatchQueue.main.async {
                    if let view = self?.view {
                        if case let ActionError.underlyingError(underlyingError) = error {
                            view.makeCustomToast(underlyingError.localizedDescription, type: .danger)
                        } else {
                            view.makeCustomToast(error.localizedDescription, type: .danger)
                        }
                    }
                }
            })
            .disposed(by: bag)

        // GDPR compliance
        viewModel.displayGdprAlert
            .filter { $0 == true }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] _ in
                self?.displayConfirmation(title: L10n.Gdpr.title,
                                          message: L10n.Gdpr.message,
                                          cancelTitle: L10n.Gdpr.disagree,
                                          confirmTitle: L10n.Gdpr.agree,
                                          confirmIsPreffered: true,
                                          cancelHandler: { [weak self] in
                                              self?.viewModel.gdprCompliant.onNext(false)
                                          }, confirmedHandler: { [weak self] in
                                              self?.viewModel.gdprCompliant.onNext(true)
                                          })
            })
            .disposed(by: bag)

        // Privacy button
        privacyButton.rx.action = viewModel.openPrivacyPolicyLink
    }

    // MARK: events

    @objc private func authButtonTapped(_: UIButton) {
        viewModel.authenticate(viewController: self)
            .subscribeOn(MainScheduler.instance)
            .subscribe(onError: { [weak self] error in
                DispatchQueue.main.async {
                    if let view = self?.view {
                        view.makeCustomToast(error.localizedDescription, type: .danger)
                    }
                }
            })
            .disposed(by: bag)
    }
}
