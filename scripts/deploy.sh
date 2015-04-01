#!/bin/bash

release_date=$(date '+%Y-%m-%d %H:%M:%S')
message="Build: ${CIRCLE_BUILD_NUM}, Uploaded: $release_date"
output_path="$PWD/build"

./scripts/build-ipa.sh \
    -d "$DEVELOPER_NAME" -a "$APPNAME" \
    -p "$PROFILE_NAME" -s "$XCODE_SCHEME" -w "$XCODE_WORKSPACE" \
    -o "$output_path"

./scripts/upload-ipa-to-deploygate.sh \
    -u "$DEPLOYGATE_USER_NAME" -t "$DEPLOYGATE_API_TOKEN" -m "$message"
    "${output_path}/${APPNAME}.ipa"

