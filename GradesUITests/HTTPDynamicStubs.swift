//
//  HTTPDynamicStubs.swift
//  GradesUITests
//
//  Created by Jiří Zdvomka on 02/05/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import Swifter

enum HTTPMethod {
	case POST
	case GET
	case PUT
	case DELETE
}

class HTTPDynamicStubs {
	
	var server = HttpServer()
	
	func setUp() {
		setupInitialStubs()
		try! server.start()
	}
	
	func tearDown() {
		server.stop()
	}
	
	func setupInitialStubs() {
		// Setting up all the initial mocks from the array
		for stub in initialJSONStubs {
			setupStub(url: stub.url, filename: stub.jsonFilename, method: stub.method)
		}
		
		for stub in initialStringStubs {
			setupStub(url: stub.url, response: stub.response, method: stub.method)
		}
	}
	
	public func setupStub(url: String, filename: String, method: HTTPMethod = .GET) {
		let testBundle = Bundle(for: type(of: self))
		let filePath = testBundle.path(forResource: filename, ofType: "json")
		let fileUrl = URL(fileURLWithPath: filePath!)
		let data = try! Data(contentsOf: fileUrl, options: .uncached)
		// Looking for a file and converting it to JSON
		let json = dataToJSON(data: data)
		
		// Swifter makes it very easy to create stubbed responses
		let response: ((HttpRequest) -> HttpResponse) = { _ in
			return HttpResponse.ok(.json(json as AnyObject))
		}
		
		switch method  {
		case .GET: server.GET[url] = response
		case .POST: server.POST[url] = response
		case .PUT: server.PUT[url] = response
		case .DELETE: server.DELETE[url] = response
		}
	}
	
	public func setupStub(url: String, response: String, method: HTTPMethod = .GET) {
		let data = Data(response.utf8)
		
		// Swifter makes it very easy to create stubbed responses
		let response: ((HttpRequest) -> HttpResponse) = { _ in
			return HttpResponse.ok(.data(data))
		}
		
		switch method  {
		case .GET: server.GET[url] = response
		case .POST: server.POST[url] = response
		case .PUT: server.PUT[url] = response
		case .DELETE: server.DELETE[url] = response
		}
	}
	
	func dataToJSON(data: Data) -> Any? {
		do {
			return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
		} catch let myJSONError {
			print(myJSONError)
		}
		return nil
	}
}

struct HTTPStubInfo {
	let url: String
	let jsonFilename: String
	let method: HTTPMethod
}

struct HTTPStringStubInfo {
	let url: String
	let response: String
	let method: HTTPMethod
}

let initialJSONStubs = [
	HTTPStubInfo(url: "api/v1/public/user-info", jsonFilename: "user-info", method: .GET),
	HTTPStubInfo(url: "api/v1/public/courses/classification-overview/kratond", jsonFilename: "classification-overview", method: .GET),
	HTTPStubInfo(url: "api/v1/public/user-roles", jsonFilename: "user-roles", method: .GET),
	HTTPStubInfo(url: "api/v1/public/courses/BI-PJS.1/information", jsonFilename: "course-name", method: .GET),
	HTTPStubInfo(url: "api/v1/public/courses/MI-IOS/information", jsonFilename: "course-name", method: .GET),
]

let initialStringStubs = [
	HTTPStringStubInfo(url: "api/v1/public/semester-code", response: "B182", method: .GET)
]
