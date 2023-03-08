# Log stdout and stderr to separate files

By default, both stdout and stderr are written to the same log file. If you'd
prefer to write stdout and stderr to separate files, you can pass the flag
`--error` in addition to `--output`

```
cluster:
  mkdir -p logs/{rule} &&
  sbatch
    --output=logs/{rule}/{rule}-{wildcards}-%j.out
    --error=logs/{rule}/{rule}-{wildcards}-%j.err
```

The example Snakefile contains a single rule that demonstrates writing to 1) an
output file, 2) an explicit logfile using the Snakemake `log` directive, 3)
stdout, and 4) stderr.

```sh
# Sumbit the job
snakemake --profile simple/

# View the files
cat output/test.txt
cat explict-logfile.txt
cat logs/example/*out
cat logs/example/*err
```

**Note:** This example was inspired by this
[Issue #14](https://github.com/jdblischak/smk-simple-slurm/issues/14)
