niter=16
nthreads=4
njobs=$((niter / nthreads))

echo "submitting $njobs separate jobs to SLURM."

for i in `seq $njobs`
	do echo "submitting job $i "
	sbatch run_RvOsims_sftwt.sh $i
done
