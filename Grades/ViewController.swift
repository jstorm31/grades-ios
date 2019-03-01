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

class ViewController: UIViewController {
    weak var authButton: UIButton!

    let auth = AuthenticationService()
    let bag = DisposeBag()

    override func loadView() {
        super.loadView()

        let button = UIButton()
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Authenticate", for: .normal)
        button.addTarget(self, action: #selector(authButtonTapped(_:)), for: .primaryActionTriggered)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        authButton = button
    }

    override func viewDidLoad() {
        super.viewDidLoad() }

    @objc private func authButtonTapped(_: UIButton) {
        auth.authenticate(useBuiltInSafari: true, viewController: self)
            .subscribe(onError: { error in
                print(error.localizedDescription)
            }, onCompleted: {
                print("Authenticated!")
            })
            .disposed(by: bag)
    }
}
