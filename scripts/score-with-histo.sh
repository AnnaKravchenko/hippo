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
	nstruc=`cat $template/nstruc/${m}.nstruc`
	cachedir=$template/coordinates/cache-${m}

	outdir=$out/$c-$f-$m
	mkdir -p $outdir

	#echo "histo $potential"
	python3 -u $HIPPO/scripts/score-with-all-histograms-discrete.py $prot $m $nstruc $HIPPO/tools/$potential/rebased/ $cachedir > $outdir/$c-$f-$m-$potential.score 2> $outdir/$potential.log
	python3 $HIPPO/scripts/rank-all-poses.py $outdir/$c-$f-$m-$potential.score $f $template > $outdir/$potential.rank-all
	cd $outdir/
	rm -f $c-$f-$m-$potential.score
#	python3 $HIPPO/scripts/analyze-score.py $outdir/$potential.rank-all > $outdir/$potential.stat
done

