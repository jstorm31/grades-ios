//
//  RefreshControl+Rx.swift
//  Grades
//
//  Created by Jiří Zdvomka on 08/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIRefreshControl {
    /// Bindable sink for `beginRefreshing()`, `endRefreshing()` methods
    public var isRefreshing: Binder<Bool> {
        return Binder(base) { refreshControl, active in
            if active {
                refreshControl.beginRefreshing()
            } else {
                refreshControl.endRefreshing()
            }
        }
    }
}
