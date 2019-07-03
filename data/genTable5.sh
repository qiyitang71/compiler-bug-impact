#!/bin/bash
#script to generate Table 5 

#current directory
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

#results directory
rm -f $resultTable
resultTable=$dir/results/table5.csv

if [ ! -d "$dir/results" ]; then
  mkdir -p $dir/results
fi

dataFile=$dir/allbugs.txt

#Alive
aliveBugs=$(ls $dir/Build_Logs/Alive/ | wc -l)
aliveReached=0
aliveTriggered=0
alivePrecise=0
alivePkg=0
aliveTestDiff=0
for file in $dir/Build_Logs/Alive/*.txt; do
  #build logs
  buildLine=$(tail -1 $file)
  bugid=$(echo $buildLine | cut -d" " -f1)
  reached=$(echo $buildLine | cut -d" " -f5)
  triggered=$(echo $buildLine | cut -d" " -f6)
  diffPkg=$(echo $buildLine | cut -d" " -f7)
  testsuite_diff=$(echo $buildLine | cut -d" " -f9)
  #priority and precise of patch
  dataLine=$(grep "$bugid" "$dataFile")
  precise=$(echo $dataLine | cut -d"," -f3)

  if [ "$reached" -ne 0 ]; then
    aliveReached=$(( aliveReached+1 ))
  fi
  if [ "$triggered" -ne 0 ]; then
    aliveTriggered=$(( aliveTriggered+1 ))
    if [ "$precise" = "yes" ]; then
      alivePrecise=$(( alivePrecise+1 ))
    fi
  fi
  if [ "$diffPkg" -ne 0 ]; then
    alivePkg=$(( alivePkg+1 ))
  fi
  if [ "$testsuite_diff" -ne 0 ]; then
    aliveTestDiff=$(( aliveTestDiff+1 ))
  fi
done

#User
userBugs=$(ls $dir/Build_Logs/User/ | wc -l)
userReached=0
userTriggered=0
userPrecise=0
userPkg=0
userTestDiff=0
for file in $dir/Build_Logs/User/*.txt; do
  #build logs
  buildLine=$(tail -1 $file)
  bugid=$(echo $buildLine | cut -d" " -f1)
  reached=$(echo $buildLine | cut -d" " -f5)
  triggered=$(echo $buildLine | cut -d" " -f6)
  diffPkg=$(echo $buildLine | cut -d" " -f7)
  testsuite_diff=$(echo $buildLine | cut -d" " -f9)
  #priority and precise of patch
  dataLine=$(grep "$bugid" "$dataFile")
  precise=$(echo $dataLine | cut -d"," -f3)

  if [ "$reached" -ne 0 ]; then
    userReached=$(( userReached+1 ))
  fi
  if [ "$triggered" -ne 0 ]; then
    userTriggered=$(( userTriggered+1 ))
    if [ "$precise" = "yes" ]; then
      userPrecise=$(( userPrecise+1 ))
    fi
  fi
  if [ "$diffPkg" -ne 0 ]; then
    userPkg=$(( userPkg+1 ))
  fi
  if [ "$testsuite_diff" -ne 0 ]; then
    userTestDiff=$(( userTestDiff+1 ))
  fi
done

#output to file
echo "TOOL, BUGS, reached, triggered, (precise), packages, test diffs" >> $resultTable
echo "Alive, $aliveBugs, $aliveReached, $aliveTriggered, ($alivePrecise), $alivePkg, $aliveTestDiff" >> $resultTable
echo "User, $userBugs, $userReached, $userTriggered, ($userPrecise), $userPkg, $userTestDiff" >> $resultTable

echo "Successully generate Table 5!"
echo "Check it by running: ./displayResults.sh $resultTable"
