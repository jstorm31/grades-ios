//
//  KosApi.swift
//  Grades
//
//  Created by Jiří Zdvomka on 10/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import OAuthSwift
import RxSwift

protocol KosApiProtocol {
    func getCourseName(code: String) -> Observable<String>
}

class KosApi: KosApiProtocol {
    private let config: [String: String]
    private let client: OAuthSwiftClient

    var baseUrl: String {
        return config["BaseURL"]!
    }

    private enum Endpoint {
        case course(String)
    }

    init(client: OAuthSwiftClient, configuration: [String: String]) {
        config = configuration
        self.client = client
    }

    func getCourseName(code: String) -> Observable<String> {
        let url = createURL(from: .course(code))
        var parameters: OAuthSwift.Parameters = [:]

        if let locale = Locale.current.languageCode {
            parameters = ["lang": locale]
        }

        return Observable.create { [weak self] observer in
            self?.client.request(url, method: .GET, parameters: parameters, success: { response in
                let courseParser = CourseXMLParser()
                let parser = XMLParser(data: response.data)
                parser.delegate = courseParser

                if parser.parse() {
                    observer.onNext(courseParser.courseName)
                    observer.onCompleted()
                } else {
                    Log.error("GradesAPI.request: Could not proccess response data to JSON.")
                    observer.onError(ApiError.unprocessableData)
                }
            }, failure: { error in
                Log.error("GradesAPI.request: External API error: \(error.localizedDescription)")
                observer.onError(ApiError.getError(forCode: error.errorCode))
            })

            return Disposables.create()
        }
    }

    private func createURL(from endpoint: Endpoint) -> URL {
        var endpointValue = ""

        switch endpoint {
        case let .course(code):
            endpointValue = config["Course"]!
                .replacingOccurrences(of: ":code", with: code)
        }

        return URL(string: "\(baseUrl)\(endpointValue)")!
    }
}
