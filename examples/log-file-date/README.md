# Insert the current date into the log file path

If you regularly re-run your pipeline, you may want to organize the log files by
date. This can be achieved by inserting `date +"%d-%m-%y"` into the `cluster`
field in `config.v8+.yaml`, both in the call to `mkdir` and to the `--output` flag
for `sbatch`.

```yaml
executor: cluster-generic
cluster-generic-submit-cmd:
  mkdir -p logs/`date +"%d-%m-%y"`/{rule} &&
  sbatch
    --output=logs/`date +"%d-%m-%y"`/{rule}/{rule}-{wildcards}-%j.out
```

The example submits a simple pipeline and saves the log files with the pattern
`logs/DD-MM-YYYY/rule/rule-wildcards-jobid.out`.

```sh
# Today's date as DD-MM-YYYY
date +"%d-%m-%y"

# Sumbit the jobs
snakemake --profile simple/

# View the log files
ls -R logs/
```

**Note:** This example was inspired by this
[Issue](https://github.com/Snakemake-Profiles/slurm/issues/88)
