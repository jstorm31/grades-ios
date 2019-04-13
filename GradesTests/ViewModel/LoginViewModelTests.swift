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
	var scheduler: ConcurrentDispatchQueueScheduler!
	var viewModel: LoginViewModel!
	var sceneMock: SceneCoordinatorMock!
	var gradesApi = AppDependencyMock.shared._gradesApi
	var authService = AppDependencyMock.shared._authService
	
	override func setUp() {
		scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		sceneMock = SceneCoordinatorMock()
		viewModel = LoginViewModel(dependencies: AppDependencyMock.shared, sceneCoordinator: sceneMock)
	}

    func testAuthenticationSuccesful() {
		authService.result = .success
		gradesApi.result = .success
		let authObservable = viewModel.authenticate(viewController: UIViewController())
		
		do {
			let result = try authObservable.toBlocking(timeout: 2.0).toArray()
			
			XCTAssertEqual(result.count, 1, "emits one Void element")
			XCTAssertNotNil(sceneMock.targetScene)
		} catch {
			Log.debug("\(error)")
			XCTFail("should not throw error")
		}
    }
	
	func testAuthenticationSuccessfulFetchUserFailed() {
		authService.result = .success
		gradesApi.result = .failure

		let userObservable = viewModel.authenticate(viewController: UIViewController())
		
		do {
			guard let _ = try userObservable.toBlocking(timeout: 2.0).first() else { return }
			XCTFail("should throw error")
			
		} catch {
			XCTAssertEqual(error as! ApiError, .general)
			XCTAssertNil(sceneMock.targetScene)
		}
	}
	
	func testAuthenticationFailed() {
		authService.result = .failure
		
		let userObservable = viewModel.authenticate(viewController: UIViewController())
		
		do {
			guard let _ = try userObservable.toBlocking(timeout: 2.0).first() else { return }
			XCTFail("should throw error")
			
		} catch {
			XCTAssertEqual(error as! AuthenticationError, .generic)
			XCTAssertNil(sceneMock.targetScene)
		}
	}

}
