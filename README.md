# Study on the impact of fuzzer-found compiler bugs

## Getting started

### Download the virtual machine (~1 GB)

Download the VM [compiler_bugs.ova](https://drive.google.com/open?id=1wAGbGWCHdPsrmPIqzcXXAWNijEB_E69h)

Go to the directory of the downloaded VM and use the md5 or md5sum command-line tool to generate the hash. It should be `85031943ba031b5e7a58a1166cdf741e`.


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
5. Go to the working directory and update the git repo
```
cd /home/user42/compiler-bug-impact
git pull
```

### Generate the tables in Section 5

1. Go to the data directory
```
cd /home/user42/compiler-bug-impact/data
```
Here, all the logs of compiling the 309 Debian apps are in Build_Logs and all the data of the number of different assembly funtions are in Function_Logs.

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
- Compute the number of different assembly functions for these two apps

The results are saved in `/home/user42/compiler-bug-impact/example/results/26323`

The build log resides in `~/compiler-bug-impact/example/results/26323/new-26323.txt`, you can compare it with the reference build log by:
```
grep -A4 "afl" ~/compiler-bug-impact/data/Build_Logs/EMI/new-26323.txt
grep -A4 "libraw" ~/compiler-bug-impact/data/Build_Logs/EMI/new-26323.txt
```
The function log resides in `~/compiler-bug-impact/example/26323/26323-func.txt`, you can compare it with the reference function analysis log by (note that no different assembly functions for afl):
```
grep -A2 "libraw" ~/compiler-bug-impact/data/Function_Logs/EMI/26323-func.txt
```
## Step-by-step instructions 

In this section, we show you how to do the empirical study step by step. There is NO NEED to run any of the scripts as each step requires enormous memory/disk/time. We have estimated the machine time spent in running all the experiments to around 5 months (see the end of Section 4.3). We ran the experiments on a range of VMs on servers and cloud machines. We then stored the logs of the experiments in the data directory to generate the tables in secion 5.

### Prepare compilers for each bug

We have built all the required compilers and you can have a look at the addresses of them in `/home/user42/compiler-bug-impact/scripts/analyse-bug.sh`

The detailed steps are:

1. Write a warning-laden fixing patch (see Section 3.1)

The list of 45 bugs we consider in the paper is in `/home/user42/compiler-bug-impact/scripts/bug_list`. For each bug, we have to prepare a warning-laden fixing patch. These patches can be found in the folder `/home/user42/compiler-bug-impact/scripts/compilers/patches`. 

2. Download the source code of the buggy and the fixed compiler

For each bug in the list, download the source code of LLVM and clang by
```
cd /home/user42/compiler-bug-impact/scripts/compilers
./download-sources.sh $bug_id $revision
```
The revision number for a bug is in the second column of `/home/user42/compiler-bug-impact/scripts/compilers/revisions.txt`

NOTE:
- For LLVM version < 3.8, we also need to download compiler-rt. Simply uncomment the part in the script which takes care of compiler-rt.
- For bug 20189, as the fixing patch was incorporated in two contiguous revisions of the compiler sources, the revision number for the buggy compiler should be `$revision-2` instead of `$revision-1`. See the script to (un)comment the appropriate part.
- For bug 27903, as explained in Section 3.1, its fixes were applied together with other code modifications and/or via a series of non-contiguous compiler revisions. In the source code of the buggy compiler of this bug, we need to modify line 61 of `lib/CodeGen/StackColoring.cpp` from `cl::init(false), cl::Hidden,` to `cl::init(true), cl::Hidden,` to turn on the buggy optimization.

3. Build the three compilers (buggy, fixed and warning-laiden/cop) for each of the bug 

```
./build-compiler.sh $bug_id
```
We need to copy the warning-laden fixing patch (part 1) to the folder `/home/user/$bug_id` and rename the file as patch.txt. The script `build-compiler.sh` will apply the warning-laden fixing patch to the source code of the fixed compiler, then build the buggy, fixed and the warning-laden/cop compilers.

NOTE:
- From the LLVM release websites, LLVM started to introduce CMake from LLVM 3.1. For older versions, we use GNU make to build the compilers. Again, (un)comment the appropriate part in the `build-compiler.sh` script to take care of this.
- The VM is set up to be able to build the compilers for most of the bugs but not the following ones: 11964, 11977, 12189, 12855, 12899, 12901 and 13326. The compilers corresponding to these old Csmith bugs require either gcc-4.4, g++-4.4 libraries or modifications in the source code in the Debian 9 OS.

### Set up the chroot environment (Debian 9)

As explained in Section 2.4 and Section 4.3, a chroot jail is required as a customised and isolated build environment to build our Debian apps.
```
cd /home/user42/compiler-bug-impact/scripts/chroot
./chroot.sh
```
The script has been run in the VM already to set up the chroot jail and please do NOT run the script again.

### Analyse the impact of the 45 selected bugs on our selection of 309 Debian apps

We have collected the logs of building the apps in `/home/user42/compiler-bug-impact/data/Build_Logs` and the logs of computing the different assemby functions in `/home/user42/compiler-bug-impact/data/Function_Logs`.

The `/home/user42/compiler-bug-impact/scripts` folder contains an `analyse-bug.sh` script which analyses the impact a specified bug on our selection of 309 Debian apps. The list of 309 Debian apps is in `/home/user42/compiler-bug-impact/scripts/build/tasks-full.json`. Note that the bug has to be one of our 45 selected bugs listed in `/home/user42/compiler-bug-impact/scripts/bug_list`. 

```
./analyse-bug.sh $bug_id
```

NOTE: The script will run for a long time for some bugs (on our virtual machine and cloud machine) and we need about 20GB free disk space to store the results of some bugs. 

This scripts will: 

1. Put the three compilers (buggy, fixed and warning-laiden/cop) of a bug in chroot jail

This part is to download the prebuild compilers and to install them in the chroot jail, corresponding to line 1 ~ 77 of the script `analyse-bug.sh`. 

2. Set the warning-laiden/cop compiler as the default compiler in the chroot jail and ask Simple Build to build the app. The resulting build logs are then searched (using grep) for the warning messages. (See Section 4.3, Stage 1)

This corresponds to line 75 ~ 113 of `/home/user42/compiler-bug-impact/scripts/build/steps-llvm`

3. Set successively the buggy and fixed compiler as the default compiler in the chroot jail and ask Simple Build to build each time the app. The two resulting binaries are then compared bitwise using diff. (See Section 4.3, first part of Stage 2)

This corresponds to line 114 ~ 215 of `/home/user42/compiler-bug-impact/scripts/build/steps-llvm`

4. If the binaries built by the buggy and fixed compilers are different, run the default test suites using Autopkgtest on the two binaries to check for any runtime discrepancies.  (See Section 4.3, Stage 3)

This corresponds to line 216 ~ 257 of `/home/user42/compiler-bug-impact/scripts/build/steps-llvm`

5. If binaries built by the buggy and fixed compilers are different, compute the number of different assembly functions in these two binaries. (See Section 4.3, second part of Stage 2)

This corresponds to line 83 of `analyse-bug.sh` which is to run the `extract-functions` script.

## Customize the evaluation

In the last part of this guide, we show how to analyse the impact of other bugs (other than EMI 26323) on a customized list of Debian apps. 

Network access in the VM is required.

To save space, first clean up the data from the previous runs
```
rm -rf ~/compilers
rm -rf ~/compiler-bug-impact/example/results
```
1. Go to the example directory 
```
cd /home/user42/compiler-bug-impact/example
```
2. (Optional) Customize the Debian apps

The default Debian apps are afl and libraw, but if you want to analyse the impact on other Debian apps, you can edit `/home/user42/compiler-bug-impact/scripts/build/tasks-small.json` by choosing any one of the Debian apps listed in 
`/home/user42/compiler-bug-impact/scripts/build/tasks-full.json`. It is suggested to limit the total number to 2 or 3 in order to complete the evaluation in a reasonable amount of time. 

3. Run the analysis by specifying the bug id

The bug id has to be one of our 45 bugs listed in `/home/user42/compiler-bug-impact/scripts/bug_list`, e.g., 12189.
```
./run_example_bug.sh 12189
```
NOTE: You will have to enter the sudo password "user42user42" after several minutes of downloading and installing the compilers.

4. Similar to the section of getting-started, compare the build log and function log with the ones in the data directory `/home/user42/compiler-bug-impact/data`.

```
grep -A4 "afl" ~/compiler-bug-impact/data/Build_Logs/Csmith/new-12189.txt
grep -A4 "libraw" ~/compiler-bug-impact/data/Build_Logs/Csmith/new-12189.txt
grep -A2 "libraw" ~/compiler-bug-impact/data/Function_Logs/Csmith/12189-func.txt
```

To find the location of the build log and function log of a particular bug, e.g. 12189
```
find /home/user42/compiler-bug-impact/data/ -name "new-12189.txt"
find /home/user42/compiler-bug-impact/data/ -name "12189-func.txt" 
```

## Remove the VM to save space (for linux terminal users)
```
VBoxManage unregistervm --delete debian
```
