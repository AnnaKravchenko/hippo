#!/bin/bash

c=$1
f=$2
m=$3
template=$4
out=$5

cat $HIPPO/HIPPO | while read potential ; do 

	histoc=$(echo $potential | cut -f1 -d'-'); 
	histof=$(echo $potential | cut -f2 -d'-'); 
	histom=$(echo $potential | cut -f3 -d'-');

	prot=$template/proteinr.pdb
	nstruc=`cat $template/nstruc/${f}-${m}.nstruc`
	cachedir=$template/coordinates/cache-${f}-${m}

	outdir=$out/$c-$f-$m
	mkdir -p $outdir

	#echo "histo $potential"
	python3 -u $HIPPO/scripts/score-with-all-histograms-discrete.py $prot $m $nstruc $HIPPO/tools/$potential/rebased/ $cachedir > $outdir/$potential.score 2> $outdir/$potential.log
	python3 $HIPPO/scripts/rank-all-poses.py $outdir/$potential.score $f $template > $outdir/$potential.rank-all
	cd $outdir/
	#rm -f $$potential.score
#	python $HIPPO/scripts/analyze-score.py $outdir/$potential.rank-all > $outdir/$potential.stat
done

