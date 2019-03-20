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

    internal enum Button {
        /// Cancel
        internal static let cancel = L10n.tr("Localizable", "button.cancel")
        /// Done
        internal static let done = L10n.tr("Localizable", "button.done")
        /// Login
        internal static let login = L10n.tr("Localizable", "button.login")
    }

    internal enum Classification {
        /// Not rated
        internal static let notRated = L10n.tr("Localizable", "classification.notRated")
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
            /// There has been an error when trying to fetch data.
            internal static let generic = L10n.tr("Localizable", "error.api.generic")
        }

        internal enum Auth {
            /// There has been an error when authenticating.
            internal static let generic = L10n.tr("Localizable", "error.auth.generic")
        }
    }

    internal enum Settings {
        /// Language
        internal static let language = L10n.tr("Localizable", "settings.language")
        /// Log out
        internal static let logout = L10n.tr("Localizable", "settings.logout")
        /// Options
        internal static let options = L10n.tr("Localizable", "settings.options")
        /// Semester
        internal static let semester = L10n.tr("Localizable", "settings.semester")
        /// Settings
        internal static let title = L10n.tr("Localizable", "settings.title")
        /// User
        internal static let user = L10n.tr("Localizable", "settings.user")
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
