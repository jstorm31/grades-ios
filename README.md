# Grades iOS
Client mobile application for [grading server](https://grades.fit.cvut.cz/) on FIT CTU running on iOS platform.

## Dependency management
The app uses [Carthage](https://github.com/Carthage/Carthage) package manager for dependency management. After cloning the repo, run `carthage bootstrap` to correctly install required frameworks.

Additionally, you should have following frameworks installed system-wide:

 * [SwiftLint](https://github.com/realm/SwiftLint)
 * [SwiftGen](https://github.com/SwiftGen/SwiftGen)
 * [SwiftFormat](https://github.com/nicklockwood/SwiftFormat)

## Configuration
All configuration related files are located in `Configuration` folder. There are several files:
 * `.plist` files - all configuration for different environments (one file for each) and common configuration
 * `EnvironmentConfiguration` - class for extracting configuration from `.plist` files and providing strongly typed interface

 > **Important note**: All `plist` files are not checked to the repository, but are encrypted and stored in `.gitsecret` folder. This is achieved by [git-secret tool](https://git-secret.io/). Only validated contributors with gpg RSA key-pair can access these files.

 ### Adding a value
 1. Add key and value to `plist` file (common or any environment)
 2. Provide new strongly typed variable in `EnvironmentConfiguration` extension

 ### Adding an environment
 1. Add environment in your project info
 2. Add correct string to `$(CONFIG_ENVIRONMENT)` in app's build settings
 3. Add `environment.plist` file
 4. `EnvironmentConfiguration` class may need update
