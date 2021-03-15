# Grades iOS
[![Build Status](https://travis-ci.com/jstorm31/grades-ios.svg?branch=master)](https://travis-ci.com/jstorm31/grades-ios)
![Swift](https://img.shields.io/badge/Swift-5.3-orange.svg)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

<p align="center">
  <img height="150" src="grades_logo.png">
</p>

Client iOS application for [student evaluation management server](https://grades.fit.cvut.cz/) at Faculty of Information Technologies, Czech Technical University in Prague.

## 🛠 Setup
1. Clone the repository.
2. Request access to configuration files encrypted with [git-secret](https://git-scm.com) from the repository owner.

## 🔗 Dependency management
The app uses Swift Package Manager for dependency management. In XCode 12+ the packages should be installed automatically.

Additionally, you should have following frameworks installed system-wide:

 * [SwiftLint](https://github.com/realm/SwiftLint)
 * [SwiftGen](https://github.com/SwiftGen/SwiftGen)
 * [SwiftFormat](https://github.com/nicklockwood/SwiftFormat)

## ⚙️ Configuration
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
 3. Add `ENVIRONMENT_NAME.plist` file (replace `ENVIRONMENT_NAME` it with real environment name)
 4. `EnvironmentConfiguration` class may need update
 
 ## 📦 Deploy
 
The app is deployed manually through AppStore Connect.

### AppStore review

In order to allow a review of the app before a new release, a version must be set (matching the new release version) in a remote configuration file (hosted by the project maintainer). That version will than have all in-app data mocked instead of real data. **It is important to change the version in the configuration file** after the review has been completed so real data are fetched to regular users.
