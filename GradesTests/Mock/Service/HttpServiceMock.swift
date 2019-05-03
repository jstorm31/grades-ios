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
	func delete<T>(url: URL, parameters: HttpServiceProtocol.HttpParameters?, body: T) -> Observable<Void> where T : Encodable {
		return Observable.empty()
	}
	
	func post<T>(url: URL, parameters: HttpServiceProtocol.HttpParameters?, body: T) -> Observable<Void> where T : Encodable {
		return Observable.empty()
	}
	
	func put<T>(url: URL, parameters: HttpServiceProtocol.HttpParameters?, body: T) -> Observable<Void> where T : Encodable {
		return Observable.empty()
	}
	
	func get<T>(url: URL, parameters: HttpServiceProtocol.HttpParameters?) -> Observable<T> where T : Decodable {
		return Observable.empty()
	}
	
	func get(url: URL, parameters: HttpParameters?) -> Observable<String> {
		return Observable.just("")
	}
}
