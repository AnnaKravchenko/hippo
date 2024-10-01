# HIPPO (Histogram-based Pseudo-potential): Scoring Function for Protein-ssRNA Docking

HIPPO is tailored for fragment-based docking poses in the ATTRACT coarse-grained representation, generated with [ATTRACT docking engine](https://github.com/sjdv1982/attract/blob/master/INSTALLATION.txt). This means that HIPPO requires a single protein structure against which all RNA models are scored. HIPPO was developed and tested on RNA fragments—specifically, trinucleotides. It can rank RNA chains/fragments of any length; however, it has not yet been tested for anything other than trinucleotides.

## Requirements

To run HIPPO, you need an environment with:
* Python 3
* NumPy
* Pandas
* Parallel

Use `hippo.yml` to create a new `hippo` environment. Then export the path to HIPPO with `HIPPO=/path/to/hippo`.
If you'd like to use HIPPO on the output of ATTRACT - make sure `source` in line 153 of `scripts/hippo.sh` points to a correct location. 

## Execution

To run HIPPO, you need to prepare input files and run `bash $HIPPO/scripts/hippo.sh` from a folder with those files. 

There are two modes to run HIPPO (see `bash $HIPPO/scripts/hippo.sh --help`). One mode processes the output of fragment-based docking from ATTRACT, where all RNA poses are stored in a .dat file. An installation of ATTRACT is required for this mode. The second mode allows you to process RNA poses stored in a PDB file, which does not require an installation of ATTRACT.

To prepare a coarse-grained protein structure, a list of bound fragments and motifs, and either a list of PDB models of RNA or a .dat file with rotations/translations:
* To coarse-grain a PDB file, use `$HIPPO/tools/reduce.py` with a PDB file as an argument. Use the flag `--rna` for RNA. Please note that `reduce.py` cannot handle PDB files with multiple models.
* The `boundfrag.list` should look as follows:
    ```
    1 AAA
    2 AAC
    3 ACG
    4 CGU
    ```
  Any length or number of fragments is acceptable.
* The `motif.list` should look as follows:
    ```
    AAA
    AAC
    ACG
    CGU
    ```
* If you're using a PDB file to store models of RNA/fragments, make sure they are named `frag${frag}r.pdb`, where `$frag` corresponds to the number of a given fragment. Please ensure that RNA models are separated by `ENDMDL` and that all your RNA/fragment models are oriented with respect to a **SINGLE** protein structure. Otherwise, the resulting ranking will not make any sense.
* If you're using .dat files to store models of RNA/fragments, make sure they are named `${motif}-e7.dat`.

## Quick Theoretical Part

HIPPO works by scoring bead-bead contacts, using four distinct sets of pseudo-potentials. You can find out more in [this paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10964654/). 

Practically speaking, HIPPO will score a list of input RNA poses four times. It will then take the number of top-ranked poses specified by the user (`poses_per_potential`) from each of the four lists of scored poses, pooling these poses together and removing redundancies. Finally, a specified number of poses (`sele_top`) will be returned in the `hippo.rank` file.

Please note that raw histogram score values are not representative of any kind of energy.

#### Re-training HIPPO

The scripts used for building HIPPO are available at [sjdv1982/histograms](https://github.com/sjdv1982/histograms/tree/main). They are customized for the ATTRACT docking engine and docking poses in ATTRACT CG representation and can be used to train HIPPO-like scoring function on any other docking benchmark, e.g. DNA.

***

Feel free to use HIPPO for your docking projects, and do not hesitate to open a GitHub issue if you have any questions!
Happy docking:)
