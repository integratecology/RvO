#!/bin/bash
#SBATCH --job-name=RvOsims_sf    # name of the job
#SBATCH --partition=defq         # partition to be used (defq, gpu or intel)
#SBATCH --time=1:30:00           # walltime (up to 96 hours)
#SBATCH --nodes=1                # number of nodes
#SBATCH --ntasks-per-node=1	 # number of parallel processes
#SBATCH --mem-per-cpu=64G       # increase memory available to each process
#SBATCH --cpus-per-task=1
#SBATCH --array=401


module load gcc
module load R
cd /home/alston92/scratch/RvO    # path where executable and data is located

if [ -f sims_RvO_sf.csv ]; then
	echo "sims_RvO_sf.csv already exists! continuing..."
else
	echo "creating results file sims_sf.csv"
	echo "sim_no,samp_freq,agde_area,krige_area" > sims_RvO_sf.csv
fi

date
echo "Initiating sampling frequency script"
Rscript RvO_sims_full_sf.R ${SLURM_ARRAY_TASK_ID}        # name of script
echo "Sampling frequency script complete"
date
