#!/bin/bash
#SBATCH --time=7:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=12G
#SBATCH --cpus-per-task=6
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=trim_atac
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

echo 'Cleaning of the alignments'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

module purge
#Loading modules
module load gcc/8.1.0 java/oracle-1.11.0_11 picard/2.18.25 samtools/1.9

echo "Set up directories ..." >&2
#Set up the temporary directory and output directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"
OUTPUT="$HOME"/results/atacseq/bam_net
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"

#Set up data directory
DATA_DIR="$HOME"/results/atacseq/bowtie2

echo "Start on $SLURMD_NODENAME: "`date` >&2
tab=($(ls "$DATA_DIR"/*/*mapped*.bam))
SHORTNAME=($(basename "${tab[$SLURM_ARRAY_TASK_ID]}" .bam))

#Run the program
java -jar /opt/apps/picard-2.18.25/picard.jar MarkDuplicates \
I=${tab[$SLURM_ARRAY_TASK_ID]} \
O="$SCRATCHDIR"/"$SHORTNAME"_dup_rem.bam \
M="$SCRATCHDIR"/"$SHORTNAME"_sub_dups.txt \
REMOVE_DUPLICATES=true

echo "Indexing bam file" >&2
samtools index -b "$SCRATCHDIR"/"$SHORTNAME"_dup_rem.bam
echo "List SCRATCHDIR: "
ls "$SCRATCHDIR" >&2
# Move results in one's directory
mv  "$SCRATCHDIR" "$OUTPUT"
echo "Stop job : "`date` >&2

