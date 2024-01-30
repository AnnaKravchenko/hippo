#!/bin/bash

path=$1
#echo "inside dered"
input_file=$path/pooled.raw
rejected_lines_file=$path/rejected.lines

awk -v rejected="$rejected_lines_file" '{
  if ($1 in a) {
    if ($2 < a[$1]) {
      print a_line[$1] > rejected
      a[$1] = $2
      a_line[$1] = $0
    } else {
      print $0 > rejected
    }
  } else {
    a[$1] = $2
    a_line[$1] = $0
  }
}
END {
  for (i in a_line) {
    print a_line[i]
  }
}' $input_file >  $path/pooled.clean
