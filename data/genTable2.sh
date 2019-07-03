#!/bin/bash
##script to generate Table 2

#current directory
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
resultsDir=$dir/results/table2

#results directory
rm -rf $resultsDir
mkdir -p $resultsDir

#global data
totalPkg=309
totalFunc=202000
dataFile=$dir/allbugs.txt

allSuccessful=0
allReached=0
allTriggered=0
allDiffPkg=0
allFunc=0
allTestsuiteDiff=0
allNum=0

#table - Csmith
echo "bug id, severity, successful, reached, triggered, precise, packages, functions, test diff" >> $resultsDir/table2_csmith.csv
successfulTotal=0
reachedTotal=0
triggeredTotal=0
diffPkgTotal=0
functionTotal=0
funcPercentTotal=0
testsuiteDiffTotal=0
num=0
for file in $dir/Build_Logs/Csmith/*.txt; do
  #build logs
  buildLine=$(tail -1 $file)
  bugid=$(echo $buildLine | cut -d" " -f1)
  successful=$(echo $buildLine | cut -d" " -f4)
  reached=$(echo $buildLine | cut -d" " -f5)
  triggered=$(echo $buildLine | cut -d" " -f6)
  diffPkg=$(echo $buildLine | cut -d" " -f7)
  testsuite_possible=$(echo $buildLine | cut -d" " -f8)
  testsuite_diff=$(echo $buildLine | cut -d" " -f9)

  successfulTotal=$(( successfulTotal+successful ))
  reachedTotal=$(( reachedTotal+reached ))
  triggeredTotal=$(( triggeredTotal+triggered ))
  diffPkgTotal=$(( diffPkgTotal+diffPkg ))
  testsuiteDiffTotal=$(( testsuiteDiffTotal+testsuite_diff ))

  #function analysis
  if [ "$diffPkg" -ne 0 ]; then
    functionLine=$(tail -1 $dir/Function_Logs/Csmith/"$bugid-func.txt")
    diffFunc=$(echo $functionLine | cut -d"=" -f2 | cut -d" " -f2)
    displayDiffFunc="[$diffFunc]"
    funcPercent=$(( diffFunc*100/totalFunc ))

    functionTotal=$(( functionTotal+diffFunc ))
    num=$(( num+1 ))
  else
    displayDiffFunc=""
    funcPercent="-"
  fi
  #priority and precise of patch
  dataLine=$(grep "$bugid" "$dataFile")
  priority=$(echo $dataLine | cut -d"," -f2)
  precise=$(echo $dataLine | cut -d"," -f3)

  echo "$bugid, $priority, $successful, $reached, $triggered, $precise, $diffPkg, $funcPercent $displayDiffFunc, \
$testsuite_diff" >> $resultsDir/table2_csmith.csv
done
#aggregate for all csmith bugs
reachedTotalPercent=$(echo "scale =1; ($reachedTotal*100/$successfulTotal)" | bc)
triggeredTotalPercent=$(echo "scale =1; ($triggeredTotal*100/$successfulTotal)" | bc)
diffPkgTotalPercent=$(echo "scale =1; ($diffPkgTotal*100/$successfulTotal)" | bc)
if [ "$num" -eq 0 ]; then
  functionTotalPercentage="0%"
else
  functionTotalPercentage=$((functionTotal*100/totalFunc/num))%
fi
echo "TOTAL, , $successfulTotal, $reachedTotal ($reachedTotalPercent%), \
$triggeredTotal ($triggeredTotalPercent%), , $diffPkgTotal ($diffPkgTotalPercent%), \
$functionTotalPercentage [$functionTotal], $testsuiteDiffTotal" >> $resultsDir/table2_csmith.csv

#aggregate for all fuzzers
allSuccessful=$(( allSuccessful+successfulTotal ))
allReached=$(( allReached+reachedTotal ))
allTriggered=$(( allTriggered+triggeredTotal ))
allDiffPkg=$(( allDiffPkg+diffPkgTotal ))
allFunc=$(( allFunc+functionTotal ))
allTestsuiteDiff=$(( allTestsuiteDiff+testsuiteDiffTotal ))
allNum=$(( allNum+num ))

#table2 - EMI
echo "bug id, severity, successful, reached, triggered, precise, packages, functions, test diff" >> $resultsDir/table2_emi.csv
successfulTotal=0
reachedTotal=0
triggeredTotal=0
diffPkgTotal=0
functionTotal=0
funcPercentTotal=0
testsuiteDiffTotal=0
num=0
for file in $dir/Build_Logs/EMI/*.txt; do
  #build logs
  buildLine=$(tail -1 $file)
  bugid=$(echo $buildLine | cut -d" " -f1)
  successful=$(echo $buildLine | cut -d" " -f4)
  reached=$(echo $buildLine | cut -d" " -f5)
  triggered=$(echo $buildLine | cut -d" " -f6)
  diffPkg=$(echo $buildLine | cut -d" " -f7)
  testsuite_possible=$(echo $buildLine | cut -d" " -f8)
  testsuite_diff=$(echo $buildLine | cut -d" " -f9)

  successfulTotal=$(( successfulTotal+successful ))
  reachedTotal=$(( reachedTotal+reached ))
  triggeredTotal=$(( triggeredTotal+triggered ))
  diffPkgTotal=$(( diffPkgTotal+diffPkg ))
  testsuiteDiffTotal=$(( testsuiteDiffTotal+testsuite_diff ))

  #function analysis
  if [ "$diffPkg" -ne 0 ]; then
    functionLine=$(tail -1 $dir/Function_Logs/EMI/"$bugid-func.txt")
    diffFunc=$(echo $functionLine | cut -d"=" -f2 | cut -d" " -f2)
    displayDiffFunc="[$diffFunc]"
    funcPercent=$(( diffFunc*100/totalFunc ))

    functionTotal=$(( functionTotal+diffFunc ))
    num=$(( num+1 ))
  else
    displayDiffFunc=""
    funcPercent="-"
  fi
  #priority and precise of patch
  dataLine=$(grep "$bugid" "$dataFile")
  priority=$(echo $dataLine | cut -d"," -f2)
  precise=$(echo $dataLine | cut -d"," -f3)

  echo "$bugid, $priority, $successful, $reached, $triggered, $precise, $diffPkg, $funcPercent $displayDiffFunc, \
$testsuite_diff" >> $resultsDir/table2_emi.csv
done
#aggregate for all emi bugs
reachedTotalPercent=$(echo "scale =1; ($reachedTotal*100/$successfulTotal)" | bc)
triggeredTotalPercent=$(echo "scale =1; ($triggeredTotal*100/$successfulTotal)" | bc)
diffPkgTotalPercent=$(echo "scale =1; ($diffPkgTotal*100/$successfulTotal)" | bc)
if [ "$num" -eq 0 ]; then
  functionTotalPercentage="0%"
else
  functionTotalPercentage=$((functionTotal*100/totalFunc/num))%
fi
echo "TOTAL, , $successfulTotal, $reachedTotal ($reachedTotalPercent%), \
$triggeredTotal ($triggeredTotalPercent%), , $diffPkgTotal ($diffPkgTotalPercent%), \
$functionTotalPercentage [$functionTotal], $testsuiteDiffTotal" >> $resultsDir/table2_emi.csv

#aggregate for all fuzzers
allSuccessful=$(( allSuccessful+successfulTotal ))
allReached=$(( allReached+reachedTotal ))
allTriggered=$(( allTriggered+triggeredTotal ))
allDiffPkg=$(( allDiffPkg+diffPkgTotal ))
allFunc=$(( allFunc+functionTotal ))
allTestsuiteDiff=$(( allTestsuiteDiff+testsuiteDiffTotal ))
allNum=$(( allNum+num ))

#table2 - Orange
echo "bug id, severity, successful, reached, triggered, precise, packages, functions, test diff" >> $resultsDir/table2_orange.csv
successfulTotal=0
reachedTotal=0
triggeredTotal=0
diffPkgTotal=0
functionTotal=0
funcPercentTotal=0
testsuiteDiffTotal=0
num=0
for file in $dir/Build_Logs/Orange/*.txt; do
  #build logs
  buildLine=$(tail -1 $file)
  bugid=$(echo $buildLine | cut -d" " -f1)
  successful=$(echo $buildLine | cut -d" " -f4)
  reached=$(echo $buildLine | cut -d" " -f5)
  triggered=$(echo $buildLine | cut -d" " -f6)
  diffPkg=$(echo $buildLine | cut -d" " -f7)
  testsuite_possible=$(echo $buildLine | cut -d" " -f8)
  testsuite_diff=$(echo $buildLine | cut -d" " -f9)

  successfulTotal=$(( successfulTotal+successful ))
  reachedTotal=$(( reachedTotal+reached ))
  triggeredTotal=$(( triggeredTotal+triggered ))
  diffPkgTotal=$(( diffPkgTotal+diffPkg ))
  testsuiteDiffTotal=$(( testsuiteDiffTotal+testsuite_diff ))

  #function analysis
  if [ "$diffPkg" -ne 0 ]; then
    functionLine=$(tail -1 $dir/Function_Logs/Orange/"$bugid-func.txt")
    diffFunc=$(echo $functionLine | cut -d"=" -f2 | cut -d" " -f2)
    displayDiffFunc="[$diffFunc]"
    funcPercent=$(( diffFunc*100/totalFunc ))

    functionTotal=$(( functionTotal+diffFunc ))
    num=$(( num+1 ))
  else
    displayDiffFunc=""
    funcPercent="-"
  fi
  #priority and precise of patch
  dataLine=$(grep "$bugid" "$dataFile")
  priority=$(echo $dataLine | cut -d"," -f2)
  precise=$(echo $dataLine | cut -d"," -f3)

  echo "$bugid, $priority, $successful, $reached, $triggered, $precise, $diffPkg, $funcPercent $displayDiffFunc, \
$testsuite_diff" >> $resultsDir/table2_orange.csv
done
#aggregate for all Orange bugs
reachedTotalPercent=$(echo "scale =1; ($reachedTotal*100/$successfulTotal)" | bc)
triggeredTotalPercent=$(echo "scale =1; ($triggeredTotal*100/$successfulTotal)" | bc)
diffPkgTotalPercent=$(echo "scale =1; ($diffPkgTotal*100/$successfulTotal)" | bc)
if [ "$num" -eq 0 ]; then
  functionTotalPercentage="0%"
else
  functionTotalPercentage=$((functionTotal*100/totalFunc/num))%
fi
echo "TOTAL, , $successfulTotal, $reachedTotal ($reachedTotalPercent%), \
$triggeredTotal ($triggeredTotalPercent%), , $diffPkgTotal ($diffPkgTotalPercent%), \
$functionTotalPercentage [$functionTotal], $testsuiteDiffTotal" >> $resultsDir/table2_orange.csv

#aggregate for all fuzzers
allSuccessful=$(( allSuccessful+successfulTotal ))
allReached=$(( allReached+reachedTotal ))
allTriggered=$(( allTriggered+triggeredTotal ))
allDiffPkg=$(( allDiffPkg+diffPkgTotal ))
allFunc=$(( allFunc+functionTotal ))
allTestsuiteDiff=$(( allTestsuiteDiff+testsuiteDiffTotal ))
allNum=$(( allNum+num ))

#table2 - yarpgen
echo "bug id, severity, successful, reached, triggered, precise, packages, functions, test diff" >> $resultsDir/table2_yarpgen.csv
successfulTotal=0
reachedTotal=0
triggeredTotal=0
diffPkgTotal=0
functionTotal=0
funcPercentTotal=0
testsuiteDiffTotal=0
num=0
for file in $dir/Build_Logs/yarpgen/*.txt; do
  #build logs
  buildLine=$(tail -1 $file)
  bugid=$(echo $buildLine | cut -d" " -f1)
  successful=$(echo $buildLine | cut -d" " -f4)
  reached=$(echo $buildLine | cut -d" " -f5)
  triggered=$(echo $buildLine | cut -d" " -f6)
  diffPkg=$(echo $buildLine | cut -d" " -f7)
  testsuite_possible=$(echo $buildLine | cut -d" " -f8)
  testsuite_diff=$(echo $buildLine | cut -d" " -f9)

  successfulTotal=$(( successfulTotal+successful ))
  reachedTotal=$(( reachedTotal+reached ))
  triggeredTotal=$(( triggeredTotal+triggered ))
  diffPkgTotal=$(( diffPkgTotal+diffPkg ))
  testsuiteDiffTotal=$(( testsuiteDiffTotal+testsuite_diff ))

  #function analysis
  if [ "$diffPkg" -ne 0 ]; then
    functionLine=$(tail -1 $dir/Function_Logs/yarpgen/"$bugid-func.txt")
    diffFunc=$(echo $functionLine | cut -d"=" -f2 | cut -d" " -f2)
    displayDiffFunc="[$diffFunc]"
    funcPercent=$(( diffFunc*100/totalFunc ))

    functionTotal=$(( functionTotal+diffFunc ))
    num=$(( num+1 ))
  else
    displayDiffFunc=""
    funcPercent="-"
  fi
  #priority and precise of patch
  dataLine=$(grep "$bugid" "$dataFile")
  priority=$(echo $dataLine | cut -d"," -f2)
  precise=$(echo $dataLine | cut -d"," -f3)

  echo "$bugid, $priority, $successful, $reached, $triggered, $precise, $diffPkg, $funcPercent $displayDiffFunc, \
$testsuite_diff" >> $resultsDir/table2_yarpgen.csv
done
#aggregate for all yarpgen bugs
reachedTotalPercent=$(echo "scale =1; ($reachedTotal*100/$successfulTotal)" | bc)
triggeredTotalPercent=$(echo "scale =1; ($triggeredTotal*100/$successfulTotal)" | bc)
diffPkgTotalPercent=$(echo "scale =1; ($diffPkgTotal*100/$successfulTotal)" | bc)
if [ "$num" -eq 0 ]; then
  functionTotalPercentage="0%"
else
  functionTotalPercentage=$((functionTotal*100/totalFunc/num))%
fi
echo "TOTAL, , $successfulTotal, $reachedTotal ($reachedTotalPercent%), \
$triggeredTotal ($triggeredTotalPercent%), , $diffPkgTotal ($diffPkgTotalPercent%), \
$functionTotalPercentage [$functionTotal], $testsuiteDiffTotal" >> $resultsDir/table2_yarpgen.csv

#aggregate for all fuzzers
allSuccessful=$(( allSuccessful+successfulTotal ))
allReached=$(( allReached+reachedTotal ))
allTriggered=$(( allTriggered+triggeredTotal ))
allDiffPkg=$(( allDiffPkg+diffPkgTotal ))
allFunc=$(( allFunc+functionTotal ))
allTestsuiteDiff=$(( allTestsuiteDiff+testsuiteDiffTotal ))
allNum=$(( allNum+num ))

allReachedPercent=$(echo "scale =1; ($allReached*100/$allSuccessful)" | bc)
allTriggeredPercent=$(echo "scale =1; ($allTriggered*100/$allSuccessful)" | bc)
allDiffPkgPercent=$(echo "scale =1; ($allDiffPkg*100/$allSuccessful)" | bc)
allFuncPercent=$(echo "scale =1; ($allFunc*100/$totalFunc/$allNum)" | bc)

echo "ALL, , $allSuccessful, $allReached ($allReachedPercent%), \
$allTriggered ($allTriggeredPercent%), , $allDiffPkg ($allDiffPkgPercent%), \
$allFuncPercent [$allFunc], $allTestsuiteDiff" >> $resultsDir/table2_all_fuzzers.csv

echo "Successully generate Table 2!"
echo "Check it by running:"
echo "./displayResults.sh $resultsDir/table2_csmith.csv"
echo "./displayResults.sh $resultsDir/table2_emi.csv"
echo "./displayResults.sh $resultsDir/table2_orange.csv"
echo "./displayResults.sh $resultsDir/table2_yarpgen.csv"
echo "./displayResults.sh $resultsDir/table2_all_fuzzers.csv"

