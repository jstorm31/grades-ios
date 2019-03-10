//
//  HttpServiceMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 09/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxSwift
@testable import GradesDev

class HttpServiceMock: HttpServiceProtocol {
	func get<T>(url: URL, parameters: HttpServiceProtocol.HttpParameters?) -> Observable<T> where T : Decodable {
		return Observable.empty()
	}
}
