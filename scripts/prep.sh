#!/bin/bash 

# if you're using ATTRACT locally, you can generate required 
# folder strcure from $m-e7.dat file using $HIPPO/scripts/prep_attract.sh 
# if not - use this script  

# this script requires the following arguments:
# 1. A path to the folder where `template-scoring` will be generated 
# 2. A pdb with an ensemble of coarse-grained models to score. 
template_dir=$1/template-scoring/
rna_models=$2

mkdir -p ${template_dir}/coordinates
#ln -s $2 $template_dir/proteinr.pdb

mkdir -p ${template_dir}/nstruc
echo `grep "ENDMDL" $rna_models | wc -l | tr -d " \t"` > ${template_dir}/nstruc/RNA.nstruc

echo "making cordinates..."
python $HIPPO/scripts/get_coordinates_stand_alone.py $rna_models
mv *npy ${template_dir}/coordinates
cd ${template_dir}/coordinates
echo "making cordinates cache..."
bash $HIPPO/scripts/discretize-all-attract.sh 2>/dev/null

#        wc -l < $wdir/frag$f.lrmsd >  $wdir/template-scoring/nstruc/$m.nstruc
