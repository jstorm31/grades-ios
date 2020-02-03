//
//  RemoteConfigService.swift
//  Grades
//
//  Created by Jiří Zdvomka on 02/02/2020.
//  Copyright © 2020 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol HasRemoteConfigService {
    var remoteConfigService: RemoteConfigServiceProtocol { get }
}

protocol RemoteConfigServiceProtocol {
    var config: BehaviorRelay<RemoteConfig> { get }
    var mockData: BehaviorRelay<Bool> { get }
    var fetching: BehaviorSubject<Bool> { get }

    func fetchConfig()
}

final class RemoteConfigService: RemoteConfigServiceProtocol {
    typealias Dependencies = HasHttpService

    var config = BehaviorRelay<RemoteConfig>(value: RemoteConfig())
    let fetching = BehaviorSubject<Bool>(value: false)
    var mockData = BehaviorRelay<Bool>(value: false)

    private let dependencies: Dependencies
    private let bag = DisposeBag()

    init(_ dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func fetchConfig() {
        let url = URL(string: EnvironmentConfiguration.shared.remoteConfigUrl)!
        let headers = [
            "Content-Type": "application/json;charset=UTF-8",
            "Cache-Control": "no-cache"
        ]

        fetching.onNext(true)
        let fetchedConfig: Observable<RemoteConfig> = dependencies.httpService
            .get(url: url, parameters: nil, headers: headers).share()

        fetchedConfig.map { _ in false }.bind(to: fetching).disposed(by: bag)
        fetchedConfig.bind(to: config).disposed(by: bag)

        fetchedConfig
            .map { config in
                if let mockDataForVersion = config.mockDataForVersion,
                    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                    mockDataForVersion == appVersion {
                    Log.info("Mocking data for this version")
                    return true
                }
                return false
            }
            .bind(to: mockData)
            .disposed(by: bag)
    }
}
