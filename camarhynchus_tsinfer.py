#!/usr/bin/python3

import tsinfer
import cyvcf2
import subprocess
import sys
import zarr
import pandas as pd
import tskit
import json
import argparse
import numpy as np
from tqdm import tqdm
import itertools
from IPython.display import SVG

#function argument define
parser = argparse.ArgumentParser(description="Run tsinfer for all Darwin's finches")
parser.add_argument("-i", "--input", type = str, help="input file names(.txt)", required=True)
parser.add_argument("-o", "--output", type = str, help="output file names(.txt)", required=True)
parser.add_argument("-aa", "--ancestralAllele", type = str, help="input ancestral allele file", required=True)

args = parser.parse_args()
input_file = args.input
output_file = args.output
ancestralAlleleFile = args.ancestralAllele

vcf_name = input_file+".vcf.gz"
zarr_file_name = input_file+".vcz"
try:
    subprocess.run([sys.executable, "-m", "bio2zarr", "vcf2zarr", "convert", "--force", vcf_name, zarr_file_name])
except FileNotFoundError:
    print("Please install bio2zarr to convert VCF to Zarr by running !pip install bio2zarr")
    
ds = zarr.load(zarr_file_name)

# Add individual and population metadata
samplesfile = "camarhynchus_loxigilla_samples.tsv"
populationfile = "camarhynchus_loxigilla_populations.tsv"

population_df = pd.read_table(populationfile)
samples_df = pd.read_table(samplesfile).set_index("sample")

#samples_df.set_index("sample",inplace=True)
# It is at this stage that you get the index of the focal individuals

#  load the Zarr store, sets the schemas, and then adds metadata about samples and individual
schema = json.dumps(tskit.MetadataSchema.permissive_json().schema).encode()

ds = zarr.load(zarr_file_name)
population_set = set(samples_df.loc[ds["sample_id"]]["population"].values)  # populations table contains more populations than are present in Zarr file so take care not to add them

# Save populations and individuals metadata
zarr.save(f"{zarr_file_name}/populations_metadata_schema", schema)
zarr.save(f"{zarr_file_name}/individuals_metadata_schema", schema)
metadata = []

for row in population_df.itertuples(index=False):
    if row.population not in population_set:
        # Uncomment print statements if you want to see what is added / skipped
        print(f"Population {row.population} not present in samples; skipping")
        continue
    data = json.dumps(row._asdict())
    print(f"Adding population metadata: {data}")
    metadata.append(data.encode())
zarr.save(f"{zarr_file_name}/populations_metadata", metadata)

# Assign samples to population
ds = zarr.load(zarr_file_name)
num_individuals = ds["sample_id"].shape[0]
individuals_pop = np.full(num_individuals, tskit.NULL, dtype=np.int32)
populations = [
    json.loads(x.decode())["population"] for x in ds["populations_metadata"]
]

# Individual metadata here just consists of the population data, so in a way is redundant.
# However, it is included to show that *any* metadata related to individuals could be added here, e.g., phenotype, geolocation, etc
metadata = []
for i, name in enumerate(ds["sample_id"]):
    pop = samples_df.loc[name].population
    data = json.dumps(samples_df.loc[name].to_dict())
    print(f"Individual {name}, population {pop}")
    individuals_pop[i] = populations.index(pop)
    metadata.append(data.encode())
    print(f"Adding individual metadata: {data}")

zarr.save(f"{zarr_file_name}/individuals_population", individuals_pop)
zarr.save(f"{zarr_file_name}/individuals_metadata", metadata)

# import ancestral allele info
# Load the file
with open(ancestralAlleleFile, 'r') as file:
    # Split each line into columns and take the third column (AA field)
    aa_values = [line.split()[2] for line in file]

# Convert the list of AA values into a NumPy array with dtype=object
ancestral_allele = np.array(aa_values, dtype=object)

#For convenience generate two dictionaries that map from population name to id and the corresponding reverse mapping
pop2id = {json.loads(x.decode())["species"]:i for i, x in enumerate(ds["populations_metadata"])}
id2pop = {v:k for k, v in pop2id.items()}

# mask outgroups for inference
sample_mask = (ds["individuals_population"] == pop2id["barbadensis"]) | (ds["individuals_population"] == pop2id["bicolor"])
#sample_mask
print(f"Masking {sum(sample_mask)} outgroup individuals")

# Setup a VariantData object.
vdata = tsinfer.VariantData(zarr_file_name, ancestral_allele=ancestral_allele, sample_mask=sample_mask)

# Run inference
import tsinfer
import msprime
ts_undated = tsinfer.infer(vdata, num_threads=4, progress_monitor=True)

# Run tsdate
import tsdate
ts = tsdate.date(tsdate.preprocess_ts(ts_undated), mutation_rate=2.3e-9, rescaling_intervals=10)

# Save the tree sequence
ts.dump(output_file)

