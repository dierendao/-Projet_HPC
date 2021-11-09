#!/bin/bash
#SBATCH --time=0:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=2G
#SBATCH --cpus-per-task=1
#SBATCH -o log/slurmjob-%j
#SBATCH --job-name=multiqc
#SBATCH --partition=short

# Program configuration
__author__='Babacar Ndao'
__email__='babacar.ndao@etu.uca.fr'
__credits__=["Babacar Ndao"]
__license__='GPL3'
__maintainer__='Babacar Ndao'
__status__='Development'
__version__='0.0.1'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

IFS=$'\n\t'

#Set up whatever package we need to run with
module purge
module load gcc/8.1.0 python/3.7.1 openblas/0.3.3 MultiQC/1.7


echo "Set up directories ..." >&2
#Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"
OUTPUT="$HOME"/results/atacseq/multiQC/

mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"

echo 'Creating report for Fastq quality ... ' >&2

multiqc "$HOME"/results/atacseq/qc -i multiQC -o "$SCRATCHDIR"
echo 'Done' >&2
#Move results in one's directory
mv  "$SCRATCHDIR" "$OUTPUT"

echo "Stop job : "`date` >&2
