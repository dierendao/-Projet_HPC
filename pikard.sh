#!/bin/bash
#SBATCH --time=0:40:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=12G
#SBATCH --cpus-per-task=6
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=trim_atac
#SBATCH --partition=short
#SBATCH --array=0-5

echo 'Cleaning of the alignments'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail
module purge
module load gcc/8.1.0 java/oracle-1.11.0_11 picard/2.18.25 samtools/1.9

echo "Set up directories ..." >&2
#Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"
OUTPUT="$HOME"/results/atacseq/bam_net
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"

#Set up data directory
DATA_DIR="/home/users/student05/results/atacseq/bowtie2"
#Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2
tab=($(ls "$DATA_DIR"/*/*mapped*.bam))
SHORTNAME=($(basename "${tab[$SLURM_ARRAY_TASK_ID]}" .bam))

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

