#!/bin/bash
#SBATCH --account=def-rieseber
#SBATCH --time=1:00:00
#SBATCH --job-name=SLIM
#SBATCH --array=1-200%100
#SBATCH --mem=120G
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --output=/scratch/gowens/adaptive_introgression/logs/%A.%a.slim_log

cd /scratch/gowens/adaptive_introgression

perl run_slim_sim_v5.pl

