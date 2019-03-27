//
//  LoginViewModelTests.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 09/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import GradesDev

class LoginViewModelTests: XCTestCase {
	var viewModel: LoginViewModel!
	var scheduler: ConcurrentDispatchQueueScheduler!
	var sceneMock: SceneCoordinatorMock!
	var authMock: AuthenticationServiceMock!
	var gradesApiMock: GradesAPIMock!
	
	override func setUp() {
		sceneMock = SceneCoordinatorMock()
		authMock = AuthenticationServiceMock()
		gradesApiMock = GradesAPIMock()		
		scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		viewModel = LoginViewModel(dependencies: AppDependencyMock.shared, sceneCoordinator: sceneMock)
	}
	
	override func tearDown() {}

    func testAuthenticationSuccesful() {
		authMock.result = .success
		
		let userObservable = viewModel.authenticate(viewController: UIViewController())
		
		do {
			guard let user = try userObservable.toBlocking(timeout: 1.0).first() else { return }

			// TODO: update test
//			XCTAssertEqual(user.username, "mockuser")
//			XCTAssertNotNil(sceneMock.targetScene)
		} catch {
			XCTFail("should not throw error")
		}
    }
	
	func testAuthenticationSuccessfulFetchUserFailed() {
		authMock.result = .success
		gradesApiMock.result = .failure

		let userObservable = viewModel.authenticate(viewController: UIViewController())
		
		do {
			guard let _ = try userObservable.toBlocking(timeout: 1.0).first() else { return }
			XCTFail("should throw error")
			
		} catch {
			XCTAssertEqual(error as! ApiError, .general)
			XCTAssertNil(sceneMock.targetScene)
		}
	}
	
	func testAuthenticationFailed() {
		authMock.result = .failure
		
		let userObservable = viewModel.authenticate(viewController: UIViewController())
		
		do {
			guard let _ = try userObservable.toBlocking(timeout: 1.0).first() else { return }
			XCTFail("should throw error")
			
		} catch {
			XCTAssertEqual(error as! AuthenticationError, .generic)
			XCTAssertNil(sceneMock.targetScene)
		}
	}

}
