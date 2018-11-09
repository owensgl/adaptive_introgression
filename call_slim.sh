#!/bin/bash
#SBATCH --account=rrg-rieseber-ac
#SBATCH --time=2:00:00
#SBATCH --job-name=SLIM
#SBATCH --array=1-300%100
#SBATCH --mem=110G
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --output=/scratch/gowens/adaptive_introgression/logs/%A.%a.slim_log

cd /scratch/gowens/adaptive_introgression

perl run_slim_sim_v4.pl

