#!/bin/bash
##script to generate Table 3

#current directory
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
resultTable=$dir/results/table3.csv

if [ ! -d "$dir/results" ]; then
  mkdir -p $dir/results
fi

#results directory
rm -f $resultTable
dataFile=$dir/allbugs.txt

#data for all
allBugs=0
allReached=0
allTriggered=0
allPrecise=0
allPkg=0
allTestDiff=0


#Csmith
csmithBugs=$(ls $dir/Build_Logs/Csmith/ | wc -l)
csmithReached=0
csmithTriggered=0
csmithPrecise=0
csmithPkg=0
csmithTestDiff=0
for file in $dir/Build_Logs/Csmith/*.txt; do
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
    csmithReached=$(( csmithReached+1 ))
  fi
  if [ "$triggered" -ne 0 ]; then
    csmithTriggered=$(( csmithTriggered+1 ))
    if [ "$precise" = "yes" ]; then
      csmithPrecise=$(( csmithPrecise+1 ))
    fi
  fi
  if [ "$diffPkg" -ne 0 ]; then
    csmithPkg=$(( csmithPkg+1 ))
  fi
  if [ "$testsuite_diff" -ne 0 ]; then
    csmithTestDiff=$(( csmithTestDiff+1 ))
  fi
done

#EMI
emiBugs=$(ls $dir/Build_Logs/EMI/ | wc -l)
emiReached=0
emiTriggered=0
emiPrecise=0
emiPkg=0
emiTestDiff=0
for file in $dir/Build_Logs/EMI/*.txt; do
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
    emiReached=$(( emiReached+1 ))
  fi
  if [ "$triggered" -ne 0 ]; then
    emiTriggered=$(( emiTriggered+1 ))
    if [ "$precise" = "yes" ]; then
      emiPrecise=$(( emiPrecise+1 ))
    fi
  fi
  if [ "$diffPkg" -ne 0 ]; then
    emiPkg=$(( emiPkg+1 ))
  fi
  if [ "$testsuite_diff" -ne 0 ]; then
    emiTestDiff=$(( emiTestDiff+1 ))
  fi
done

#Orange
orangeBugs=$(ls $dir/Build_Logs/Orange/ | wc -l)
orangeReached=0
orangeTriggered=0
orangePrecise=0
orangePkg=0
orangeTestDiff=0
for file in $dir/Build_Logs/Orange/*.txt; do
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
    orangeReached=$(( orangeReached+1 ))
  fi
  if [ "$triggered" -ne 0 ]; then
    orangeTriggered=$(( orangeTriggered+1 ))
    if [ "$precise" = "yes" ]; then
      orangePrecise=$(( orangePrecise+1 ))
    fi
  fi
  if [ "$diffPkg" -ne 0 ]; then
    orangePkg=$(( orangePkg+1 ))
  fi
  if [ "$testsuite_diff" -ne 0 ]; then
    orangeTestDiff=$(( orangeTestDiff+1 ))
  fi
done

#yarpgen
yarpgenBugs=$(ls $dir/Build_Logs/yarpgen/ | wc -l)
yarpgenReached=0
yarpgenTriggered=0
yarpgenPrecise=0
yarpgenPkg=0
yarpgenTestDiff=0
for file in $dir/Build_Logs/yarpgen/*.txt; do
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
    yarpgenReached=$(( yarpgenReached+1 ))
  fi
  if [ "$triggered" -ne 0 ]; then
    yarpgenTriggered=$(( yarpgenTriggered+1 ))
    if [ "$precise" = "yes" ]; then
      yarpgenPrecise=$(( yarpgenPrecise+1 ))
    fi
  fi
  if [ "$diffPkg" -ne 0 ]; then
    yarpgenPkg=$(( yarpgenPkg+1 ))
  fi
  if [ "$testsuite_diff" -ne 0 ]; then
    yarpgenTestDiff=$(( yarpgenTestDiff+1 ))
  fi
done

#aggregate all
allBugs=$(echo "$csmithBugs + $emiBugs + $orangeBugs + $yarpgenBugs" | bc)
allReached=$(echo "$csmithReached + $emiReached + $orangeReached + $yarpgenReached" | bc)
allTriggered=$(echo "$csmithTriggered + $emiTriggered + $orangeTriggered + $yarpgenTriggered" | bc)
allPrecise=$(echo "$csmithPrecise + $emiPrecise + $orangePrecise + $yarpgenPrecise" | bc)
allPkg=$(echo "$csmithPkg+ $emiPkg + $orangePkg + $yarpgenPkg" | bc)
allTestDiff=$(echo "$csmithTestDiff + $emiTestDiff + $orangeTestDiff + $yarpgenTestDiff" | bc)

#output to file
echo "TOOL, BUGS, reached, triggered, (precise), packages, test diffs" >> $resultTable
echo "Csmith, $csmithBugs, $csmithReached, $csmithTriggered, ($csmithPrecise), $csmithPkg, $csmithTestDiff" >> $resultTable
echo "EMI, $emiBugs, $emiReached, $emiTriggered, ($emiPrecise), $emiPkg, $emiTestDiff" >> $resultTable
echo "Orange, $orangeBugs, $orangeReached, $orangeTriggered, ($orangePrecise), $orangePkg, $orangeTestDiff" >> $resultTable
echo "yarpgen, $yarpgenBugs, $yarpgenReached, $yarpgenTriggered, ($yarpgenPrecise), $yarpgenPkg, $yarpgenTestDiff" >> $resultTable
echo "TOTAL, $allBugs, $allReached, $allTriggered, ($allPrecise), $allPkg, $allTestDiff" >> $resultTable

echo "Successully generate Table 3!"
echo "Check it by running: ./displayResults.sh $resultTable"
