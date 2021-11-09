#!/bin/bash
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=2G
#SBATCH --cpus-per-task=8
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=qc_atac
#SBATCH --partition=short
#SBATCH --array=0-23

# Program configuration
__author__='Babacar Ndao'
__email__='babacar.ndao@etu.uca.fr'
__credits__=["Babacar Ndao"]
__license__='GPL3'
__maintainer__='Babacar Ndao'
__status__='Development'
__version__='0.0.1'

echo 'Quality control'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

IFS=$'\n\t'

# Upload whatever required packages
module load java/oracle-1.7.0_79 fastqc/0.11.7 

echo "Set up directories ..." >&2
# Set up data and result directories
# Run QC on trimmed data
DATA_DIR="$HOME"/results/atacseq/trim

echo "Set up an array with all fastq.gz sequence files..." >&2
tab=($(ls "$DATA_DIR"/*/*trim*.fastq.gz))
echo "tab = " >&2
printf '%s\n' "${tab[@]}" >&2

# Set up the temporary directory
#SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"

if [[ "${tab[$SLURM_ARRAY_TASK_ID]}" =~ "trim_paired" ]] ; then
   echo "Paired expression found in filename in trim directory."
   shortname=($(basename "${tab[$SLURM_ARRAY_TASK_ID]}" _trim_paired.fastq.gz ))
elif [[ "${tab[$SLURM_ARRAY_TASK_ID]}" =~ "trim_unpaired" ]] ; then
   echo "Unpaired expression found in filename in trim directory."
   shortname=($(basename "${tab[$SLURM_ARRAY_TASK_ID]}" _trim_unpaired.fastq.gz ))
else 
   echo "No paired or unpaired match expression in filename."
fi

SCRATCHDIR=/storage/scratch/"$USER"/"$shortname/fastqc-post"

OUTPUT="$HOME"/results/atacseq/qc/"$shortname"
mkdir -p "$OUTPUT"
# Look for empty result directory
#if [ -d "$OUTPUT/fastqc-post" ]
#then
#    if [ "$(ls -A $OUTPUT/fastqc-post)" ]; then
#    echo "$OUTPUT/fastqc-post is not empty and must be cleaned."
#    rm -rf "$OUTPUT"/fastqc-post
#    else
#    echo "Directory $OUTPUT/fastq-post is empty."
#    fi
#fi

mkdir -p -m 700 "$SCRATCHDIR"

cd "$SCRATCHDIR"
mkdir -p "$SCRATCHDIR"

# Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2

echo "Run the post-trimming quality control on "${tab[$SLURM_ARRAY_TASK_ID]}" ... " >&2
fastqc "${tab[$SLURM_ARRAY_TASK_ID]}" -dir "$SCRATCHDIR" -o "$SCRATCHDIR"
cp -r "$SCRATCHDIR" "$OUTPUT"

# Cleaning in case something went wrong
rm -rf  "$SCRATCHDIR"

echo "Stop job : "`date` >&2



