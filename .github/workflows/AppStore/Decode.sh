#!/bin/bash

# XCConfig
rm -rf XCConfig
gpg -d -o "$DECRYPTED_XCCONFIG_PATH" --pinentry-mode=loopback --passphrase "$XCCONFIG_SECRET" "$ENCRYPTED_XCCONFIG_PATH"
unzip XCConfig.zip
rm -rf XCConfig.zip

# GoogleService-Info.plist
gpg -d -o "$DECRYPTED_IOS_GOOGLE_SERVICE_PLIST_PATH" --pinentry-mode=loopback --passphrase "$IOS_GOOGLE_SERVICE_PLIST_SECRET" "$ENCRYPTED_IOS_GOOGLE_SERVICE_PLIST_PATH"

# Provisioning Profile
gpg -d -o "$DECRYPTED_STAGE_PROVISION_PATH" --pinentry-mode=loopback --passphrase "$STAGE_PROVISION_SECRET" "$ENCRYPTED_STAGE_PROVISION_PATH"
unzip Tuist/Signing/StageProvisionProfile.zip -d Tuist/Signing
mv -v Tuist/Signing/StageProvisionProfile/* Tuist/Signing/

gpg -d -o "$DECRYPTED_PROD_PROVISION_PATH" --pinentry-mode=loopback --passphrase "$PROD_PROVISION_SECRET" "$ENCRYPTED_PROD_PROVISION_PATH"
unzip Tuist/Signing/ProdProvisionProfile.zip -d Tuist/Signing
mv -v Tuist/Signing/ProdProvisionProfile/* Tuist/Signing/

# master.key
gpg -d -o "$DECRYPTED_MASTER_KEY_PATH" --pinentry-mode=loopback --passphrase "$MASTER_KEY_SECRET" "$ENCRYPTED_MASTER_KEY_PATH"

# fastlane env
gpg -d -o "$DECRYPTED_FASTLANE_ENV_PATH" --pinentry-mode=loopback --passphrase "$FASTLANE_SECRET" "$ENCRYPTED_FASTLANE_ENV_PATH"

# AppStore Connect API Key
gpg -d -o "$DECRYPTED_APPSTORE_CONNECT_PATH" --pinentry-mode=loopback --passphrase "$APPSTORE_CONNECT_SECRET" "$ENCRYPTED_APPSTORE_CONNECT_PATH"