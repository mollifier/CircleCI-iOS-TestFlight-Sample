#!/bin/bash

PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_UUID.mobileprovision"
RELEASE_DATE=$(date '+%Y-%m-%d %H:%M:%S')
ARCHIVE_PATH="$PWD/build.xcarchive"
APP_DIR="$ARCHIVE_PATH/Products/Applications"

echo "********************"
echo "*     Archive      *"
echo "********************"
xcodebuild -scheme "$XCODE_SCHEME" -workspace "$XCODE_WORKSPACE" -archivePath "$ARCHIVE_PATH" clean archive -configuration Release CODE_SIGN_IDENTITY="$DEVELOPER_NAME"

echo "********************"
echo "*     Signing      *"
echo "********************"
xcrun -log -sdk iphoneos PackageApplication "$APP_DIR/$APPNAME.app" -o "$APP_DIR/$APPNAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"

# deploy
./scripts/upload-ipa-to-deploygate.sh -u "$DEPLOYGATE_USER_NAME" -t "$DEPLOYGATE_API_TOKEN" -m "Build: ${CIRCLE_BUILD_NUM}, Uploaded: $RELEASE_DATE" "$APP_DIR/$APPNAME.ipa"

