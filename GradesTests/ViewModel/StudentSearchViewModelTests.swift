//
//  StudentSearchViewModelTests.swift
//  GradesTests
//
//  Created by Jiří Zdvomka on 21/04/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import GradesDev

class StudentSearchViewModelTests: XCTestCase {
	var scheduler: ConcurrentDispatchQueueScheduler!
	var viewModel: StudentSearchViewModel!
	var coordinator: SceneCoordinatorMock!
	var selectedUser: BehaviorSubject<User?>!
	private let bag = DisposeBag()
	
	override func setUp() {
		scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
		coordinator = SceneCoordinatorMock()
		
		let students = BehaviorRelay<[User]>(value: [
			User(userId: 1, username: "jindra5", firstName: "Jindřich", lastName: "Novák"),
			User(userId: 2, username: "ondra6", firstName: "Ondřej", lastName: "Pavlita")
		])
		
		selectedUser = BehaviorSubject<User?>(value: nil)
		
		viewModel = StudentSearchViewModel(coordinator: coordinator, students: students, selectedStudent: selectedUser)
	}
	
	func testDataSource() {
		let dataSource = viewModel.dataSource.subscribeOn(scheduler)
		let result = try! dataSource.toBlocking(timeout: 2).first()
		XCTAssertEqual(result![0].items.count, 2)
	}
	
	func testStudentSelection() {
		let testScheduler = TestScheduler(initialClock: 0)
		let selectedUser = testScheduler.createObserver(User?.self)
		self.selectedUser.skip(1).bind(to: selectedUser).disposed(by: bag)
		
		testScheduler
			.createColdObservable([.next(10, 1)])
			.bind(to: viewModel.itemSelected)
			.disposed(by: bag)
		testScheduler.start()

		let user = User(userId: 2, username: "ondra6", firstName: "Ondřej", lastName: "Pavlita")
		XCTAssertEqual(selectedUser.events, [.next(10, user)])
	}
}
