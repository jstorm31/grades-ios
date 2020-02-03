//
//  RemoteConfigServiceMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 03/02/2020.
//  Copyright © 2020 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
@testable import Grades

final class RemoteConfigServiceMock: RemoteConfigServiceProtocol {
    var config = BehaviorRelay<RemoteConfig>(value: RemoteConfig())
    var fetching =  BehaviorSubject<Bool>(value: false)
    var mockData = BehaviorRelay<Bool>(value: false)
    
    func fetchConfig() {
        config.accept(RemoteConfig())
    }
}
