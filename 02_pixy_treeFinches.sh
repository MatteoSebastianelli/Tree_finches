#!/bin/bash -l

#SBATCH -A uppmax2025-2-114
#SBATCH -M rackham
#SBATCH -p core -n 12
#SBATCH -t 78:00:00 #n_days-hh:mm:ss
#SBATCH -J pixy_tree_finches
#SBATCH --mail-type=all
#SBATCH --mail-user=matteo.sebastianelli@imbim.uu.se


ml bcftools pixy

cd $wd

TREE_FINCH_POP_FILE=/crex/proj/snic2020-2-19/private/darwins_finches/users/seba/finches463/pixy/tree_finches/tree_finches_pops.txt

# example of popfile
102Fer2092	pall_productus
102Fer2093	pall_productus
102Fer2094	pall_productus
102Isa1889	pall_productus
102Isa1892	pall_productus
102Isa1896	pall_productus
102Isa1940	pall_productus
102Sal1803	pall_striatipecta
102Sal1804	pall_striatipecta
102Sal2013	pall_striatipecta

VCF=finches_INV_BIALLELIC.vcf.gz 
tabix $VCF

pixy --stats pi dxy \
  --vcf $VCF \
  --bypass_invariant_check no \
  --n_cores 12 \
  --window_size 10000 \
  --populations $TREE_FINCH_POP_FILE \
  --output_folder out \
  --output_prefix out"$FILE"

