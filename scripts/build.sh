#!/bin/bash
set +x

if [[ $CIRCLECI == "true" ]]; then
    echo "$0: CircleCI detected"

    PULL_REQUEST=$CIRCLE_PULL_REQUEST
    BRANCH=$CIRCLE_BRANCH
    BRANCH_TAG=$CIRCLE_TAG
    BUILD_NUMBER=$(($CIRCLE_BUILD_NUM + 5000))
else
    echo "$0: No CI system detected"

    PULL_REQUEST="false"
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    BUILD_NUMBER=9999
fi

#### BUILD
BUILD_FLAGS="-PdisablePreDex -xlint --no-daemon"

if [[ $BRANCH == "master" ]]; then
    if [ $BRANCH_TAG ]; then
        BUILD_TRACK=""
        BUILD_TARGET="assembleProdRelease"
    else
        BUILD_TRACK="DigOps.Dev"
        BUILD_TARGET="assembleDevRelease"
    fi
elif [[ $BRANCH == "develop" ]]; then
    if [ $BRANCH_TAG ]; then
        BUILD_TRACK="Innovation.Sprint"
        BUILD_TARGET="assembleProdRelease"
    else
        BUILD_TRACK="Innovation.Dev"
        BUILD_TARGET="assembleDevRelease"
    fi
else
    BUILD_TRACK="Debug"
    BUILD_TARGET="assembleDevDebug"
fi

echo "$0: Building $BUILD_TRACK on $BRANCH "
export BUILD_NUMBER=$BUILD_NUMBER && export BUILD_SUFFIX=$BUILD_TRACK && ./gradlew $BUILD_TARGET $BUILD_FLAGS
exit $?
