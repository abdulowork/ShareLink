#!/bin/bash

set -ueo pipefail

APP_IDENTITY_PATH=$RUNNER_TEMP/app_identity.p12
FINDER_EXTENSION_IDENTITY_PATH=$RUNNER_TEMP/finder_extension_identity.p12
PKG_IDENTITY_PATH=$RUNNER_TEMP/pkg_identity.p12
APP_PROVISIONING_PROFILE_PATH=$RUNNER_TEMP/app.provisionprofile
FINDER_EXTENSION_PROVISIONING_PROFILE_PATH=$RUNNER_TEMP/finder_extension.provisionprofile
KEYCHAIN_PATH=$RUNNER_TEMP/app-signing.keychain-db
NOTARIZATION_KEY_PATH=$RUNNER_TEMP/notarization_key

APP_IDENTITY_SHA=abff0bcfc75d3be67107129cd0760e03fb87fc22
PKG_IDENTITY_SHA=3cc9a73e6eb08b26291e64e8d8e5933134184c3e

echo -n "$APP_SIGNING_IDENTITY" | base64 --decode -o "$APP_IDENTITY_PATH"
echo -n "$APP_PROVISIONING_PROFILE" | base64 --decode -o "$APP_PROVISIONING_PROFILE_PATH"
echo -n "$FINDER_EXTENSION_SIGNING_IDENTITY" | base64 --decode -o "$FINDER_EXTENSION_IDENTITY_PATH"
echo -n "$FINDER_EXTENSION_PROVISIONING_PROFILE" | base64 --decode -o "$FINDER_EXTENSION_PROVISIONING_PROFILE_PATH"
echo -n "$PKG_SIGNING_IDENTITY" | base64 --decode -o "$PKG_IDENTITY_PATH"
echo -n "$NOTARIZATION_KEY" | base64 --decode -o "$NOTARIZATION_KEY_PATH"

security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

security import "$APP_IDENTITY_PATH" -P "$APP_SIGNING_IDENTITY_PASSWORD" -A -t cert -f pkcs12 -k "$KEYCHAIN_PATH"
security import "$FINDER_EXTENSION_IDENTITY_PATH" -P "$FINDER_EXTENSION_SIGNING_IDENTITY_PASSWORD" -A -t cert -f pkcs12 -k "$KEYCHAIN_PATH"
security import "$PKG_IDENTITY_PATH" -P "$PKG_SIGNING_IDENTITY_PASSWORD" -A -t cert -f pkcs12 -k "$KEYCHAIN_PATH"
security list-keychains -d user | xargs security list-keychains -d user -s "$KEYCHAIN_PATH"
security set-key-partition-list -S apple-tool:,apple: -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

ARCHIVE_NAME=output

# Archive the .app
xcodebuild archive -DVTProvisioningProfileSearchPath="$RUNNER_TEMP" -project ShareLink.xcodeproj -scheme ShareLink -destination 'generic/platform=macOS' -archivePath "$ARCHIVE_NAME" CODE_SIGN_IDENTITY="$APP_IDENTITY_SHA" OTHER_CODE_SIGN_FLAGS="--keychain $KEYCHAIN_PATH"

# Create the .pkg
DISTRIBUTION_NAME=Distribution.pkg
DISTRIBUTION_XML=Distribution.xml
OUTPUT_PKG=ShareLink.pkg
pkgbuild --root "$ARCHIVE_NAME".xcarchive/Products/Applications/ShareLink.app --identifier com.tssolonin.ShareLink.FinderExtension --sign "$PKG_IDENTITY_SHA" --keychain "$KEYCHAIN_PATH" --scripts Scripts --install-location "/Applications/ShareLink.app" "$DISTRIBUTION_NAME"
productbuild --synthesize --package "$DISTRIBUTION_NAME" "$DISTRIBUTION_XML"
productbuild --distribution "$DISTRIBUTION_XML" --sign "$PKG_IDENTITY_SHA" --package-path . "$OUTPUT_PKG"

# Notarize
xcrun notarytool submit --issuer "$NOTARIZATION_ISSUER" --key-id "$NOTARIZATION_KEY_ID" --key "$NOTARIZATION_KEY_PATH" --wait "$OUTPUT_PKG"
xcrun stapler staple "$OUTPUT_PKG"
