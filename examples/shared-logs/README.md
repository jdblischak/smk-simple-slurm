# Insert the current Snakefile into the log file path

If you share the same profile `config.yaml` across multiple separate Snakefiles,
it is convenient to separate the log files per pipeline. The key to achieving
this is to dynamically obtain the name of the current Snakefile and insert it
into the log file path with ``logs/`basename {workflow.main_snakefile}`/{rule}``

```sh
# Run each separate pipeline with the same profile
snakemake --profile shared/ --snakefile qc.snakefile
snakemake --profile shared/ --snakefile impute.snakefile
snakemake --profile shared/ --snakefile phase.snakefile

# View the log files
ls -R logs/
```

**Note:** This example was inspired by [Issue 12][issue-12]

[issue-12]: https://github.com/jdblischak/smk-simple-slurm/issues/12
