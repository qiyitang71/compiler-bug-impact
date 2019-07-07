# Study on the impact of fuzzer-found compiler bugs

## Getting started

### Download the virtual machine (~1 GB)

Download the VM [compiler_bugs.ova](https://drive.google.com/file/d/1mubw_cEIkMzWVeBGIHBAn826-sdtu81u/view?usp=sharing)

Make sure you have at least 20 GB disk space to run the following example.

### Start the virtual machine 

For Windows, Linux, Macintosh and Solaris, download Oracle VirtualBox from www.virtualbox.org and import the VM.

For Ubuntu Linux terminal users, you can

1. Install the Oracle VirtualBox

```
sudo apt install virtualbox
```
2. Import our pre-build appliance
```
vboxmanage import compiler_bugs.ova
```
3. Start the VM and wait for it to boot up (about 30 seconds)
```
VBoxHeadless --startvm debian
```
4. Open another terminal and ssh to the VM (password: user42user42)
```
ssh -p 2222 user42@localhost
```

### Generate the tables in Section 5

1. Go to the data directory
```
cd /home/user42/compiler-bug-impact/data
```
Here, all the logs of compiling the 309 Debian apps are in Build_Logs and all the data of the number of different funtions are in Function_Logs.

2. Generate the tables in Section 5, e.g. to see Table 3, simply run 
```
./genTable3.sh
```
3. View the tables, e.g. to view Table 3 
```
./displayResults.sh results/table3.csv
```

### Small example to analyse the impact of EMI bug 26323 on two Debian apps

Network access in the VM is required to run the example.

1. Go to the example directory 
```
cd /home/user42/compiler-bug-impact/example
```
2. Run the example 
```
./run_example.sh
```

NOTE: You will have to enter the sudo password "user42user42" after several minutes of downloading and installing the compilers.

This script will 
- Download the compilers (fixed, buggy and warning-laden/cop) corresponding to EMI bug 26323 from Gitlab if not downloaded earlier
- Install this compiler in the chroot
- Run the steps-llvm script with compiler over two apps: afl and libraw
- Compute the number of different functions for these two apps

The results are saved in /home/user42/compiler-bug-impact/example/results/26323

The build log resides in ~/compiler-bug-impact/example/results/26323/new-26323.txt, you can compare it with the reference build log by:
```
grep -A4 "afl" ~/compiler-bug-impact/data/Build_Logs/EMI/new-26323.txt
grep -A4 "libraw" ~/compiler-bug-impact/data/Build_Logs/EMI/new-26323.txt
```
The function log resides in ~/compiler-bug-impact/example/26323/26323-func.txt, you can compare it with the reference function analysis log by (note that no different functions for afl):
```
grep -A2 "libraw" ~/compiler-bug-impact/data/Function_Logs/EMI/26323-func.txt
```

## step-by-step evaluation 

In this section, we show you how to do the empirical study step by step. There is no need to run any of the scripts as each step requires enormous memory/disk/time. We have estimated the machine time spent in running all the experiments to around 5 months (see the end of Section 4.3). We ran the experiments on a range of VMs on servers and cloud machines. We then stored the logs of the experiments in the data directory to generate the tables in secion 5.

### Prepare compilers for each bug

We have built all the required compilers and you can have a look at the addresses of them in /home/user42/compiler-bug-impact/scripts/analyse-bug.sh

The detailed steps are:

1. Write a warning-laden fixing patch (see Section 3.1)

The list of 45 bugs we consider in the paper is in /home/user42/compiler-bug-impact/scripts/bug_list. For each bug, we have to prepare a warning-laden fixing patch. These patches can be found in the folder /home/user42/compiler-bug-impact/scripts/compilers/patches. 

2. Download the source code of the buggy and the fixed compiler

For each bug in the list, download the source code of LLVM and clang by
```
cd /home/user42/compiler-bug-impact/scripts/compilers
./download-sources.sh $bug_id $revision
```
The revision number for a bug is in the second column of /home/user42/compiler-bug-impact/scripts/compilers/revisions.txt

NOTE:

For LLVM version < 3.8, we need to download compiler-rt. Simply uncomment the part in the script which takes care of compiler-rt.

For bug 20189, as the fixing patch was incorporated in two contiguous revisions of the compiler sources, the revision number for the buggy compiler should be $revision-2 instead of $revision-1. See the script to (un)comment the appropriate part.

For bug 27903, as explained in Section 3.1, its fixes were applied together with other code modifications and/or via a series of non-contiguous compiler revisions. In the source code of the buggy compiler of this bug, we need to modify line 61 from `cl::init(false), cl::Hidden,` to `cl::init(true), cl::Hidden,` to turn on the buggy optimization.

3. Build the three compilers (buggy, fixed and warning-laiden/cop) for each of the bug 

```
./build-compiler.sh $bug_id
```
We need to copy the warning-laden fixing patch (part 1) to the folder /home/user/$bug_id and rename the file as patch.txt. The script `build-compiler.sh` will apply the warning-laden fixing patch to the source code of the fixed compiler. It will then build the buggy, fixed and the warning-laden/cop compilers.

NOTE from the LLVM release websites, LLVM started to introduce CMake from LLVM 3.1. For older versions, we use GNU make to build the compilers. Again, (un)comment the appropriate part in the script to take care of this.


### Set up the chroot environment (Debian 9)

As explained in Section 2.4, a chroot jail is required as a customised and isolated build environment to build our Debian apps.
`
cd /home/user42/compiler-bug-impact/scripts/chroot
./chroot.sh
`

### Analyse the impact of the 45 selected bugs on our selection of 309 Debian apps

We have collected the logs of building the apps in /home/user42/compiler-bug-impact/data/Build_Logs and the logs of computing the different functions in /home/user42/compiler-bug-impact/data/Function_Logs.

The /home/user42/compiler-bug-impact/scripts folder contains an analyse-bug.sh script that analyses the impact a specified bug on our selection of 309 Debian apps. The list of 309 Debian apps is in /home/user42/compiler-bug-impact/scripts/build/tasks-full.json. Note that the bug has to be one of our 45 selected bugs listed in /home/user42/compiler-bug-impact/scripts/bug_list. 

```
./analyse-bug.sh $bug_id
```

NOTE: The script will run for a long time for some bugs (on our virtual machine and cloud machine) and we need about 20GB free disk space to store the results of some bugs. 

This scripts will: 

1. Put the three compilers (buggy, fixed and warning-laiden/cop) of a bug in chroot jail

This first part corresponds to line 1 to line 77 of the script `analyse-bug.sh` which is downloading the prebuild compilers and installing them in the chroot jail. 

2. Build the apps using warning-laiden/cop, buggy and fixed compilers in the chroot jail using the Simple Build framework. Check for warning messages in the build process.

3. If the binaries built by the buggy and fixed compilers are different, run the default test suites using Autopkgtest on the two binaries to check for any runtime discrepancies. 

Part 2 and 3 correpond to line 81 of `analyse-bug.sh` which is running the `steps-llvm` script.

4. If binaries built by the buggy and fixed compilers are different, compute the number of different functions in these two binaries.

This part corresponds to line 83 of `analyse-bug.sh` which is running the `extract-functions` script.

### Remove the VM to save space
```
VBoxManage unregistervm --delete debian
```
