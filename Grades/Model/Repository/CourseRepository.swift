//
//  CourseRepository.swift
//  Grades
//
//  Created by Jiří Zdvomka on 13/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxSwift

typealias StudentOverview = (totalPoints: Double?, finalGrade: String?)
typealias CategorizedClassifications = ([Classification], [Classification], [Classification])

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
    typealias Dependencies = HasGradesAPI & HasSettingsRepository

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
        guard let course = course else {
            Log.info("Course is not set, emitting []")
            return Observable.just([])
        }

        #if DEBUG
            // Return mock data in Debug
            // swiftlint:disable force_cast
            if let environment = Bundle.main.infoDictionary!["ConfigEnvironment"], (environment as! String) == "Debug" {
                // swiftlint:disable line_length
                return Observable<[Classification]>.just([
                    Classification(id: 1, identifier: "1", text: [ClassificationText(identifier: "1", name: "Assignment 1")], evaluationType: .manual, type: "number", valueType: .number, value: .number(22.5), parentId: nil, isHidden: false),
                    Classification(id: 2, identifier: "2", text: [ClassificationText(identifier: "1", name: "Assignment 2")], evaluationType: .manual, type: "number", valueType: .number, value: nil, parentId: nil, isHidden: false)
                ]).delaySubscription(.seconds(1), scheduler: MainScheduler.instance)
            }
        #endif

        return dependencies.gradesApi.getCourseStudentClassification(username: username, code: course.code)
            .map { [weak self] classifications in
                if let hidden = self?.dependencies.settingsRepository.currentSettings.value.undefinedEvaluationHidden, hidden == true {
                    return classifications.filter { $0.isDefined }
                }
                return classifications
            }
            .trackActivity(activityIndicator)
            .catchError { [weak self] error in
                if let self = self {
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
        #if DEBUG
            if let environment = Bundle.main.infoDictionary!["ConfigEnvironment"], (environment as! String) == "Debug" {
                return Observable<StudentOverview>.just((22.5, "D")).delaySubscription(.seconds(1), scheduler: MainScheduler.instance)
            }
        #endif

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
        let (parents, childs, childless) = categorizeItems(classifications)
        var groups = parents.map { GroupedClassification(fromClassification: $0) }

        if !childless.isEmpty {
            // Add group of childless classifications at the beginning
            groups.append(GroupedClassification(fromClassification: nil, items: childless))
        }

        for item in childs {
            let rootId = findRootClassification(forChild: item, inClassifications: classifications)
            let rootIndex = groups.firstIndex { $0.id == rootId }
            groups[rootIndex!].items.append(item)
        }

        return groups
    }

    /**
     Filters out items with childs
     - Returns array of items that has no childs
     */
    private func categorizeItems(_ classifications: [Classification]) -> CategorizedClassifications {
        let parentCandidates = classifications.filter { $0.parentId == nil }
        let childs = classifications.filter { $0.parentId != nil }
        var parents = [Classification]()
        var childless = [Classification]()

        for candidate in parentCandidates {
            var hasChild = false

            for child in childs {
                let parentId = findRootClassification(forChild: child, inClassifications: classifications)
                if parentId == candidate.id {
                    hasChild = true
                    break
                }
            }

            if hasChild {
                parents.append(candidate)
            } else {
                childless.append(candidate)
            }
        }

        return (parents, childs, childless)
    }

    /**
     Finds root classification for given classification
     - Classifications can be deeply nested. Expects all items are in collection.
     - returns: id of root classification
     */
    private func findRootClassification(forChild child: Classification, inClassifications items: [Classification]) -> Int {
        if let parentId = child.parentId, let parent = items.first(where: { $0.id == parentId }) {
            return findRootClassification(forChild: parent, inClassifications: items)
        } else {
            return child.id // Found parent
        }
    }
}
