#!/bin/bash
#SBATCH --time=0:40:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=12G
#SBATCH --cpus-per-task=6
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=deeptools
#SBATCH --partition=short

echo 'Exploration des données'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail
module purge
module load gcc/4.8.4 python/2.7.9 numpy/1.9.2 samtools/1.3 deepTools/3.1.2


echo "Set up directories ..." >&2
#Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"
OUTPUT="$HOME"/results/atacseq/expl_data
mkdir -p "$OUTPUT"
#Set up data directory
DATA_DIR="/home/users/student05/results/atacseq/bam_net"
#Run the program
tab="$DATA_DIR"/*/*mapped*.bam

multiBamSummary bins -b $tab \
-o "$SCRATCHDIR"/results.npz

plotCorrelation \
-in "$SCRATCHDIR"/results.npz \
--corMethod pearson --skipZeros \
--plotTitle "Pearson Correlation of Average Scores Per Transcript" \
--whatToPlot scatterplot \
-o "$SCRATCHDIR"/scatterplot_PearsonCorr_bigwigScores.png   \
--outFileCorMatrix "$SCRATCHDIR"/PearsonCorr_bigwigScores.tab

plotCorrelation \
    -in "$SCRATCHDIR"/results.npz \
    --corMethod spearman --skipZeros \
    --plotTitle "Spearman Correlation of Read Counts" \
    --whatToPlot heatmap --colorMap RdYlBu --plotNumbers \
    -o "$SCRATCHDIR"/heatmap_SpearmanCorr_readCounts.png   \
    --outFileCorMatrix "$SCRATCHDIR"/SpearmanCorr_readCounts.tab

plotCoverage --bamfiles $tab \
    --plotFile "$SCRATCHDIR"/coverage \
    --plotTitle "Coverage" \
    --outRawCounts "$SCRATCHDIR"/coverage.tab \
    --ignoreDuplicates

echo "List SCRATCHDIR: "
ls "$SCRATCHDIR" >&2
# Move results in one's directory
mv  "$SCRATCHDIR" "$OUTPUT"
echo "Stop job : "`date` >&2

