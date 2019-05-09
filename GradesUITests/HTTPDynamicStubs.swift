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
		for stub in initialJsontStubsWithParameters {
			setupStubWithParameters(url: stub.url, to: stub.to, method: stub.method)
		}
		
		for stub in initialJSONStubs {
			setupStub(url: stub.url, filename: stub.jsonFilename, method: stub.method)
		}
		
		for stub in initialStringStubs {
			setupStub(url: stub.url, response: stub.response, method: stub.method)
		}
	}
	
	func setupStubWithParameters(url: String, to mappedData: MappedFilenameToParameter, method: HTTPMethod = .GET) {
		let response: ((HttpRequest) -> HttpResponse) = { [weak self] request in
			
			guard let filename = self?.findFile(for: request, in: mappedData) else {
				return HttpResponse.notFound
			}
			
			let testBundle = Bundle(for: type(of: self!))
			let filePath = testBundle.path(forResource: filename, ofType: "json")
			let fileUrl = URL(fileURLWithPath: filePath!)
			let data = try! Data(contentsOf: fileUrl, options: .uncached)
			let json = self?.dataToJSON(data: data)
			return HttpResponse.ok(.json(json as AnyObject))
		}
		
		switch method  {
		case .GET: server.GET[url] = response
		case .POST: server.POST[url] = response
		case .PUT: server.PUT[url] = response
		case .DELETE: server.DELETE[url] = response
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
	
	private func findFile(for request: HttpRequest, in map: MappedFilenameToParameter) -> String? {
		for param in request.queryParams {
			if let filename = map[DynamicStubParameter(name: param.0, value: param.1)]  {
				return filename
			}
		}
		return nil
	}
}

struct DynamicStubParameter: Hashable {
	var name = ""
	var value = ""
}

typealias MappedFilenameToParameter = [DynamicStubParameter:String]

struct HTTPStubInfo {
	let url: String
	let jsonFilename: String
	let method: HTTPMethod
}

struct HTTPStubInfoParameters {
	let url: String
	let method: HTTPMethod
	let to: MappedFilenameToParameter
}

struct HTTPStringStubInfo {
	let url: String
	let response: String
	let method: HTTPMethod
}

let initialJSONStubs = [
	HTTPStubInfo(url: "api/v1/public/user-info", jsonFilename: "user-info", method: .GET),
	HTTPStubInfo(url: "api/v1/public/courses/BI-PJS.1/student-classifications/kratond", jsonFilename: "student-classification", method: .GET),
	HTTPStubInfo(url: "api/v1/public/course/BI-PJS.1/student-groups", jsonFilename: "student-groups", method: .GET),
	HTTPStubInfo(url: "api/v1/public/courses/BI-PJS.1/classifications", jsonFilename: "classifications", method: .GET),
	HTTPStubInfo(url: "api/v1/public/courses/BI-PJS.1/group/ALL/student-classifications/semestral_test_1", jsonFilename: "student-classifications", method: .GET),
	HTTPStubInfo(url: "api/v1/public/courses/BI-PJS.1/group/TEST/student-classifications/semestral_test_1", jsonFilename: "student-classifications", method: .GET),
	HTTPStubInfo(url: "api/v1/public/courses/BI-PJS.1/group/ALL/student-classifications/semestral_test", jsonFilename: "student-classifications", method: .GET),
	HTTPStubInfo(url: "api/v1/public/courses/BI-PJS.1/student-classifications", jsonFilename: "student-classifications-put", method: .PUT),
	HTTPStubInfo(url: "api/v1/public/courses/BI-PJS.1/group/MY_PARALLELS/student-classifications", jsonFilename: "my-paralels", method: .GET),
	HTTPStubInfo(url: "api/v1/public/courses/BI-PJS.1/student-classifications/pavjan", jsonFilename: "student-classification", method: .GET),
	HTTPStubInfo(url: "api/v1/public/courses/BI-PJS.1/student-classifications/tichon", jsonFilename: "student-classification", method: .GET)
]

let initialJsontStubsWithParameters = [
	HTTPStubInfoParameters(url: "api/v1/public/courses/classification-overview/kratond", method: .GET, to: [
		DynamicStubParameter(name: "semester", value: "B182"): "classification-overview-B182",
		DynamicStubParameter(name: "semester", value: "B181"): "classification-overview-B181"
	]),
	HTTPStubInfoParameters(url: "api/v1/public/courses/BI-PJS.1/information", method: .GET, to: [
		DynamicStubParameter(name: "semester", value: "B182"): "course-name",
	]),
	HTTPStubInfoParameters(url: "api/v1/public/courses/MI-IOS/information", method: .GET, to: [
		DynamicStubParameter(name: "semester", value: "B182"): "course-name",
	]),
	HTTPStubInfoParameters(url: "api/v1/public/courses/BI-KOM/information", method: .GET, to: [
		DynamicStubParameter(name: "semester", value: "B181"): "course-name",
	]),
	HTTPStubInfoParameters(url: "api/v1/public/user-roles", method: .GET, to: [
		DynamicStubParameter(name: "semester", value: "B182"): "user-roles-182",
		DynamicStubParameter(name: "semester", value: "B181"): "user-roles-181"
	])
]

let initialStringStubs = [
	HTTPStringStubInfo(url: "api/v1/public/semester-code", response: "B182", method: .GET)
]
