#!/bin/bash
##script to generate Table 4

#current directory
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
resultsDir=$dir/results/table4

#results directory
rm -rf $resultsDir
mkdir -p $resultsDir

#global data
totalPkg=309
totalFunc=202000
dataFile=$dir/allbugs.txt

#table 4 - Alive
echo "bug id, severity, successful, reached, triggered, precise, packages, functions, test diff" >> $resultsDir/table4_alive.csv
successfulTotal=0
reachedTotal=0
triggeredTotal=0
diffPkgTotal=0
functionTotal=0
funcPercentTotal=0
testsuiteDiffTotal=0
num=0
for file in $dir/Build_Logs/Alive/*.txt; do
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
    functionLine=$(tail -1 $dir/Function_Logs/Alive/"$bugid-func.txt")
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
$testsuite_diff " >> $resultsDir/table4_alive.csv
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
$functionTotalPercentage [$functionTotal], $testsuiteDiffTotal " >> $resultsDir/table4_alive.csv

#table 4 - User reported
echo "bug id, severity, successful, reached, triggered, precise, packages, functions, test diff" >> $resultsDir/table4_user.csv
successfulTotal=0
reachedTotal=0
triggeredTotal=0
diffPkgTotal=0
functionTotal=0
funcPercentTotal=0
testsuiteDiffTotal=0
num=0
for file in $dir/Build_Logs/User/*.txt; do
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
    functionLine=$(tail -1 $dir/Function_Logs/User/"$bugid-func.txt")
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
$testsuite_diff " >> $resultsDir/table4_user.csv
done
#aggregate for all user bugs
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
$functionTotalPercentage [$functionTotal], $testsuiteDiffTotal " >> $resultsDir/table4_user.csv

echo "Successully generate Table 4!"
echo "Check it by running:"
echo "./displayResults.sh $resultsDir/table4_alive.csv"
echo "./displayResults.sh $resultsDir/table4_user.csv"
