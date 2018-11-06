#!/bin/bash
#SBATCH --mem=4G
#SBATCH -p noor
#SBATCH --cpus-per-task=1
#SBATCH -J adapt_

reps=10

for i in `seq 1 $reps`; do
	sbatch run_sims_duke.sh
done
