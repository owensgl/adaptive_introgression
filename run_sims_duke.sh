#!/bin/bash
#SBATCH --mem=16G
#SBATCH --cpus-per-task=10
#SBATCH -J adapt
#SBATCH -o tmp/adapt-%j.out

perl run_slim_sim_v4.pl
