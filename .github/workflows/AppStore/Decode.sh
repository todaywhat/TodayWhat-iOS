#!/bin/bash

# XCConfig
rm -rf XCConfig
gpg -d -o "$DECRYPTED_XCCONFIG_PATH" --pinentry-mode=loopback --passphrase "$XCCONFIG_SECRET" "$ENCRYPTED_XCCONFIG_PATH"
unzip XCConfig.zip
rm -rf XCConfig.zip

# GoogleService-Info.plist
gpg -d -o "$DECRYPTED_IOS_GOOGLE_SERVICE_PLIST_PATH" --pinentry-mode=loopback --passphrase "$IOS_GOOGLE_SERVICE_PLIST_SECRET" "$ENCRYPTED_IOS_GOOGLE_SERVICE_PLIST_PATH"

# fastlane env
gpg -d -o "$DECRYPTED_FASTLANE_ENV_PATH" --pinentry-mode=loopback --passphrase "$FASTLANE_SECRET" "$ENCRYPTED_FASTLANE_ENV_PATH"

# AppStore Connect API Key
gpg -d -o "$DECRYPTED_APPSTORE_CONNECT_PATH" --pinentry-mode=loopback --passphrase "$APPSTORE_CONNECT_SECRET" "$ENCRYPTED_APPSTORE_CONNECT_PATH"