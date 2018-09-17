#!/bin/bash

#SBATCH --mem=220000
#SBATCH --cpus-per-task=20
#SBATCH -p noor
#SBATCH -J adapt_intro-%j
#SBATCH -o adapt_intro-%j.out

Rscript 01_process_output_files.R