#!/bin/bash

# This script:
# 1. deals with user input 
# 2. prepares required by HIPPO folder structure
# 3. scores RNA or all fragments written in boundfrag.list


# Deal with input 
usage_short() {
    echo "Usage: hippo.sh protein.pdb rna.pdb [-o /path/to/output]"
    echo "Try 'hippo.sh --help' for more information."
    exit 
}

usage_long() {
    echo "Usage: hippo.sh protein.pdb boundfrag.list poses_per_potential sele_top [-t /path/to/template/] [-o /path/to/output] [-n name] [-a]"
    echo ""
    echo "Mandatory positional arguments:"
    echo "  - protein.pdb is a single protein structure (to be expanded to an ensemble option)"
    echo "  - boundfrag.list that lists bound fragments or entire RNA, e.g. '1 GUU; 2 UUU; etc.' or '1 GUUUGUU' "
    echo "    For each fragment, a correspoondong file with the docking models:"
    echo "    frag1r.pdb in default mode or motif-e7.dat in attract mode (if flag -a used)."
    echo "    Currently, all docking models have to be positioned with respect to given protein structure, regardless of a mode!"
    echo "  - poses_per_potential is the number of poses to pool (per 1 potential)"
    echo "  - sele_top is the number of poses to keep at the end of the scoring"
    echo ""
    echo "Optional arguments:"
    echo "  -t is a path to folder where 'template-scoring' with required input for HIPPO - will be created; otherwise it will be in a current folder"
    echo "  -o is a path to folder where an output foldew will be created; otherwise it will be in a current folder"
    echo "  -n is a name that will be used to create an output folded, e.g. 1B7F to get output folder titled 1B7F-1-GUU; otherwise it will be titled HIPPO-1-GUU"
    echo "  -a is a flag for 'attract mode', i.e. HIPPO will score poses written as rotations/trainslations in .dat files and not in .pdb files"
    echo "  Mind that in attract mode HIPPO assumes that ATTRACT is installed, and fragment with same motif are docked just once, while default mode will look for"
    echo "  frag_r.pdb for each fragment regardelss of motif."
    echo "  -c is a flag that will remove 'template-scoring', including sizeable coordinates files"
    #echo "  -l is a flag that will look for .lrmsd files to access "
    exit 1
}

if [[ "$1" == "--help" ]]; then
    usage_long
fi

if [[ $# -lt 4 ]]; then
    echo "Error: 4 positional arguments are mandatory"
    echo "Try 'hippo.sh --help' for more information."
    exit 
fi

# Get mandatory input 
protein_pdb=$1
boundfrag=$2
poses_per_potential=$3
sele_top=$4
curr_dir=`pwd`
template_path=$curr_dir/template-scoring
output_path=$curr_dir
out_name=HIPPO
attract=flase
clean=false
# #todo lrmsd analysis outside of attract
#lrmsd=false 

shift 4

# Get optional input
while getopts ":o:t:n:acl" opt; do
    case ${opt} in
        o )
            output_path=$OPTARG
            ;;
        t )
            template_path=$OPTARG/template-scoring
            ;;
        n )
            out_name=$OPTARG
            ;;
        a )
            attract=true
            echo "Assuming ATTRACT installed properly"
            ;;
        c )
            clean=true
            echo "Directory 'template-scoring' will be deleted"
            ;;
        # l )
        #     lrmsd=true
        #     echo "Scoring will be accessed based on per-model lrmsd."
        #     ;;
        \? )
            echo "Invalid option: -$OPTARG" >&2
            usage_short
            ;;
        : )
            echo "Option -$OPTARG requires an argument." >&2
            usage_short
            ;;
    esac
done

#echo "$protein_pdb $boundfrag $poses_per_potential $sele_top $template_path $output_path $out_name"

# Prepare required folder structure
# 1. Verifiy for each line in $boundfrag we have either .dat or .pdb (1 type per scoring run!)
# 2. Make template-scoring 
# 3. Copy proteinr.pdb there 
# 4. Make nstruc; fill in nstruc/$motif.nstruc
# 5. Make coordinates; fill in
# 6. Make cache. Fix the len of name in it first. 
# 7. Make out dir; run score.sh

if [[ ! -f "$boundfrag" ]]; then
    echo "Error: File '$boundfrag' does not exist."
    exit 1
fi

mkdir -p $template_path/nstruc
mkdir -p $template_path/coordinates
cat $protein_pdb > $template_path/proteinr.pdb

# check that models exist, if yes - count them, then make coordinates and cache 
# in attract mode assume single .dat per motif
# otherwise assume single pdb per fragment regardless of the motif
while IFS=' ' read -r frag motif; do
    if [[ "$attract" == true ]] ; then
        if [[ ! -f "${motif}-e7.dat" ]]; then
        echo "Error: File ${motif}-e7.dat not found"
        rm -r $template_path
        exit 
        else 
        echo "check that attract is installed"
        # discretize also with attract
        #bash $HIPPO/scripts/score-with-histo-attract.sh
        # do stuff 
        fi 
    else 
        if [[ ! -f "frag${frag}r.pdb" ]]; then
        echo "Error: File frag${frag}r.pdb not found"
        rm -r $template_path
        exit 
        else 
        # count models 
        awk '/ENDMDL/ {count++} END {print count}' "frag${frag}r.pdb" > "${template_path}/nstruc/${frag}-${motif}.nstruc"
        # make coordinates
        python3 $HIPPO/scripts/get_coordinates_stand_alone.py "frag${frag}r.pdb" "${frag}-${motif}" "$template_path/coordinates"
        # make cache
        cd $template_path/coordinates
        #bash $HIPPO/scripts/discretize-all.sh
        bash $HIPPO/scripts/discretize-given.sh $frag $motif
        cd $curr_dir # just in case. Have to test if needed 
        # in this case, score.sh is redundant. Just call functions from here"
        echo "scoring fragment ${frag}"
        bash $HIPPO/scripts/score-with-histo.sh "${out_name}" "${frag}" "${motif}" "${template_path}" "${output_path}"
        bash $HIPPO/scripts/pool_poses.sh "${output_path}/${out_name}-${frag}-${motif}" "${poses_per_potential}" "${sele_top}"
        echo "*******************************************"
        fi 
    fi 
done < "$boundfrag"

if [[ "$clean" == true ]] ; then 
    rm -r $template_path
fi 



