#!/bin/bash

if [ $# -ne 2 ]
  then
    echo "No arguments supplied. Usage is ./download-sources.sh \$bug_id \$revision "
    exit 1
fi

# argument 1 is bug id
working_folder=/home/user42/$1

# argument 2 is revision number
revision=$2
# for bug 20189 
# revisionmo=$(( revision - 2 ))
revisionmo=$(( revision - 1 ))

sudo rm -rf $working_folder
sudo mkdir $working_folder
sudo chown user42:sbuild $working_folder
rm ./compilers.log

sudo echo ""$(date | awk '{print $4}')" - STARTING COMPILERS INSTALL FOR LLVMv"$revision" (output to /home/user42/compilers.log)"

# Downloading LLVM sources
# for clang verison < 3.8.0, compiler-rt is not optional 
# so please uncomment the code to download compiler-rt

echo "--> [1/4] "$(date | awk '{print $4}')" - DOWLOADING AND PREPARING COMPILER SOURCES "
cd $working_folder
mkdir buggy
mkdir fixed
mkdir cop
svn checkout https://llvm.org/svn/llvm-project/llvm/trunk@$revision llvm >>/home/user42/compilers.log 2>&1
rm -rf ./llvm/.svn
cd ./llvm/tools
svn checkout https://llvm.org/svn/llvm-project/cfe/trunk@$revision clang >>/home/user42/compilers.log 2>&1
rm -rf ./clang/.svn
cd $working_folder
#cd llvm/projects
#svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk@$revision compiler-rt >>/home/user42/compilers.log 2>&1
#rm -rf ./compiler-rt/.svn
cd $working_folder
cp -r ./llvm ./fixed
mv ./llvm ./cop
cd buggy
svn checkout https://llvm.org/svn/llvm-project/llvm/trunk@$revisionmo llvm >>/home/user42/compilers.log 2>&1
rm -rf ./llvm/.svn
cd ./llvm/tools
svn checkout https://llvm.org/svn/llvm-project/cfe/trunk@$revisionmo clang >>/home/user42/compilers.log 2>&1
rm -rf ./clang/.svn
cd $working_folder/buggy
#cd llvm/projects
#svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk@$revisionmo compiler-rt >>/home/user42/compilers.log 2>&1
#rm -rf ./compiler-rt/.svn
