#!/bin/bash
##example script to get started 
bug_id="26323"

COMPILER=/home/user42/compilers/$bug_id
if [ ! -d "$COMPILER" ]; then
    echo "--> Downloading compiler for bug $bug_id ..."
    mkdir -p /home/user42/compilers
    cd /home/user42/compilers
    wget https://gitlab.com/mmarcozz/buggy-compilers/raw/"$bug_id"/"$bug_id".zip
    echo "--> Unzipping $bug_id"".zip ..."
    unzip -qq "$bug_id".zip
    rm "$bug_id".zip
fi
echo "--> Installing compiler for bug $bug_id ..."
rm -rf /srv/chroot/stretch-amd64-sbuild/home/compiler/cop
rm -rf /srv/chroot/stretch-amd64-sbuild/home/compiler/buggy
rm -rf /srv/chroot/stretch-amd64-sbuild/home/compiler/fixed
cp -r $COMPILER/cop /srv/chroot/stretch-amd64-sbuild/home/compiler/
cp -r $COMPILER/buggy /srv/chroot/stretch-amd64-sbuild/home/compiler/
cp -r $COMPILER/fixed /srv/chroot/stretch-amd64-sbuild/home/compiler/
echo "--> Starting impact analysis for bug $bug_id over package afl and libraw"
rm -f /home/user42/compiler-bug-impact/scripts/build/tasks.json
cp /home/user42/compiler-bug-impact/scripts/build/tasks-small.json /home/user42/compiler-bug-impact/scripts/build/tasks.json
/home/user42/compiler-bug-impact/scripts/build/steps-llvm-example "$bug_id"
echo "--> Starting function analysis for bug $bug_id"
/home/user42/compiler-bug-impact/scripts/function_analysis/extract-functions-example "$bug_id"
echo "--> Results available in the /home/user42/compiler-bug-impact/example/results/$bug_id/"

