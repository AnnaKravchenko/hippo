# to change it for 'x-x..x-32.npy'

# - reads ligand Numpy coordinates (*.npy) from current directory
# - iterates implicitly over all *.npy
# - creates cache-$frag-$motif/ directory with cache files
set -u -e

scripts=$HIPPO/scripts
histo_dir=$HIPPO/tools/fake-histo/

frag=$1
motif=$2
flag=$3 # true for motif-based, when fragments of the same motif docked just 1 time, i.e. when working with .dat
        # false for frgament-based, when each fragment docked individually, regardless of motif


if [[ $flag == false ]]; then
    for i in ${frag}-${motif}-*.npy; do
        atomtype=$(echo "$i" | awk -F'[-.]' '{print $3}')
        mkdir -p cache-$frag-$motif
        echo "cache coordinates of $frag-$motif-$atomtype"
        python3 $scripts/discretize_coordinates.py $i $atomtype $histo_dir/1-$atomtype.json cache-$frag-$motif
    done
else 
    for i in ${motif}-*.npy; do
        atomtype=$(echo "$i" | awk -F'[-.]' '{print $2}')
        mkdir -p cache-$motif
        echo "cache coordinates of $motif-$atomtype"
        python3 $scripts/discretize_coordinates.py $i $atomtype $histo_dir/1-$atomtype.json cache-$motif
    done
fi 