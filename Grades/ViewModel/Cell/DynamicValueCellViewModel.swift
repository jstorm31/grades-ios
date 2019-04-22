//
//  DynamicValueCellViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 16/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift

final class DynamicValueCellViewModel {
    let key: String
    let title: String?
    let subtitle: String?

    let value = BehaviorSubject<DynamicValue?>(value: nil)
    let bag = DisposeBag()

    // MARK: Cell output

    let showTextField = PublishSubject<Bool>()
    let stringValue = PublishSubject<String?>()
    let boolValue = PublishSubject<Bool>()

    // MARK: Initialization

    init(key: String, title: String? = nil, subtitle: String? = nil) {
        self.key = key
        self.title = title
        self.subtitle = subtitle
    }

    // MARK: Binding

    func bindOutput() {
        let sharedValue = value.share(replay: 1, scope: .whileConnected)

        sharedValue
            .unwrap()
            .map { type -> Bool in
                switch type {
                case .string, .number:
                    return true
                case .bool:
                    return false
                }
            }
            .bind(to: showTextField)
            .disposed(by: bag)

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
