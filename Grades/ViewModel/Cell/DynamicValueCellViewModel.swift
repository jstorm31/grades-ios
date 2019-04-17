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

    let valueType = PublishSubject<DynamicValueType>()
    let stringValue = PublishSubject<String?>()
    let boolValue = PublishSubject<Bool>()

    let valueInput = PublishSubject<DynamicValue?>()
    let valueOutput = PublishSubject<DynamicValue>()

    let bag = DisposeBag()

    init(key: String, title: String? = nil) {
        self.key = key
        self.title = title
    }

    func bindOutput() {
        let sharedValue = valueInput.share()

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
            .map { $0 != nil }
            .bind(to: boolValue)
            .disposed(by: bag)
    }
}
