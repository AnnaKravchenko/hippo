# to change it for 'x-x..x-32.npy'

# - reads ligand Numpy coordinates (*.npy) from current directory
# - iterates implicitly over all *.npy
# - creates cache-$frag-$motif/ directory with cache files
set -u -e

scripts=$HIPPO/scripts
histo_dir=$HIPPO/tools/fake-histo/

for i in *.npy; do
    frag=$(echo "$i" | awk -F'[-.]' '{print $1}')
    motif=$(echo "$i" | awk -F'[-.]' '{print $2}')
    atomtype=$(echo "$i" | awk -F'[-.]' '{print $3}')
    mkdir -p cache-$frag-$motif
    echo "cache coordinates of $frag-$motif-$atomtype"
    python3 $scripts/discretize_coordinates.py $i $atomtype $histo_dir/1-$atomtype.json cache-$frag-$motif
done