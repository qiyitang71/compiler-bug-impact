# Study on the impact of fuzzer-found compiler bugs
## Getting started

### Download the virtual machine

Download the VM [compiler_bugs.ova](https://drive.google.com/file/d/1mubw_cEIkMzWVeBGIHBAn826-sdtu81u/view?usp=sharing) 
Make sure you have about 20 GB disk space to run the example.

### start the virtual machine 
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

1. go to the data directory
```
cd /home/user42/compiler-bug-impact/data
```
Here, all the logs of compiling the 309 Debian apps are in Build_Logs and all the data of the number of different funtions are in Function_Logs.

2. generate the tables in Section 5, e.g. to see table 3, simply run 
```
./genTable3.sh
```
3. view the tables, e.g. to view Table 3 
```
./displayResults.sh results/table3.csv
```

### Small example to analyze the impact of EMI bug 26323 on two Debian apps

1. go to the example directory 
```
cd /home/user42/compiler-bug-impact/example
```
2. run the example 
```
./run_example.sh
```
This script will 
- Download the compilers (fixed, buggy and cop) corresponding to EMI bug 26323 from Gitlab if not downloaded earlier
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

(to be continued ...)

### Remove the VM
```
VBoxManage unregistervm --delete debian
```
