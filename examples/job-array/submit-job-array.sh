#!/bin/bash
set -e

# Submit the Snakemake rules as a single job array

snakemake --summary > snakemake-summary.txt
awk --field-separator \
  '\t' '$3 == "process" && $7 == "update pending" {print $1}' \
  snakemake-summary.txt > files.txt

n=$(cat files.txt | wc -l)
echo "Submitting job array to create $n files"
n=$((n - 1)) # Bash arrays are 0-indexed

mkdir -p logs/smk-job-array

sbatch \
  --mem=100 \
  --job-name=smk-job-array \
  --output=logs/smk-job-array/%x-%A-%a.out \
  --array=0-$n \
  job-array.sh
