//
//  unwrap.swift
//  RxSwiftExt
//
//  Created by Marin Todorov on 4/7/16.
//  Copyright © 2016 RxSwift Community. All rights reserved.
//
import Foundation
import RxSwift

public extension ObservableType {
    /**
     Takes a sequence of optional elements and returns a sequence of non-optional elements, filtering out any nil values.
     - returns: An observable sequence of non-optional elements
     */

    func unwrap<T>() -> Observable<T> where Element == T? {
        return filter { $0 != nil }.map { $0! }
    }
}
