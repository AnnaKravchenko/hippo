#!/bin/bash

wdir=$1 #with xxx.rank-all 
tr=$2 # how many poses per scoring to pool (NOT %, raw count)
global_tr=$3 # how many poses to keep in total

hippo=$HIPPO/HIPPO #names of the potenials (histogram sets) in hippo

echo "pooling..."

cat $hippo | parallel -j 4 "awk -v file={} -v last_rank=\"$tr\" -F' ' 'NR > 1 && \$2 < last_rank { print \$0, file }' $wdir/{}.rank-all | sort -t\$' ' -k2,2n > $wdir/{}.selected_sorted_by_histo_rank" ::: $(cat $hippo)
cat $hippo | while read hset ; do cat $wdir/$hset.selected_sorted_by_histo_rank >> $wdir/pooled.raw ; done #; rm $wdir/$hset.selected_sorted_by_histo_rank; done

rm $wdir/*.selected_sorted_by_histo_rank
echo "deredunant..."

bash $HIPPO/scripts/dered_pool.sh $wdir # this create pooled.clean & rejected.lines 
rm $wdir/pooled.raw
#sort -k2 -n $wdir/rejected.lines > $wdir/rejected.lines-sorted
rm $wdir/rejected.lines
sort -k2 -n $wdir/pooled.clean > $wdir/pooled.clean-sorted
rm $wdir/pooled.clean

len=`wc -l < $wdir/pooled.clean-sorted`

if [ $len -ge $global_tr ] ; then
        echo "ranking..."

        head -n $global_tr $wdir/pooled.clean-sorted > $wdir/all.topC
	echo '#rank #pose_id' > $wdir/hippo.rank
	awk '{print NR,$1}'  $wdir/all.topC >> $wdir/hippo.rank

        #awk '$3<5' $wdir/all.topC > $wdir/nns.topC
        #wc -l < $wdir/nns.topC > $wdir/topC.nns
        #awk '$3<5' $wdir/all.topC | wc -l > $wdir/topC.nns
else
        echo "$len poses, pool is not big enough. Adjust how many poses per scoring to pool [tr=$2]"
fi

rm $wdir/pooled.clean-sorted
