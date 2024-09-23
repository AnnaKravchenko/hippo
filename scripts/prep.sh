#!/bin/bash 

# if you're using ATTRACT locally, you can generate required folder strcure from $m-e7.dat file.
# run this script with $1 pointing to the folder with:
# motif-e7.dat
# motif.list 
# boundfrag.list 
# nalib (fragmnet library)
# (optional) frag${f}.lrmsd 

wdir=$1 #path to folder with files like $motit-e7.dat, frag$f.lrmsd etc.

mkdir -p $wdir/template-scoring/rmsd
mkdir -p $wdir/template-scoring/coordinates
mkdir -p $wdir/template-scoring/nstruc

ln -s $wdir/protein-aar.pdb $wdir/template-scoring/proteinr.pdb

while read line; do
    f=$(echo $line | cut -f1 -d' ')
    m=$(echo $line | cut -f2 -d' ')
    if [ -f $wdir/frag$f.lrmsd ] ; then
        ln -s $wdir/frag$f.lrmsd $wdir/template-scoring/rmsd/.
        wc -l < $wdir/frag$f.lrmsd >  $wdir/template-scoring/nstruc/$m.nstruc
    else
        echo "$wdir/frag$f.lrmsd not found. Please create $wdir/template-scoring/nstruc/$m.nstruc manually"
    fi
done < $wdir/boundfrag.list

echo "making cordinates..."
mkdir $wdir/coordinates
# this needs acces to attract engine
bash $HIPPO/scripts/g-at-c.sh $wdir motif.list
ln -s $wdir/coordinates/*npy $wdir/template-scoring/coordinates
echo "making cordinates cache..."
cd $wdir/template-scoring/coordinates
# this need access to pands, not in attract. Also don't need actual attract to work. Can be done w/o attract?
bash $HIPPO/scripts/discretize-all.sh 2>tmp.out
rm tmp.out 
