fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios clean
```
fastlane ios clean
```
Clean all files before build (deletes derived data)
### ios register
```
fastlane ios register
```
Register new development device to provisioning profile (prompts name and UUID)
### ios version_set
```
fastlane ios version_set
```
Clean all files before build (deletes derived data)
### ios create_default_keychain
```
fastlane ios create_default_keychain
```

### ios unlock_default_keychain
```
fastlane ios unlock_default_keychain
```

### ios delete_default_keychain
```
fastlane ios delete_default_keychain
```

### ios certificates
```
fastlane ios certificates
```
Update certificates (readonly): scheme:{development, appstore, adhoc}
### ios refresh_profiles
```
fastlane ios refresh_profiles
```
Update certificates for all schemes (development, appstore, adhoc)
### ios info
```
fastlane ios info
```
Prints information (like version ...) about project
### ios build
```
fastlane ios build
```
Build aplication scheme:{development, appstore, adhoc}
### ios build_only
```
fastlane ios build_only
```
Only build a project
### ios setup_apple_login
```
fastlane ios setup_apple_login
```
Setup Apple Two-factor Auth
### ios deploy_crashlytics
```
fastlane ios deploy_crashlytics
```
Deploy application to crashlytics
### ios deploy_pilot
```
fastlane ios deploy_pilot
```
Deploy application to pilot
### ios deploy_appstore
```
fastlane ios deploy_appstore
```
Deploy application to appstore
### ios release
```
fastlane ios release
```
Release app (runs deploy_appstore)
### ios lint
```
fastlane ios lint
```
Run swiftlint
### ios test
```
fastlane ios test
```
Run all tests (scan command). UNIT and UI
### ios snapshots
```
fastlane ios snapshots
```
Run UI test and create snapshots (saves images o google drive)
### ios post_deploy_to_slack
```
fastlane ios post_deploy_to_slack
```
Post to 2N slack into app_monitoring channel
### ios ci_crashlytics
```
fastlane ios ci_crashlytics
```
CI - Build and upload to crashlytics
### ios ci_testflight
```
fastlane ios ci_testflight
```
CI - Build and upload to testflight
### ios ci_appstore
```
fastlane ios ci_appstore
```
CI - Build and upload to testflight
### ios ci_nightbuild
```
fastlane ios ci_nightbuild
```
CI nightbuild

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
