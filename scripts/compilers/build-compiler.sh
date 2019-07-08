#!/bin/bash
if [ $# -ne 1 ]; then
    echo "No arguments supplied. Usage is ./build-compiler.sh \$bug_id "
    exit 1
fi
bug_id=$1
working_folder=/home/user42/$bug_id

if [ ! -d "$working_folder" ]; then
  echo "$working_folder not exist. Download the source code for bug $bug_id first "
  exit 1
fi

sudo chown user42:sbuild $working_folder
cd $working_folder

if ! [ -e "patch.txt" ]
  then
   echo "No patch.txt file found. Stopping here."
   exit 1
fi
rm -f ./compilers.log

# COMPILING BUGGY COMPILER
echo "--> [1/3] "$(date | awk '{print $4}')" - BUILDING BUGGY COMPILER "
cd $working_folder/buggy
mkdir llvm-build
rm -rf llvm-install
mkdir llvm-install
cd $working_folder/buggy/llvm-build
# Depending on LLVM version, compilation must be made using either make or cmake: comment the required line to choose between them
cmake -DCMAKE_BUILD_TYPE="Release" $working_folder/buggy/llvm >>/home/user42/compilers.log 2>&1
make -j$(nproc) >>/home/user42/compilers.log 2>&1
cmake -DCMAKE_INSTALL_PREFIX=$working_folder/buggy/llvm-install -P cmake_install.cmake >>/home/user42/compilers.log 2>&1
#../llvm/configure --prefix=$working_folder/buggy/llvm-install --enable-optimized --disable-compiler-version-checks >>/home/user42/compilers.log 2>&1
#make -j$(nproc) >>/home/user42/compilers.log 2>&1
#make install >>/home/user42/compilers.log 2>&1

# COMPILING FIXED COMPILER
#echo "--> [2/3] "$(date | awk '{print $4}')" - BUILDING FIXED COMPILER "
cd $working_folder/fixed
mkdir llvm-build
mkdir llvm-install
cd $working_folder/fixed/llvm-build

# Depending on LLVM version, compilation must be made using either make or cmake: comment the required line to choose between them
cmake -DCMAKE_BUILD_TYPE="Release" $working_folder/fixed/llvm >>/home/user42/compilers.log 2>&1
make -j$(nproc) >>/home/user42/compilers.log 2>&1
cmake -DCMAKE_INSTALL_PREFIX=$working_folder/fixed/llvm-install -P cmake_install.cmake >>/home/user42/compilers.log 2>&1
#../llvm/configure --prefix=$working_folder/fixed/llvm-install --enable-optimized >>/home/user42/compilers.log 2>&1
#make -j$(nproc) >>/home/user42/compilers.log 2>&1
#make install >>/home/user42/compilers.log 2>&1

# COMPILING COP COMPILER
echo "--> [3/3] "$(date | awk '{print $4}')" - BUILDING COP COMPILER "
cd $working_folder/cop
patch -p0 < $working_folder/patch.txt
mkdir llvm-build
mkdir llvm-install
cd llvm-build

# Depending on LLVM version, compilation must be made using either make or cmake: comment the required line to choose between them
cmake -DCMAKE_BUILD_TYPE="Release" $working_folder/cop/llvm >>/home/user42/compilers.log 2>&1
make -j$(nproc) >>/home/user42/compilers.log 2>&1
cmake -DCMAKE_INSTALL_PREFIX=$working_folder/cop/llvm-install -P cmake_install.cmake >>/home/user42/compilers.log 2>&1
#../llvm/configure --prefix=$working_folder/cop/llvm-install --enable-optimized >>/home/user42/compilers.log 2>&1
#make -j$(nproc) >>/home/user42/compilers.log 2>&1
#make install >>/home/user42/compilers.log 2>&1

echo ""$(date | awk '{print $4}')" - COMPILERS INSTALL FOR LLVM "$working_folder" DONE"

