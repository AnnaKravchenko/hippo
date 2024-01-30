#!/bin/bash 

c=$1
f=$2
m=$3
input=$4
output=$5
tr_per_histo=$6
tr_per_pool=$7

echo "scoring..."
bash $HIPPO/scripts/score-with-histo.sh $c $f $m  $input/template-scoring/ $output
bash $HIPPO/scripts/pool_poses.sh $output/$c-$f-$m $tr_per_histo $tr_per_pool
