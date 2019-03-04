//
//  SubjectList.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxSwift

class SubjectListViewModel {
    func fetchUser() -> Observable<User> {
        return GradesAPI.getUser()
    }

    func fetchSubjects() -> Observable<[Subject]> {
        return GradesAPI.getSubjects()
    }
}
