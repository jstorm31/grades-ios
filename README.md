# Grades iOS
Client mobile application for [grading server](https://grades.fit.cvut.cz/) on FIT CTU running on iOS platform.

## Dependency management
The app uses [Carthage](https://github.com/Carthage/Carthage) package manager for dependency management. After cloning the repo, run `carthage bootstrap` to correctly install required frameworks.

Additionally, you should have following frameworks installed system-wide:

 * [SwiftLint](https://github.com/realm/SwiftLint)
 * [SwiftGen](https://github.com/SwiftGen/SwiftGen)

## Configuration
All configuration related files are located in `Configuration` folder. There are two files:
 * `config.plist` - all configuration for different environments and common configuration
 * `EnvironmentConfiguration` - class for extraction configuration from `config.plist` and providing strongly typed interface

 ### Adding value
 1. Add key and value to `config.plist` to common or any environment
 2. Provide new strongly typed variable in `EnvironmentConfiguration` extension

 ### Adding environment
 1. Add environment in your project info
 2. Add correct string to `$(CONFIG_ENVIRONMENT)` in app's build settings
 3. Add environment dictionary to root key of `config.plist` file
