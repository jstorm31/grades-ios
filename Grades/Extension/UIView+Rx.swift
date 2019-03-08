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

extension Reactive where Base: UIView {
    /// Bindable sink for toast activity indicator
    public var refreshing: Binder<Bool> {
        return Binder(base) { view, active in
            if active {
                view.makeToastActivity(.center)
            } else {
                view.hideToastActivity()
            }
        }
    }
}
