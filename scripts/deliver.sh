#!/bin/bash

# Scans the path in $1 for versionName and writes that to stdout.
function versionNameDeclaredInGradlefile() {
    local buildDotGradle=$1

    egrep --only-matching \
    'versionName\s+["'\''][^"'\'']+["'\'']' \
    "$buildDotGradle" |
    # Convert single-quotes to double-quotes so we have a known delimiter
    tr \' \"  |
    # Text is now `versionName "something"`, so treat " as field delimiter
    # and snag field 2, which gives us `something`.
    cut -d\" -f2
}

set +x

if [[ $CIRCLECI == "true" ]]; then
    echo "Setting CircleCI build variables"
    PULL_REQUEST=$CIRCLE_PULL_REQUEST
    BRANCH=$CIRCLE_BRANCH
    BUILD_NUMBER=$(($CIRCLE_BUILD_NUM + 5000))
else
    echo "Local build, nothing to deliver"
    exit $?
fi

VERSION_NAME=$(versionNameDeclaredInGradlefile "CbyGE/app/build.gradle")

OUTPUTDIR=$PWD/app/build/outputs/apk
DIGIOPS_DEV_APK="DigOps.Dev.apk"
DIGIOPS_REL_APK=".apk"
INNOVATION_DEV_APK="Innovation.Dev.apk"
INNOVATION_REL_APK="Innovation.Sprint.apk"
DEBUG_PATH="/dev/release/devRelease-$VERSION_NAME.$BUILD_NUMBER"
PROD_PATH="/prod/release/prodRelease-$VERSION_NAME.$BUILD_NUMBER"

RELEASE_NOTES="($BRANCH): $NUMBER"

echo -e "Release notes:\n$RELEASE_NOTES"

echo "Searching build $VERSION_NAME.$BUILD_NUMBER .. "

echo "Contents of $OUTPUTDIR:"
ls -lR $OUTPUTDIR

# Upload Dev
if [ -f $OUTPUTDIR/$DEBUG_PATH$INNOVATION_DEV_APK ]; then
    FULL_APP_PATH="$OUTPUTDIR/$DEBUG_PATH$INNOVATION_DEV_APK"
    API_TOKEN="$HOCKEYAPP_INNOVATION_DEV_API_TOKEN"
    APP_ID="$HOCKEYAPP_INNOVATION_DEV_APP_ID"
elif [ -f $OUTPUTDIR/$PROD_PATH$INNOVATION_REL_APK ]; then
    FULL_APP_PATH="$OUTPUTDIR/$PROD_PATH$INNOVATION_REL_APK"
    API_TOKEN="$HOCKEYAPP_INNOVATION_SPRINT_API_TOKEN"
    APP_ID="$HOCKEYAPP_INNOVATION_SPRINT_APP_ID"
elif [ -f "$OUTPUTDIR/$DEBUG_PATH$DIGIOPS_DEV_APK" ]; then
    FULL_APP_PATH="$OUTPUTDIR/$DEBUG_PATH$DIGIOPS_DEV_APK"
    API_TOKEN="$HOCKEYAPP_DIGOPS_DEV_API_TOKEN"
    APP_ID="$HOCKEYAPP_DIGOPS_DEV_APP_ID"
elif [ -f $OUTPUTDIR$PROD_PATH$DIGIOPS_REL_APK ]; then
    FULL_APP_PATH="$OUTPUTDIR/$PROD_PATH$DIGIOPS_REL_APK"
    API_TOKEN="$HOCKEYAPP_DIGOPS_RELEASE_API_TOKEN"
    APP_ID="$HOCKEYAPP_DIGOPS_RELEASE_APP_ID"
fi


if [ -e "$FULL_APP_PATH" ]; then
    echo "Uploading $FULL_APP_PATH to Hockeyapp."
    echo curl https://rink.hockeyapp.net/api/2/apps/$APP_ID/app_versions/upload \
            -H "X-HockeyAppToken: $API_TOKEN" \
            -F "ipa=@$FULL_APP_PATH" \
            -F "notes=$RELEASE_NOTES" \
            -F "notes_type=0" \
            -F "status=2"
else
    echo "Build apk was not found, not uploading"
fi
