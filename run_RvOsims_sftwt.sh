#!/bin/bash
#SBATCH --job-name=RvOsims_sfwt  # name of the job
#SBATCH --partition=defq         # partition to be used (defq, gpu or intel)
#SBATCH --time=04:00:00          # walltime (up to 96 hours)
#SBATCH --nodes=1                # number of nodes
#SBATCH --ntasks=4		 # number of parallel processes
#SBATCH --mem-per-cpu=40G        # increase memory available to each process

module load gcc
module load R
cd /home/alston92/scratch/RvO    # path where executable and data is located

date
echo "Initiating walltime test script"
Rscript RvO_sims_sf_test_wt.R $1       # name of script
echo "Walltime script complete"
date
