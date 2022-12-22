#!/bin/bash
set -eu

# Create many FASTQ files as input for Snakemake

mkdir -p output/fastq/
touch output/fastq/sample{1..20000}.fastq
