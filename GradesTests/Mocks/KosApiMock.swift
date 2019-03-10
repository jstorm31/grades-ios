//
//  KosApiMock.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 10/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift
@testable import GradesDev

class KosApiMock: KosApiProtocol {
	var result = Result.success
	
	func getCourseName(code: String) -> Observable<String> {
		switch result {
		case .success:
			let name = code == "BI-PST" ? "Pravděpodobnost a statistika" : "Název předmětu"
			return Observable.just(name)
		case .failure:
			return Observable.error(ApiError.general)
		}
	}
}
