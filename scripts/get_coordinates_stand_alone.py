import os
import sys
import numpy as np
from pathlib import Path

def extract_bead_coordinates(rna_pdb: str, name: str, saveto: str):
    """Extract bead coordinates in dump_coordinates way
    Arg:
    pdb_file: with multiple models of ATTRACT CG RNA
    name: to save coordinates using name-XX.npy
    saveto: path to where to save *npy

    Out:
    numpy arrays like:
    [ [<in model 1>
        [x,y,z for the 1st occurence of a bead],
        [x,y,z for the 1st occurence of a bead],
        ...
      ]
      [<in model 2>
        [x,y,z for the 1st occurence of a bead],
        [x,y,z for the 1st occurence of a bead],
        ...
       ]
        ...
    ]
    for each bead id present in input.
    """
    bead_ids=range(32, 49) 
    bead_data = {bead_id: [] for bead_id in bead_ids}  

    def process_pdb_lines(pdb_lines):
        """Process PDB lines and extract coordinates for matching bead IDs."""
        current_model = {bead_id: [] for bead_id in bead_ids}  
        for line in pdb_lines:
            if line.startswith('ATOM') or line.startswith('HETATM'):
                bead_id = int(line[56:60].strip())
                if bead_id in bead_ids:
                    x = float(line[30:38].strip())
                    y = float(line[38:46].strip())
                    z = float(line[46:54].strip())
                    current_model[bead_id].append([x, y, z])

        for bead_id, coords in current_model.items():
            if coords:
                bead_data[bead_id].append(coords)  
    
    with open(rna_pdb, 'r') as f:
        pdb_lines = []
        for line in f:
            if line.startswith('MODEL'):
                pdb_lines = []  
            elif line.startswith('ENDMDL'):
                process_pdb_lines(pdb_lines)  
            else:
                pdb_lines.append(line)

    for bead_id, models in bead_data.items():
        if models:
            bead_array = np.array(models)
            np.save(f"{saveto}/{name}-{bead_id}.npy", bead_array)
            
rna_file = sys.argv[1] # A pdb file with multiple RNA models
name = 'RNA' # default name in name-XX.npy 
saveto = os.getcwd() # save in current dir by default
if sys.argv[2]:
    name = sys.argv[2] 
if sys.argv[3]:
    saveto = sys.argv[3]

extract_bead_coordinates(rna_file, name, saveto)
 