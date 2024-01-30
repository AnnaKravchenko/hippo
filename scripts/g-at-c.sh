wdir=$1
file=$2

cd $wdir
  for motif in `cat $file`; do
    python3 $HIPPO/scripts/g-at-c.py `head -1 $LIBRARY/${motif}-clust1.0r.list` \
      ${motif}-e7.dat $LIBRARY/${motif}-clust1.0r.list coordinates/${motif}
  done
