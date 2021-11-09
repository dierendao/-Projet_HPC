#!/bin/bash
#SBATCH --time=0:40:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=2G
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=Sacct
#SBATCH --partition=short

# Program configuration
__author__='Babacar Ndao'
__email__='babacar.ndao@etu.uca.fr'
__credits__=["Babacar Ndao"]
__license__='GPL3'
__maintainer__='Babacar Ndao'
__status__='Development'
__version__='0.0.1'

sacct --format=jobid,elapsed,ncpus,AllocCPUS,CPUTime,TotalCPU,ReqMem,ntasks,state,User > "$HOME"/results/atacseq/Info_workflow.txt
