#!/bin/bash
#SBATCH --job-name=RAM_test      # name of the job
#SBATCH --partition=defq         # partition to be used (defq, gpu or intel)
#SBATCH --time=08:00:00          # walltime (up to 96 hours)
#SBATCH --nodes=1                # number of nodes
#SBATCH --ntasks=1		 # number of parallel processes
#SBATCH --mem-per-cpu=80G        # increase memory available to each process

module load gcc
module load R
cd /home/alston92/scratch/RvO    # path where executable and data is located

date
echo "Initiating RAM test script"
Rscript RvO_sims_full_sf.R        # name of script
echo "RAM test script complete"
date
