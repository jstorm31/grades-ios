// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
    /// App version
    internal static let appVersion = L10n.tr("Localizable", "appVersion")

    internal enum About {
        /// This app has been developed by Jiří Zdvomka at Faculty of Information Technology, Czech Technical University in Prague as his Bachelor's Thesis.
        internal static let text = L10n.tr("Localizable", "about.text")
        /// Credits
        internal static let title = L10n.tr("Localizable", "about.title")
    }

    internal enum Button {
        /// Cancel
        internal static let cancel = L10n.tr("Localizable", "button.cancel")
        /// Yes
        internal static let confirm = L10n.tr("Localizable", "button.confirm")
        /// Done
        internal static let done = L10n.tr("Localizable", "button.done")
        /// Log in
        internal static let login = L10n.tr("Localizable", "button.login")
        /// Privacy policy
        internal static let privacy = L10n.tr("Localizable", "button.privacy")
    }

    internal enum Classification {
        /// Not rated
        internal static let notRated = L10n.tr("Localizable", "classification.notRated")
        /// Other
        internal static let other = L10n.tr("Localizable", "classification.other")
        /// Total
        internal static let total = L10n.tr("Localizable", "classification.total")
    }

    internal enum Courses {
        /// Fetching courses
        internal static let fetching = L10n.tr("Localizable", "courses.fetching")
        /// p
        internal static let points = L10n.tr("Localizable", "courses.points")
        /// Studying
        internal static let studying = L10n.tr("Localizable", "courses.studying")
        /// Teaching
        internal static let teaching = L10n.tr("Localizable", "courses.teaching")
        /// Courses
        internal static let title = L10n.tr("Localizable", "courses.title")
    }

    internal enum Error {
        internal enum Api {
            /// Fetch data error
            internal static let generic = L10n.tr("Localizable", "error.api.generic")
        }

        internal enum Auth {
            /// Authentication error
            internal static let generic = L10n.tr("Localizable", "error.auth.generic")
        }
    }

    internal enum Labels {
        /// Nothing to display
        internal static let noContent = L10n.tr("Localizable", "labels.noContent")
    }

    internal enum License {
        /// Copyright [2019] [FIT CTU in Prague]\n\nLicensed under the Apache License, Version 2.0 (the 'License');\nyou may not use this file except in compliance with the License.\nYou may obtain a copy of the License at\n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software\ndistributed under the License is distributed on an 'AS IS' BASIS,\nWITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\nSee the License for the specific language governing permissions and\nlimitations under the License.
        internal static let text = L10n.tr("Localizable", "license.text")
        /// License
        internal static let title = L10n.tr("Localizable", "license.title")
    }

    internal enum Notification {
        /// Grade change
        internal static let studentClassificationChange = L10n.tr("Localizable", "notification.StudentClassificationChange")
        /// New notification
        internal static let title = L10n.tr("Localizable", "notification.title")
        internal enum Request {
            ///
            internal static let body = L10n.tr("Localizable", "notification.request.body")
            ///
            internal static let cancel = L10n.tr("Localizable", "notification.request.cancel")
            ///
            internal static let confirm = L10n.tr("Localizable", "notification.request.confirm")
            ///
            internal static let title = L10n.tr("Localizable", "notification.request.title")
        }
    }

    internal enum Settings {
        /// Credits
        internal static let about = L10n.tr("Localizable", "settings.about")
        /// Language
        internal static let language = L10n.tr("Localizable", "settings.language")
        /// License
        internal static let license = L10n.tr("Localizable", "settings.license")
        /// Log out
        internal static let logout = L10n.tr("Localizable", "settings.logout")
        /// Do you really wish to logout?
        internal static let logoutConfirmTitle = L10n.tr("Localizable", "settings.logoutConfirmTitle")
        /// Options
        internal static let options = L10n.tr("Localizable", "settings.options")
        /// Other
        internal static let other = L10n.tr("Localizable", "settings.other")
        /// Semester
        internal static let semester = L10n.tr("Localizable", "settings.semester")
        /// Settings
        internal static let title = L10n.tr("Localizable", "settings.title")
        /// User
        internal static let user = L10n.tr("Localizable", "settings.user")
        internal enum User {
            /// Name
            internal static let name = L10n.tr("Localizable", "settings.user.name")
            /// Roles
            internal static let roles = L10n.tr("Localizable", "settings.user.roles")
        }
    }

    internal enum Sorter {
        /// Name
        internal static let name = L10n.tr("Localizable", "sorter.name")
        /// Sort by:
        internal static let title = L10n.tr("Localizable", "sorter.title")
        /// Value
        internal static let value = L10n.tr("Localizable", "sorter.value")
    }

    internal enum Students {
        /// Search student
        internal static let search = L10n.tr("Localizable", "students.search")
        /// Students
        internal static let title = L10n.tr("Localizable", "students.title")
        /// Grades have been successfully updated.
        internal static let updateSuccess = L10n.tr("Localizable", "students.updateSuccess")
    }

    internal enum Teacher {
        internal enum Group {
            /// Students
            internal static let students = L10n.tr("Localizable", "teacher.group.students")
        }

        internal enum Students {
            /// Change
            internal static let changeButton = L10n.tr("Localizable", "teacher.students.changeButton")
            /// Evaluation item
            internal static let classification = L10n.tr("Localizable", "teacher.students.classification")
            /// Final grade not specified
            internal static let finalGradeEmpty = L10n.tr("Localizable", "teacher.students.finalGradeEmpty")
            /// Evaluation items
            internal static let grading = L10n.tr("Localizable", "teacher.students.grading")
            /// Group
            internal static let group = L10n.tr("Localizable", "teacher.students.group")
            /// Student
            internal static let title = L10n.tr("Localizable", "teacher.students.title")
        }

        internal enum Tab {
            /// Detail
            internal static let group = L10n.tr("Localizable", "teacher.tab.group")
            /// Student
            internal static let student = L10n.tr("Localizable", "teacher.tab.student")
        }
    }

    internal enum UserRoles {
        /// student
        internal static let student = L10n.tr("Localizable", "userRoles.student")
        /// teacher
        internal static let teacher = L10n.tr("Localizable", "userRoles.teacher")
    }
}

// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
    private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
        // swiftlint:disable:next nslocalizedstring_key
        let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
        return String(format: format, locale: Locale.current, arguments: args)
    }
}

private final class BundleToken {}
