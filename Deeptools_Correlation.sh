#!/bin/bash
#SBATCH --time=5:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=12G
#SBATCH --cpus-per-task=6
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=deeptools
#SBATCH --partition=short

# Program configuration
__author__='Babacar Ndao'
__email__='babacar.ndao@etu.uca.fr'
__credits__=["Babacar Ndao"]
__license__='GPL3'
__maintainer__='Babacar Ndao'
__status__='Development'
__version__='0.0.1'

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
OUTPUT="$HOME"/results/atacseq/expl_data_correlation
mkdir -p "$OUTPUT"
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"
#Set up data directory
NPZ="$HOME"/results/atacseq/npz
#Run the program
#Plot Pearson
plotCorrelation \
-in "$NPZ"/*/results.npz \
--corMethod pearson --skipZeros \
--plotTitle "Pearson Correlation of Average Scores Per Transcript" \
--whatToPlot scatterplot \
-o "$SCRATCHDIR"/scatterplot_PearsonCorr_bigwigScores.png   \
--outFileCorMatrix "$SCRATCHDIR"/PearsonCorr_bigwigScores.tab
#Plot Spearman
plotCorrelation \
    -in "$NPZ"/*/results.npz \
    --corMethod spearman --skipZeros \
    --plotTitle "Spearman Correlation of Read Counts" \
    --whatToPlot heatmap --colorMap RdYlBu --plotNumbers \
    -o "$SCRATCHDIR"/heatmap_SpearmanCorr_readCounts.png   \
    --outFileCorMatrix "$SCRATCHDIR"/SpearmanCorr_readCounts.tab

echo "List SCRATCHDIR: "
ls "$SCRATCHDIR" >&2
# Move results in one's directory
mv  "$SCRATCHDIR" "$OUTPUT"
echo "Stop job : "`date` >&2

