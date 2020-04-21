#!/bin/bash

files=(source components fonts images manifest)

mkdir -p "../builds"

timestamp=$(date +%Y_%m_%d_%H_%M_%S)
folder="build_${timestamp}"
buildfolder="../builds/${folder}"
mkdir ${buildfolder}

if [ $? -ne 0 ]; then
    exit
fi

echo ${folder}

for f in "${files[@]}"; do
    cp -r "../$f" ${buildfolder}
done

# Delete RALE from build
find ${buildfolder} -name 'TrackerTask.xml' -delete

# Delete RALE & all comment lines from source code
find ${buildfolder} -name '*.brs' |
    while read filename; do
        sed -Ei "s/^\s*\?.*//g" "$filename"
        sed -Ei "s/^\s*print.*//gi" "$filename"
        sed -i '/#START TRACKER#/,/#END TRACKER#/{//!x}' "$filename"
    done

mkdir "${buildfolder}/out"
cd ${buildfolder}
zip -0 -qr "out/roku-deploy.zip" ${files[@]}
