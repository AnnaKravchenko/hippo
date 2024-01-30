# - reads ligand Numpy coordinates ($motif-*.npy) from current directory
# - iterates implicitly over all motifs
# - creates cache-$motif/ directory with cache files
set -u -e
#HIPPOSCR='/data1/akravche/hippo-paper/github/scripts'

scripts=$HIPPO/scripts
histo_dir=$HIPPO/tools/fake-histo/

for i in ???-*.npy; do 
    motif=`echo $i | awk '{print substr($1, 1, 3)}'`
    atomtype=`echo $i | awk '{print substr($1, 5, length($1) - 8)}'`
    echo $motif $atomtype
    mkdir -p cache-$motif
    python3 $scripts/discretize_coordinates.py $i $atomtype $histo_dir/1-$atomtype.json cache-$motif
done
