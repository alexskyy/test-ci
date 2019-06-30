#!/bin/bash

#set +x

echo $*
echo $BUILD_SUFFIX

target=$1
build_path="CbyGE/app/build/outputs/apk"
prod_rel="$build_path/prod/release/"
dev_rel="$build_path/dev/release/"

        def buildSuffix = System.getenv("BUILD_SUFFIX")
        if (buildSuffix == null) {
            echo "applicationIdSuffix=Debug"
        } else if (buildSuffix == "DigOps.Release") {
            echo "applicationIdSuffix=none"
        } else {
            echo "applicationIdSuffix=$buildSuffix"
        }

echo "CopyFile google-services/google-services.json$buildSuffix"
if [[ $target == "assembleProdRelease" ]]; then
	mkdir -p $prod_rel
	touch "$prod_rel/prodRelease-5.2.4.5000$BUILD_SUFFIX.apk"
elif [[ $target == "assembleDevRelease" ]]; then
	mkdir -p $dev_rel
    touch "$dev_rel/devRelease-5.2.4.5000$BUILD_SUFFIX.apk"
else
    mkdir -p $dev_rel
    touch "$dev_rel/devDebug-5.2.4.5000Debug.apk"
fi
