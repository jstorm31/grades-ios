//
//  DynamicValueCellViewModel.swift
//  Grades
//
//  Created by Jiří Zdvomka on 16/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift

final class DynamicValueCellViewModel {
    let title = BehaviorSubject<String>(value: "")
    let subtititle = BehaviorSubject<String>(value: "")
    let valueInput = BehaviorSubject<DynamicValue>(value: .string(""))
    let valueOutput = PublishSubject<DynamicValue>()
    let stringValue = BehaviorSubject<String?>(value: nil)
    let boolValue = BehaviorSubject<Bool?>(value: nil)

    private let bag = DisposeBag()

    func set(title: String, subtitle: String) {
        self.title.onNext(title)
        subtititle.onNext(subtitle)
    }

    func bindOutput() {
        let sharedValue = valueInput.share()

        sharedValue
            .map { (value: DynamicValue) -> String? in
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
            .map { (value: DynamicValue) -> Bool? in
                if case let .bool(boolValue) = value {
                    return boolValue
                }
                return nil
            }
            .bind(to: boolValue)
            .disposed(by: bag)
    }
}
