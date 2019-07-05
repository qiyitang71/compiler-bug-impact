#!/bin/bash

if [ $# -ne 1 ]
  then
    echo "No arguments supplied. Usage is ./analyse-bug BUGID, e.g. ./analyse-bug 19636"
    exit 1
fi
bug_id=$1
if ! grep -q "^$bug_id$" bug_list; then
    echo "'$bug_id' is not a valid BUGID"
    exit 1
fi

declare -A bugs
bugs=( ["11964"]="https://gitlab.com/mmarcozz/buggy-compilers/raw/master/11964.zip" \
    ["12901"]="https://gitlab.com/mmarcozz/buggy-compilers/raw/master/12901.zip" \
    ["15959"]="https://gitlab.com/mmarcozz/buggy-compilers/raw/master/15959.zip" \
    ["20186"]="https://gitlab.com/mmarcozz/compiler-bugs-2/raw/master/20186.zip" \
    ["21255"]="https://gitlab.com/mmarcozz/compiler-bugs-2/raw/master/21255.zip" \
    ["25900"]="https://gitlab.com/mmarcozz/compiler-bugs-2/raw/master/25900.zip" \
    ["26734"]="https://gitlab.com/mmarcozz/compiler-bugs-3/raw/master/26734.zip" \
    ["28504"]="https://gitlab.com/mmarcozz/compiler-bugs-3/raw/master/28504.zip" \
    ["31808"]="https://gitlab.com/mmarcozz/compiler-bugs-4/blob/master/31808.zip" \
    ["11977"]="https://gitlab.com/mmarcozz/buggy-compilers/raw/master/11977.zip" \
    ["13326"]="https://gitlab.com/mmarcozz/buggy-compilers/raw/master/13326.zip" \
    ["17103"]="https://gitlab.com/mmarcozz/buggy-compilers/raw/master/17103.zip" \
    ["20189"]="https://gitlab.com/mmarcozz/compiler-bugs-2/raw/master/20189.zip" \
    ["21256"]="https://gitlab.com/mmarcozz/compiler-bugs-2/raw/master/21256.zip" \
    ["26266"]="https://gitlab.com/mmarcozz/compiler-bugs-2/raw/master/26266.zip" \
    ["27392"]="https://gitlab.com/mmarcozz/compiler-bugs-3/blob/master/27392.zip" \
    ["28610"]="https://gitlab.com/mmarcozz/compiler-bugs-3/raw/master/28610.zip" \
    ["32830"]="https://gitlab.com/mmarcozz/compiler-bugs-4/raw/master/32830.zip" \
    ["12189"]="https://gitlab.com/mmarcozz/buggy-compilers/raw/master/12189.zip" \
    ["13547"]="https://gitlab.com/mmarcozz/buggy-compilers/raw/master/13547.zip" \
    ["17179"]="https://gitlab.com/mmarcozz/buggy-compilers/raw/master/17179.zip" \
    ["21242"]="https://gitlab.com/mmarcozz/compiler-bugs-2/raw/master/21242.zip" \
    ["21274"]="https://gitlab.com/mmarcozz/compiler-bugs-2/raw/master/21274.zip" \
    ["26323"]="https://gitlab.com/mmarcozz/buggy-compilers/raw/master/26323.zip" \
    ["27575"]="https://gitlab.com/mmarcozz/compiler-bugs-3/blob/master/27575.zip" \
    ["29031"]="https://gitlab.com/mmarcozz/compiler-bugs-3/blob/master/29031.zip" \
    ["33706"]="https://gitlab.com/mmarcozz/compiler-bugs-4/raw/master/33706.zip" \
    ["12885"]="https://gitlab.com/mmarcozz/buggy-compilers/raw/master/12885.zip" \
    ["15674"]="https://gitlab.com/mmarcozz/buggy-compilers/raw/master/15674.zip" \
    ["17473"]="https://gitlab.com/mmarcozz/buggy-compilers/raw/master/17473.zip" \
    ["21243"]="https://gitlab.com/mmarcozz/compiler-bugs-2/raw/master/21243.zip" \
    ["24187"]="https://gitlab.com/mmarcozz/compiler-bugs-5/raw/master/24187.zip" \
    ["26407"]="https://gitlab.com/mmarcozz/compiler-bugs-2/raw/master/26407.zip" \
    ["27903"]="https://gitlab.com/mmarcozz/compiler-bugs-3/blob/master/27903.zip" \
    ["30841"]="https://gitlab.com/mmarcozz/compiler-bugs-4/raw/master/30841.zip" \
    ["34381"]="https://gitlab.com/mmarcozz/compiler-bugs-4/raw/master/34381.zip" \
    ["12899"]="https://gitlab.com/mmarcozz/buggy-compilers/raw/master/12899.zip" \
    ["15940"]="https://gitlab.com/mmarcozz/buggy-compilers/raw/master/15940.zip" \
    ["19636"]="https://gitlab.com/mmarcozz/compiler-bugs-2/raw/master/19636.zip" \
    ["21245"]="https://gitlab.com/mmarcozz/compiler-bugs-2/raw/master/21245.zip" \
    ["24516"]="https://gitlab.com/mmarcozz/compiler-bugs-2/raw/master/24516.zip" \
    ["26711"]="https://gitlab.com/mmarcozz/compiler-bugs-3/raw/master/26711.zip" \
    ["27968"]="https://gitlab.com/mmarcozz/compiler-bugs-3/blob/master/27968.zip" \
    ["30935"]="https://gitlab.com/mmarcozz/compiler-bugs-4/blob/master/30935.zip" \
    ["37119"]="https://gitlab.com/mmarcozz/compiler-bugs-5/raw/master/37119.zip")

COMPILER=/home/user42/compilers/$bug_id
if [ ! -d "$COMPILER" ]; then
    echo "--> Downloading compiler for bug $bug_id..."
    mkdir -p /home/user42/compilers
    cd /home/user42/compilers/
    wget ${bugs[$bug_id]}
    echo "--> Unzipping $bug_id"".zip..."
    unzip -qq $bug_id.zip
    rm $bug_id.zip
fi
echo "--> Installing compiler for bug $bug_id..."
rm -rf /srv/chroot/stretch-amd64-sbuild/home/compiler/cop
rm -rf /srv/chroot/stretch-amd64-sbuild/home/compiler/buggy
rm -rf /srv/chroot/stretch-amd64-sbuild/home/compiler/fixed
cp -r $COMPILER/cop /srv/chroot/stretch-amd64-sbuild/home/compiler/ 
cp -r $COMPILER/buggy /srv/chroot/stretch-amd64-sbuild/home/compiler/ 
cp -r $COMPILER/fixed /srv/chroot/stretch-amd64-sbuild/home/compiler/  
echo "--> Starting impact analysis for bug $bug_id over the selected packages"
rm -f /home/user42/compiler-bug-impact/scripts/build/tasks.json
cp /home/user42/compiler-bug-impact/scripts/build/tasks-full.json /home/user42/compiler-bug-impact/scripts/build/tasks.json 
/home/user42/compiler-bug-impact/scripts/build/steps-llvm "$bug_id"
echo "--> Starting function analysis for bug $bug_id"
/home/user42/compiler-bug-impact/scripts/function_analysis/extract-functions "$bug_id"
echo "--> Results available in the /home/user42/compiler-bug-impact/results/$bug_id/"

