#!/bin/bash
##script to generate table 6

#current directory
dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

#results directory
resultTable=$dir/results/table6.csv
rm -f $resultTable

if [ ! -d "$dir/results" ]; then
  mkdir -p $dir/results
fi

dataFile=$dir/allbugs.txt
totalFunc=202000

# enhancement
enhancement_bugs=0
enhancement_successful=0
enhancement_reached=0
enhancement_triggered=0
enhancement_pkg=0
enhancement_func=0
enhancement_testDiff=0
enhancement_bugdiffnum=0

enhancement_reached_percent=0
enhancement_triggered_percent=0
enhancement_pkg_percent=0
enhancement_func_percent=0
enhancement_testDiff_percent=0

#normal
normal_bugs=0
normal_successful=0
normal_reached=0
normal_triggered=0
normal_pkg=0
normal_func=0
normal_testDiff=0
normal_bugdiffnum=0

normal_reached_percent=0
normal_triggered_percent=0
normal_pkg_percent=0
normal_func_percent=0
normal_testDiff_percent=0

#release blocker
release_bugs=0
release_successful=0
release_reached=0
release_triggered=0
release_pkg=0
release_func=0
release_testDiff=0
release_bugdiffnum=0

release_reached_percent=0
release_triggered_percent=0
release_pkg_percent=0
release_func_percent=0
release_testDiff_percent=0

for file in $(find $dir/Build_Logs/ -name "*.txt"); do
  #build logs
  buildLine=$(tail -1 $file)
  bugid=$(echo $buildLine | cut -d" " -f1)
  successful=$(echo $buildLine | cut -d" " -f4)
  reached=$(echo $buildLine | cut -d" " -f5)
  triggered=$(echo $buildLine | cut -d" " -f6)
  diffPkg=$(echo $buildLine | cut -d" " -f7)
  testsuite_diff=$(echo $buildLine | cut -d" " -f9)

  #function analysis
  if [ "$diffPkg" -ne 0 ]; then
    functionLine=$(tail -1 $(find $dir/Function_Logs/ -name "$bugid-func.txt"))
    diffFunc=$(echo $functionLine | cut -d"=" -f2 | cut -d" " -f2)
  else
    diffFunc=0
  fi

  #priority and precise of patch
  dataLine=$(grep "$bugid" "$dataFile")
  priority=$(echo $dataLine | cut -d"," -f2)

  #enhancement
  if [ "$priority" = "enhancement" ]; then
    enhancement_bugs=$(( enhancement_bugs+1 ))
    enhancement_successful=$(( enhancement_successful+successful ))
    enhancement_reached=$(( enhancement_reached+reached ))
    enhancement_triggered=$(( enhancement_triggered+triggered ))
    enhancement_pkg=$(( enhancement_pkg+diffPkg ))
    enhancement_func=$(( enhancement_func+diffFunc ))
    enhancement_testDiff=$(( enhancement_testDiff+testsuite_diff ))
    if [ "$diffPkg" -ne 0 ]; then
      enhancement_bugdiffnum=$(( enhancement_bugdiffnum+1 ))
    fi
  #normal
  elif [ "$priority" = "normal" ]; then
    normal_bugs=$(( normal_bugs+1 ))
    normal_successful=$(( normal_successful+successful ))
    normal_reached=$(( normal_reached+reached ))
    normal_triggered=$(( normal_triggered+triggered ))
    normal_pkg=$(( normal_pkg+diffPkg ))
    normal_func=$(( normal_func+diffFunc ))
    normal_testDiff=$(( normal_testDiff+testsuite_diff ))
    if [ "$diffPkg" -ne 0 ]; then
      normal_bugdiffnum=$(( normal_bugdiffnum+1 ))
    fi
  #release blocker
  else
    release_bugs=$(( release_bugs+1 ))
    release_successful=$(( release_successful+successful ))
    release_reached=$(( release_reached+reached ))
    release_triggered=$(( release_triggered+triggered ))
    release_pkg=$(( release_pkg+diffPkg ))
    release_func=$(( release_func+diffFunc ))
    release_testDiff=$(( release_testDiff+testsuite_diff )) 
    if [ "$diffPkg" -ne 0 ]; then
      release_bugdiffnum=$(( release_bugdiffnum+1 ))
    fi
  fi
done 

#aggregate data
enhancement_reached_percent=$(echo "scale =1; ($enhancement_reached*100/$enhancement_successful)" | bc)
enhancement_triggered_percent=$(echo "scale =1; ($enhancement_triggered*100/$enhancement_successful)" | bc)
enhancement_pkg_percent=$(echo "scale =1; ($enhancement_pkg*100/$enhancement_successful)" | bc)
enhancement_func_percent=$(echo "scale =2; ($enhancement_func*100/$totalFunc/$enhancement_bugdiffnum)" | bc)
enhancement_testDiff_percent=$(echo "scale =1; ($enhancement_testDiff*100/$enhancement_successful)" | bc)

normal_reached_percent=$(echo "scale =1; ($normal_reached*100/$normal_successful)" | bc)
normal_triggered_percent=$(echo "scale =1; ($normal_triggered*100/$normal_successful)" | bc)
normal_pkg_percent=$(echo "scale =1; ($normal_pkg*100/$normal_successful)" | bc)
normal_func_percent=$(echo "scale =2; ($normal_func*100/$totalFunc/$normal_bugdiffnum)" | bc)
normal_testDiff_percent=$(echo "scale =1; ($normal_testDiff*100/$normal_successful)" | bc)

release_reached_percent=$(echo "scale =1; ($release_reached*100/$release_successful)" | bc)
release_triggered_percent=$(echo "scale =1; ($release_triggered*100/$release_successful)" | bc)
release_pkg_percent=$(echo "scale =1; ($release_pkg*100/$release_successful)" | bc)
release_func_percent=$(echo "scale =2; ($release_func*100/$totalFunc/$release_bugdiffnum)" | bc)
release_testDiff_percent=$(echo "scale =1; ($release_testDiff*100/$release_successful)" | bc)

#output to file 
echo "severity, userBugs, successful, reached, triggered, packages, functions, test diffs" >> $resultTable
echo "enhancement, $enhancement_bugs, $enhancement_successful, $enhancement_reached ($enhancement_reached_percent%), \
$enhancement_triggered ($enhancement_triggered_percent%), $enhancement_pkg ($enhancement_pkg_percent%), \
$enhancement_func_percent% [$enhancement_func], $enhancement_testDiff ($enhancement_testDiff_percent%)" >> $resultTable
echo "normal, $normal_bugs, $normal_successful, $normal_reached ($normal_reached_percent%), \
$normal_triggered ($normal_triggered_percent%), $normal_pkg ($normal_pkg_percent%), \
$normal_func_percent% [$normal_func], $normal_testDiff ($normal_testDiff_percent%)" >> $resultTable
echo "release, $release_bugs, $release_successful, $release_reached ($release_reached_percent%), \
$release_triggered ($release_triggered_percent%), $release_pkg ($release_pkg_percent%), \
$release_func_percent% [$release_func], $release_testDiff ($release_testDiff_percent%)" >> $resultTable

echo "Successully generate Table 6!"
echo "Check it by running: ./displayResults.sh $resultTable"
