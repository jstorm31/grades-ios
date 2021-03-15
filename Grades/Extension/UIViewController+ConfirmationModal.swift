//
//  UIViewController+ConfirmationModal.swift
//  Grades
//
//  Created by Jiří Zdvomka on 20/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import UIKit

protocol ConfirmationModalPresentable {
    func present(_ controller: UIViewController, animated: Bool, completion: (() -> Void)?)
}

extension ConfirmationModalPresentable {
    func present(_ controller: UIViewController, animated: Bool) {
        present(controller, animated: animated, completion: nil)
    }
}

extension ConfirmationModalPresentable {
    func displayConfirmation(title: String,
                             message: String? = nil,
                             cancelTitle: String? = nil,
                             confirmTitle: String? = nil,
                             confirmIsPreffered: Bool = true,
                             cancelHandler: (() -> Void)? = nil,
                             confirmedHandler: @escaping () -> Void)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancelAction: UIAlertAction
        if let cancelHandler = cancelHandler {
            cancelAction = UIAlertAction(title: cancelTitle ?? L10n.Button.cancel, style: .cancel) { _ in
                cancelHandler()
            }
        } else {
            cancelAction = UIAlertAction(title: cancelTitle ?? L10n.Button.cancel, style: .cancel)
        }
        alertController.addAction(cancelAction)

        let okAction = UIAlertAction(title: confirmTitle ?? L10n.Button.confirm, style: .default) { _ in
            confirmedHandler()
        }
        alertController.addAction(okAction)
        alertController.preferredAction = confirmIsPreffered ? okAction : cancelAction

        present(alertController, animated: true)
    }
}
