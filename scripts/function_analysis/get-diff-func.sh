#!/bin/bash
# working directory
working_dir=$1
opfile=$working_dir/$(echo $working_dir | rev | cut -d/ -f1 | rev)"-func.txt"
rm -f $opfile
javac CSVReader.java
for dir in $working_dir/*; do
  if  [ ! -d $dir ]; then
    continue
  fi
  if  [ ! -f "$dir"/buggy-binary.csv ]; then
    continue
  fi
  if  [ ! -f "$dir"/fixed-binary.csv ]; then
    continue
  fi
  pkg=$(echo $dir | rev | cut -d/ -f1 | rev)
  echo "collecting functions of $pkg ..."
  echo $pkg >> $opfile
  java CSVReader "$dir"/buggy-binary.csv "$dir"/fixed-binary.csv >> $opfile
done

if [ -f "$opfile" ]; then
  python get-data.py $opfile 
  echo "write results to $opfile"
else
  echo "no different functions found"
fi
