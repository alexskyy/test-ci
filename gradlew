#!/bin/bash

set +x

echo $*

target=$1
build_path="app/build/outputs/apk"
prod_rel="$build_path/prod/release/"
dev_rel="$build_path/dev/release/"

if [[ $target == "assembleProdRelease" ]]; then
    if [ $BRANCH_TAG ]; then
        #BUILD_TRACK=""
        #BUILD_TARGET="assembleProdRelease"
	mkdir -p $prod_rel
	touch "$prod_rel/prodRelease-5.2.4.500.apk"
    else
        #BUILD_TRACK="DigOps.Dev"
        #BUILD_TARGET="assembleDevRelease"
	mkdir -p $dev_rel
        touch "$dev_rel/devRelease-5.2.4.5000DigOps.Dev.apk"
    fi
elif [[ $BRANCH == "develop" ]]; then
    if [ $BRANCH_TAG ]; then
        #BUILD_TRACK="Innovation.Sprint"
        #BUILD_TARGET="assembleProdRelease"
	mkdir -p $prod_rel
        touch "$prod_rel/prodRelease-5.2.4.5000Innovation.Sprint.apk"
    else
        #BUILD_TRACK="Innovation.Dev"
        #BUILD_TARGET="as$sembleDevRelease"
	mkdir -p $dev_rel
        touch "$dev_rel/devRelease-5.2.4.5000Innovation.Dev.apk"
    fi
else
    #BUILD_TRACK="Debug"
    #BUILD_TARGET="assembleDevDebug"

    mkdir -p $dev_rel
    touch "$dev_rel/devDebug-5.2.4.5000Debug.apk"
fi
