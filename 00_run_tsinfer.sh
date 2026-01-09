# Run tsinfer script - using chr28 as example
python AllFinches_tsinfer.py -i camarhynchus_chr28_maxmiss075_maf003_DP2_100_IDrenamed_phased_LoxiAA.recode -o ./output_folder/camarhynchus_chr28.trees -aa finches_chr28_loxigilla_AA.txt

# Example of AA.txt file
chr28	373	C
chr28	639	G
chr28	819	A
chr28	1123	A
chr28	1137	A
chr28	1234	G
chr28	1299	A
chr28	1556	T
chr28	1651	C
chr28	1841	G

# Example of samples file
sample	population
heliobates_Isabela_108Isa2	heliobatesIsabela
heliobates_Isabela_108Isa1936	heliobatesIsabela
heliobates_Isabela_108Isa1857	heliobatesIsabela
barbadensis_Barbados_932Bar1	barbadensis
barbadensis_Barbados_932Bar2	barbadensis
barbadensis_Barbados_932Bar3	barbadensis
barbadensis_Barbados_932Bar6	barbadensis
barbadensis_Barbados_932Bar7	barbadensis
bicolor_Barbados_929Bar1	bicolor

# Example of population file
population	species
pallidus_W	pallidus
pallidusSanCristobal	pallidus
psittacula_affinis	psittacula
psittacula_habeli	psittacula
psittacula_psittacula	psittacula
heliobatesIsabela	heliobates
barbadensis	barbadensis
bicolor	bicolor
pallidusSanta_Cruz	pallidus
