#!/bin/bash
set -e

# Run a single rule in the job array

all=(`cat files.txt`)
output=${all[$SLURM_ARRAY_TASK_ID]}

echo "Creating $output"

snakemake \
  --nolock \
  -j 1 \
  "$output"
