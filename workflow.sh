#! /bin/bash
#cd "$(dirname "$0")"

echo 'Team 4 (Universite Clermont Auvergne, Mesocentre)'
echo 'Date: Fall Master course 2021 '
echo 'Object: Sample case of ATACseq workflow showing job execution and dependen
cy handling.'
echo 'Inputs: paths to scripts qc, trim and bowtie2, atac_rem_dup, atacseq_deepl, atac_macs, atac_bedtools'
echo 'Outputs: trimmed fastq files, QC HTML files and BAM files, BED files, .npz files, .tab files, .png files, (.narrowPeak, .xls, .r files)'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose

IFS=$'\n\t'

echo "Launching Atac-seq Workflow"
# first job - no dependencies
# Initial QC
jid1=$(sbatch --parsable scripts/atac_qc_init.slurm)
echo "$jid1 : Initial Quality Control"

# Trimming
jid2=$(sbatch --parsable --dependency=afterok:$jid1 scripts/atac_trim.slurm)
echo "$jid2 : Trimming with Trimmomatic tool"

# Post QC
jid3=$(sbatch --parsable --dependency=afterok:$jid2 scripts/atac_qc_post.slurm)
echo "$jid3 : Post control_quality"

# MultiQc Report
jidQC=$(sbatch --parsable --dependency=afterok:$jid3 scripts/multiqc.sh)
echo "$jidQC : Generating MultiQC Report"

# Bowtie2 Alignment
jid4=$(sbatch --parsable --dependency=afterok:$jid3 scripts/atac_bowtie2.slurm)
echo "$jid4 : Sequence Alignment Using Bowtie2 "

# Cleaning Alignments
jid5=$(sbatch --parsable --dependency=afterok:$jid4 scripts/pikard.sh)
echo "$jid5 : Cleaning alignments Using Picard Tools"

# Eliminating GC biases
jidBias=$(sbatch --parsable --dependency=afterok:$jid5 scripts/GC_Remove.sh)
echo "$jidBias : Eliminating GC biases Using DeepTools"

#  Data Exploitation
jid6=$(sbatch --parsable --dependency=afterok:$jidBias scripts/deeptools.sh)
echo "$jid6 : Generating NPZ file"

jid6_1=$(sbatch --parsable --dependency=afterok:$jid6 scripts/Deeptools_Correlation.sh)
echo "$jid6_1 : Ploting Correlation"

jid6_2=$(sbatch --parsable --dependency=afterok:$jid6 scripts/Deeptools_Coverage.sh)
echo "$jid6_2 : Plotting Coverage"

#  Identification of dna accessibility sites
jid7=$(sbatch --parsable --dependency=afterok:$jid6_2 scripts/macs2.sh)
echo "$jid7 : Identification of dna accessibility sites using MACS2"

#  Identification of common and unique accessibility sites
jid8=$(sbatch --parsable --dependency=afterok:$jid7 scripts/bedtools.sh)
echo "$jid8 : Identification of common and unique accessibility sites using BedTools"

#  Info on workflow
jid9=$(sbatch --parsable --dependency=afterok:$jid8 scripts/sacct.sh)
echo "$jid9 : Getting general info from worflow"


echo "Stop job : "`date` >&2