# HIPPO (Histogram-based pseudo-potential): Scoring Function for Protein-ssRNA Docking

HIPPO is a scoring function designed for the fragment-based docking of protein-ssRNA complexes, specifically tailored to the ATTRACT coarse-grained (CG) representation. This repository contains the scripts used to build and utilize HIPPO.

## Prerequisites

Before using HIPPO, ensure you have the following dependencies installed:
- Python 3
- NumPy
- Pandas
- Parallel

## Scripts

The scripts used for building HIPPO are available at [sjdv1982/histograms](https://github.com/sjdv1982/histograms/tree/main). They are customized for the ATTRACT docking engine and docking poses in ATTRACT CG representation.

## Example

Here's an example of how to score poses of the fragment with HIPPO:

1. **Requirements:**
   - Define the HIPPO environment variable for the current terminal session with export HIPPO=/my_path/hippo or define it permanently by adding that line in your /home/.bashrc
   - A folder titled `template-scoring` with the following files:
     - `proteinr.pdb`: Protein in CG. Can be derived from all-atom using `$ATTRATTOOLS/reduce.py`.
     - `nstruc/${motif}.nstruc`: Number of poses to score.
     - `coordinates/${motif}-${bead}.npy`: One file per each type of RNA beads in ATTRACT CG representation, present in at least one docking pose. Contains the coordinates of the corresponding beads within each pose. An example of the set of the docking poses (pdb), from which these foles have been derived are provided extra/ 

If you’re using ATTRACT, check scripts/prep.sh to generate the required files automatically. 

2. **Scoring Process:**
   - Clone this repository.
   - Export variable `HIPPO` (e.g., `export HIPPO=”my_path/HIPPOv1”`).
   - Create `template-scoring/` with the required fields.
   - Run `bash $HIPPO/scripts/score.sh $c $f $m $input $output $to_pool $to_keep`, where:
     - `$c`: Name of the complex (used only in the folder name), e.g., `6JVX`.
     - `$f`: Number of the docked fragment (used only in the folder name), e.g., `3`.
     - `$m`: Motif of the fragment, e.g., `GUG`.
     - `$input`: Path to where `template_scoring/` is.
     - `$output`: Location where the output folder named `$complex-$fragment_number-$motif` will be generated.
     - `$to_pool`: Number of poses to take from each scoring list to pool together. We recommend pooling ~10% of all docking poses to score.
     - `$to_keep`: Number of pooled poses to keep. We recommend keeping 20% of all docking poses.

3. **Generated Files:**
   - `X.rank-all`: Structure: `#pose_id #histo_rank`. It is a list of poses with structure ranked by the potential X.
   - `all.top`: Structure: `#pose_id #histo_rank $histo_name`. It is a list of top-ranked poses, given by all 4 potentials, with each pose mapped to the potential.
   - `hippo.rank`: Structure: `#rank #pose_id`. It is a list of poses, ranked according to HIPPO.

Feel free to explore and use HIPPO for your protein-ssRNA fragment-based docking needs!
