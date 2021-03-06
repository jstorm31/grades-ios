//
//  UIView+Rx.swift
//  Grades
//
//  Created by Jiří Zdvomka on 08/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

public extension Reactive where Base: UIView {
    /// Bindable sink for toast activity indicator
    var refreshing: Binder<Bool> {
        return Binder(base) { view, active in
            if active {
                view.makeToastActivity(.center)
            } else {
                view.hideToastActivity()
            }
        }
    }

    var errorMessage: Binder<Error?> {
        return Binder(base) { view, error in
            if let error = error {
                view.makeCustomToast(error.localizedDescription, type: .danger)
            }
        }
    }

    var successMessage: Binder<String> {
        return Binder(base) { view, message in
            view.makeCustomToast(message, type: .success)
        }
    }
}
