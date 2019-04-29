//
//  DynamicValueCellViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 16/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift

final class DynamicValueCellViewModel {
    let valueType: DynamicValueType
    let key: String
    let title: String?
    let subtitle: String?

    let value = BehaviorRelay<DynamicValue?>(value: nil)
    let bag = DisposeBag()

    // MARK: Cell output

    let stringValue = PublishSubject<String?>()
    let boolValue = PublishSubject<Bool>()

    // MARK: Initialization

    init(valueType: DynamicValueType, key: String, title: String? = nil, subtitle: String? = nil) {
        self.valueType = valueType
        self.key = key
        self.title = title
        self.subtitle = subtitle

        Log.debug("[Allocated]: \(key)")
    }

    deinit {
        Log.debug("[Deallocated]: \(key)")
    }

    // MARK: Binding

    func bindOutput() {
        let sharedValue = value.share(replay: 1, scope: .whileConnected)

        sharedValue
            .map { (value: DynamicValue?) -> String? in
                guard let value = value else { return nil }

                switch value {
                case let .string(value):
                    return value
                case let .number(value):
                    return value != nil ? String(value!) : nil
                default:
                    return nil
                }
            }
            .bind(to: stringValue)
            .disposed(by: bag)

        sharedValue
            .map { (value: DynamicValue?) -> Bool? in
                guard let value = value else { return nil }

                if case let .bool(boolValue) = value {
                    return boolValue
                }
                return nil
            }
            .map { $0 == nil ? false : $0! }
            .bind(to: boolValue)
            .disposed(by: bag)
    }
}
