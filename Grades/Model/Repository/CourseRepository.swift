//
//  CourseRepository.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift

typealias StudentOverview = (totalPoints: Double, finalGrade: String)

protocol HasCourseRepository {
    var courseRepository: CourseRepositoryProtocol { get }
}

protocol CourseRepositoryProtocol {
    var course: Course? { get }
    var isFetching: BehaviorSubject<Bool> { get }
    var error: BehaviorSubject<Error?> { get }

    func set(course: Course)
    func classifications(forStudent: String) -> Observable<[Classification]>
    func groupedClassifications(forStudent: String) -> Observable<[GroupedClassification]>
    func overview(forStudent: String) -> Observable<StudentOverview>
}

final class CourseRepository: CourseRepositoryProtocol {
    typealias Dependencies = HasGradesAPI

    // MARK: Properties

    var course: Course?

    let isFetching = BehaviorSubject<Bool>(value: false)
    let error = BehaviorSubject<Error?>(value: nil)

    private let dependencies: Dependencies
    private let activityIndicator = ActivityIndicator()
    private let bag = DisposeBag()

    // MARK: initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        activityIndicator
            .distinctUntilChanged()
            .asObservable()
            .bind(to: isFetching)
            .disposed(by: bag)
    }

    func set(course: Course) {
        self.course = course
    }

    // MARK: methods

    func classifications(forStudent _: String) -> Observable<[Classification]> {
        // TODO:
        return Observable.empty()
    }

    func groupedClassifications(forStudent _: String) -> Observable<[GroupedClassification]> {
        // TODO:
        return Observable.empty()
    }

    func overview(forStudent _: String) -> Observable<StudentOverview> {
        // TODO:
        return Observable.empty()
    }

    /// Fetch course detail and student classification, merge and bind as CourseStudent
//    private func getCourseDetail() {
//        let coursesSubscription = dependencies.gradesApi.getCourseStudentClassification(username: username, code: courseDetail.code)
//            .trackActivity(activityIndicator)
//            .share()
//
//        coursesSubscription
//            .bind(to: course)
//            .disposed(by: bag)
//
//        coursesSubscription
//            .map { $0.classifications }
//            .map(groupClassifications)
//            .subscribe(onNext: { [weak self] in
//                self?.groupedClassifications.onNext($0)
//            })
//            .disposed(by: bag)
//    }

    /// Groups classifications by their root parent classification
    private func groupClassifications(classifications: [Classification]) -> [GroupedClassification] {
        let childs = classifications.filter { $0.parentId != nil }
        var groups = classifications
            .filter { $0.parentId == nil }
            .map { GroupedClassification(fromClassification: $0) }

        for item in childs {
            let rootId = findRootClassification(forChild: item, inClassifications: classifications)
            let rootIndex = groups.firstIndex { $0.id == rootId }
            groups[rootIndex!].items.append(item)
        }

        return groups
    }

    /**
     Finds root classification for given classification
     - Classifications can be deeply nested. Expects all items are in collection.
     - returns: id of root classification
     */
    private func findRootClassification(forChild child: Classification, inClassifications items: [Classification]) -> Int {
        if let parentId = child.parentId {
            let parent = items.first { $0.id == parentId }! // element must be in the array
            return findRootClassification(forChild: parent, inClassifications: items)
        } else {
            return child.id // Found parent
        }
    }
}
