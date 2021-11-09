#!/bin/bash
#SBATCH --time=7:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=20G
#SBATCH --cpus-per-task=6
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=GC_Remove
#SBATCH --partition=short
#SBATCH --array=0-5

# Program configuration
__author__='Babacar Ndao'
__email__='babacar.ndao@etu.uca.fr'
__credits__=["Babacar Ndao"]
__license__='GPL3'
__maintainer__='Babacar Ndao'
__status__='Development'
__version__='0.0.1'

echo 'Correction of GC Biases'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

#Loading Modules
module purge
module load gcc/4.8.4 python/2.7.9 numpy/1.9.2 samtools/1.3 deepTools/3.1.2


echo "Set up directories ..." >&2
#Set up the temporary directory and output directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"
OUTPUT="$HOME"/results/atacseq/GC_cleaned
mkdir -p "$OUTPUT"
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"
#Set up data directory
DATA_DIR="$HOME"/results/atacseq/bam_net
#Set up 2bit genome directory
genome="/home/users/shared/databanks/bio/ncbi/genomes/Mus_musculus/Mus_musculus_GRCm38.p6/Mus_musculus_2020-7-9/2bit/all.2bit"

echo "Start on $SLURMD_NODENAME: "`date` >&2
tab=($(ls "$DATA_DIR"/*/*mapped*.bam))
SHORTNAME=($(basename "${tab[$SLURM_ARRAY_TASK_ID]}" .bam))

#Run the program
#Part I: Detecting GC Biases
computeGCBias \
-b ${tab[$SLURM_ARRAY_TASK_ID]} \
--effectiveGenomeSize 2652783500 \
-g "$genome" \
--GCbiasFrequenciesFile "$SCRATCHDIR"/"$SHORTNAME"_freq.txt
#Part II: Correcting GC Biases
correctGCBias \
-b ${tab[$SLURM_ARRAY_TASK_ID]} \
--effectiveGenomeSize 2652783500 \
-g "$genome" \
--GCbiasFrequenciesFile "$SCRATCHDIR"/"$SHORTNAME"_freq.txt \
-o "$SCRATCHDIR"/"$SHORTNAME"_gc_corrected.bam

#Indexing bam files
echo "Indexing bam file" >&2
samtools index -b "$SCRATCHDIR"/"$SHORTNAME"_gc_corrected.bam

echo "List SCRATCHDIR: "
ls "$SCRATCHDIR" >&2
# Move results in one's directory
mv  "$SCRATCHDIR" "$OUTPUT"
echo "Stop job : "`date` >&2
