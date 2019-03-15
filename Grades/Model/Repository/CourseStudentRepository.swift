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
    var course: BehaviorRelay<CourseStudent?> { get }
}

class CourseStudentRepository: CourseStudentRepositoryProtocol {
    private let gradesApi: GradesAPIProtocol
    private let bag = DisposeBag()

    let code: String
    let name: String?

    var course = BehaviorRelay<CourseStudent?>(value: nil)
    var groupedClassifications = BehaviorSubject<[GroupedClassification]>(value: [])
    lazy var error = BehaviorSubject<Error?>(value: nil)

    init(username: String, code: String, name: String?, gradesApi: GradesAPIProtocol) {
        self.code = code
        self.name = name
        self.gradesApi = gradesApi

        getCourseDetail(username: username, courseCode: code)
    }

    // MARK: methods

    /// Fetch course detail and student classification, merge and bind as CourseStudent
    private func getCourseDetail(username: String, courseCode: String) {
        let coursesSubscription = gradesApi.getCourseStudentClassification(username: username, code: courseCode).share()

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

        coursesSubscription
            .monitorLoading()
            .errors()
            .bind(to: error)
            .disposed(by: bag)
    }

    /// Groups classifications by their root parent classification
    private func groupClassifications(classifications: [Classification]) -> [GroupedClassification] {
        let childs = classifications.filter { $0.parentId != nil }
        var groups = classifications
            .filter { $0.parentId == nil }
            .map { GroupedClassification(id: $0.id, header: $0.getLocalizedText(), totalValue: $0.value, items: []) }

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
