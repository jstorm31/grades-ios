//
//  CourseRepository.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxCocoa
import RxSwift

protocol CourseStudentRepositoryProtocol {
    var code: String { get }
    var name: String? { get }

    var course: BehaviorRelay<CourseStudent?> { get }
    var groupedClassifications: BehaviorSubject<[GroupedClassification]> { get }
    var isFetching: BehaviorSubject<Bool> { get }
    var error: BehaviorSubject<Error?> { get }

    func bindOutput()
}

class CourseStudentRepository: CourseStudentRepositoryProtocol {
    private let gradesApi: GradesAPIProtocol
    private let activityIndicator = ActivityIndicator()
    private let bag = DisposeBag()
    private let username: String
    let code: String
    let name: String?

    let course = BehaviorRelay<CourseStudent?>(value: nil)
    let groupedClassifications = BehaviorSubject<[GroupedClassification]>(value: [])
    let isFetching = BehaviorSubject<Bool>(value: false)
    let error = BehaviorSubject<Error?>(value: nil)

    init(username: String, code: String, name: String?, gradesApi: GradesAPIProtocol) {
        self.username = username
        self.code = code
        self.name = name
        self.gradesApi = gradesApi

        activityIndicator
            .distinctUntilChanged()
            .asObservable()
            .bind(to: isFetching)
            .disposed(by: bag)
    }

    func bindOutput() {
        getCourseDetail(username: username, courseCode: code)
    }

    // MARK: methods

    /// Fetch course detail and student classification, merge and bind as CourseStudent
    private func getCourseDetail(username: String, courseCode: String) {
        let coursesSubscription = gradesApi.getCourseStudentClassification(username: username, code: courseCode)
            .trackActivity(activityIndicator)
            .share()

        coursesSubscription
            .bind(to: course)
            .disposed(by: bag)

        coursesSubscription
            .map { $0.classifications }
            .map(groupClassifications)
            .subscribe(onNext: { [weak self] in
                self?.groupedClassifications.onNext($0)
            })
            .disposed(by: bag)
    }

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
