#!/bin/bash
#SBATCH --job-name=RvOsims_sd    # name of the job
#SBATCH --partition=defq,intel   # partition to be used (defq, gpu or intel)
#SBATCH --time=1:00:00           # walltime (up to 96 hours)
#SBATCH --nodes=1                # number of nodes
#SBATCH --ntasks-per-node=1	 # number of parallel processes
#SBATCH --mem-per-cpu=16G        # increase memory available to each process
#SBATCH --cpus-per-task=1
#SBATCH --array=1-400%40


module load gcc
module load R
cd /home/alston92/scratch/RvO    # path where executable and data is located

if [ -f sims_RvO_sd.csv ]; then
	echo "sims_RvO_sd.csv already exists! continuing..."
else
	echo "creating results file sims_sf.csv"
	echo "sim_no,samp_dur,agde_area,krige_area" > sims_RvO_sd.csv
fi

date
echo "Initiating sampling duration script"
Rscript RvO_sims_full_sd.R ${SLURM_ARRAY_TASK_ID}        # name of script
echo "Sampling duration script complete"
date
