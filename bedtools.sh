#!/bin/bash
#SBATCH --time=0:40:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=12G
#SBATCH --cpus-per-task=6
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=trim_atac
#SBATCH --partition=short
#SBATCH --array=0-2

# Program configuration
__author__='Babacar Ndao'
__email__='babacar.ndao@etu.uca.fr'
__credits__=["Babacar Ndao"]
__license__='GPL3'
__maintainer__='Babacar Ndao'
__status__='Development'
__version__='0.0.1'

echo "Identification les sites d'accessibilité"

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail
module purge
module load gcc/4.8.4 bedtools/2.27.1

echo "Set up directories ..." >&2
#Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"
OUTPUT="$HOME"/results/atacseq/BedTools
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"


#Set up data directory
DATA_DIR="$HOME"/results/atacseq/MACS2
#Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2
tab1=($(ls "$DATA_DIR"/*/*24h*_mapped_*.bed))
tab2=($(ls "$DATA_DIR"/*/*0h*_mapped_*.bed))
SHORTNAME=($(basename "${tab1[$SLURM_ARRAY_TASK_ID]}" .bed  ))

# intersect the peaks from both experiments.
# -f 0.50 combined with -r requires 50% reciprocal overlap between the
# peaks from each experiment.
bedtools intersect -a ${tab2[$SLURM_ARRAY_TASK_ID]} \
 -b ${tab1[$SLURM_ARRAY_TASK_ID]} \
 -f 0.50 -r > "$SCRATCHDIR"/"$SHORTNAME"_both.bed

bedtools intersect -v -a ${tab2[$SLURM_ARRAY_TASK_ID]} \
 -b ${tab1[$SLURM_ARRAY_TASK_ID]} \
 -f 0.50 -r > "$SCRATCHDIR"/"$SHORTNAME"_0H_Unique.bed

bedtools intersect -v -a ${tab1[$SLURM_ARRAY_TASK_ID]} \
 -b ${tab2[$SLURM_ARRAY_TASK_ID]} \
 -f 0.50 -r > "$SCRATCHDIR"/"$SHORTNAME"_24H_Unique.bed



echo "List SCRATCHDIR: "
ls "$SCRATCHDIR" >&2
# Move results in one's directory
mv  "$SCRATCHDIR" "$OUTPUT"
echo "Stop job : "`date` >&2
