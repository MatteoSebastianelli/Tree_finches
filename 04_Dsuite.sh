#!/bin/bash -l

#SBATCH -A uppmax2025-2-114
#SBATCH -M rackham
#SBATCH -p core
#SBATCH -t 72:00:00 #n_days-hh:mm:ss
#SBATCH -J camarhynchus_dsuite
#SBATCH --mail-type=all
#SBATCH --mail-user=matteo.sebastianelli@imbim.uu.se
#SBATCH -a 0-29

ml Dsuite/0.5-r57

CHRLIST=($(<chr_list.txt))
CHR=${CHRLIST[${SLURM_ARRAY_TASK_ID}]}

mkdir "$CHR"
cd ./"$CHR"

## affinis, parvulus, habeli
Dsuite Dinvestigate -w 200,100 ../../finches_highcov_463_"$CHR"_QF_IDrenamed_setGT_snps_biall_maxmiss075_maf003_DP2_100_LoxiAA.recode.vcf.gz ../../../loxi_parvulus_affinis_habeli_G03.pop.txt ../../loxi_parvulus_affinis_habeli_trios.txt



