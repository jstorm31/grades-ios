//
//  CourseRepository.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import RxSwift

typealias StudentOverview = (totalPoints: Double?, finalGrade: String?)

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

    @discardableResult
    func classifications(forStudent username: String) -> Observable<[Classification]> {
        guard let course = course else { return Observable.just([]) }
        return dependencies.gradesApi.getCourseStudentClassification(username: username, code: course.code)
            .trackActivity(activityIndicator)
            .catchError { [weak self] error in
                if let `self` = self {
                    self.error.onNext(error)
                }
                return Observable.just([])
            }
    }

    @discardableResult
    func groupedClassifications(forStudent username: String) -> Observable<[GroupedClassification]> {
        return classifications(forStudent: username).map(groupClassifications)
    }

    @discardableResult
    func overview(forStudent username: String) -> Observable<StudentOverview> {
        let classifications = self.classifications(forStudent: username).share()

        let pointsTotal = classifications
            .map { $0.first { $0.type == ClassificationType.pointsTotal.rawValue } ?? nil }
            .unwrap()
            .map { (item: Classification) -> Double? in
                guard let value = item.value else { return nil }

                switch value {
                case let .number(number):
                    return number
                default:
                    return nil
                }
            }

        let finalGrade = classifications
            .map { $0.first { $0.type == ClassificationType.finalScore.rawValue } ?? nil }
            .unwrap()
            .map { (item: Classification) -> String? in
                guard let value = item.value else { return nil }

                switch value {
                case let .string(string):
                    return string
                default:
                    return nil
                }
            }

        return Observable.zip(pointsTotal, finalGrade) { (totalPoints: $0, finalGrade: $1) }
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
