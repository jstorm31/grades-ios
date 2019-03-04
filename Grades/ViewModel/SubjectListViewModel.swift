//
//  SubjectList.swift
//  Grades
//
//  Created by Jiří Zdvomka on 04/03/2019.
//  Copyright © 2019 jiri.zdovmka. All rights reserved.
//

import Foundation
import RxSwift

struct SubjectListViewModel {
    var user: Observable<User> {
        return GradesAPI.getUser()
    }

    var subjects: Observable<[Subject]> {
        return GradesAPI.getSubjects()
    }
}
