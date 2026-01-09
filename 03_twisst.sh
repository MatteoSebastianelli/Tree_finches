#!/bin/bash -l

#SBATCH -A uppmax2025-2-114
#SBATCH -M rackham
#SBATCH -p core -n 2
#SBATCH -t 72:00:00 #n_days-hh:mm:ss
#SBATCH -J cama_twisst
#SBATCH --mail-type=all
#SBATCH --mail-user=matteo.sebastianelli@imbim.uu.se
#SBATCH -a 0-29

ml bioinfo-tools vcftools/0.1.16 samtools bcftools/1.19 python/3.12.1 PhyML/3.3.20190321

GENOMICS_GENERAL=/crex/proj/snic2020-2-19/private/darwins_finches/users/seba/BIN/genomics_general
TWISST=/crex/proj/snic2020-2-19/private/darwins_finches/users/seba/BIN/twisst-0.2

CHRLIST=($(<chr_list.txt)) # this is a simple list of chromosomes as they are in the vcf
CHR=${CHRLIST[${SLURM_ARRAY_TASK_ID}]}

####### RUN TWISST ANALYSIS FOR THE Camarhynchus study
## focus on habeli, affinis, parvulus - example based on chr28, same vcf used in the ARG example subset for the individuals of interest

python $GENOMICS_GENERAL/VCF_processing/parseVCF.py -i loxigilla_parvulus_affinis_habeli_twisst_"$CHR".recode.vcf | bgzip > loxigilla_parvulus_affinis_habeli_twisst_"$CHR".geno.vcf.gz

python $GENOMICS_GENERAL/phylo/phyml_sliding_windows.py --threads 2 \
-g loxigilla_parvulus_affinis_habeli_twisst_"$CHR".geno.vcf.gz \
--prefix loxigilla_parvulus_affinis_habeli_twisst_"$CHR"_w50SNPs_phyml_bionj \
--windType sites -w 50 --minSites 10 --minPerInd 2 --model GTR --optimise n --outgroup outgroup_loxigilla.txt

python $TWISST/twisst.py \
-t loxigilla_parvulus_affinis_habeli_twisst_"$CHR"_w50SNPs_phyml_bionj.trees.gz  \
--groupsFile loxigilla_parvulus_affinis_habeli_groupIDs.txt \
-g habeli \
-g affinis \
-g parvulus \
-g outgroup > loxigilla_parvulus_affinis_habeli_twisst_"$CHR".weights.txt


