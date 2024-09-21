fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### sync_certificates

```sh
[bundle exec] fastlane sync_certificates
```

Match를 사용하여 인증서와 프로비저닝 프로파일 동기화

----


## iOS

### ios testflight_release

```sh
[bundle exec] fastlane ios testflight_release
```

테스트플라이트에 최신코드의 오늘뭐임 iOS앱을 올려요

### ios appstore_release

```sh
[bundle exec] fastlane ios appstore_release
```

앱스토어에 오늘뭐임 iOS앱의 새로운 버전 심사를 올려요

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
