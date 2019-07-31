#!/bin/bash

for file in $(find . -name "new-*.txt"); do
  succ_build=$(grep "package was successfully built with cop compiler" $file | wc -l)
  bug_reached=$(grep "package was successfully built with cop compiler AND bug was reached" $file| wc -l)
  bug_triggerd=$(grep ".. bug also triggered" $file| wc -l)
  bin_diff=$(grep ".. the binaries seem different" $file| wc -l)
  testsuite_abort1=$(grep ".. warning: no test was run successfully for at least one binary, please investigate manually" $file| wc -l)
  testsuite_abort2=$(grep "the corresponding source package does NOT contain a valid test suite" $file| wc -l)
  testsuite_abort=$(( testsuite_abort1+testsuite_abort2 ))
  testsuite_diff=$(grep ".. the test suite runs seem to produce different outputs" $file| wc -l)
  echo "$bugid - $num_total_file $succ_build $bug_reached $bug_triggerd $bin_diff $testsuite_abort $testsuite_diff" >> $file
done
