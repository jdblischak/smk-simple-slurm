# Many input files

If you have a rule with many thousands of input files, your submitted job may
fail because the [job script is too
large](https://bugs.schedmd.com/show_bug.cgi?id=2198):

```
sbatch: error: Batch job submission failed: Pathname of a file, directory or other parameter too long
```

This is because the default jobscript injects all the properties directly into
the subitted job script:

```
$ cat $CONDA_PREFIX/lib/python3.9/site-packages/snakemake/executors/jobscript.sh
#!/bin/sh
# properties = {properties}
{exec_job}
```

You can avoid this by creating a custom jobscript file that omits the comment
with the job properties.

**Note:** This example was inspired by this
[Issue](https://github.com/Snakemake-Profiles/slurm/issues/87)

The example Snakefile creates 150k files, which are then the input to a single
rule named "combine". The error is avoided by using the custom jobscript
`simple/jobscript-wo-properties.sh`.

You could run the Snakefile to create these 150k files, but I don't recommend
this. To avoid taxing Slurm just for a demonstration, I made the rule that
creates each of the 150k a local rule that isn't submitted. Thus if you do
run the Snakefile, you'll want to request many local cores.

```sh
snakemake --profile simple/ --local-cores 28
```

But this would still take a long time. Instead I'd recommend artificially
creating the 150k input files and then executing Snakemake only for the final
rule.

```sh
touch output/{1..150000}.txt
snakemake --profile simple/
```

To instead reproduce the Slurm error, comment out the field `jobscript` in
`simple/config.yaml`.

**Note:** If your rule that has many input files isn't computationally
intensive, e.g. it simply concatenates all the files, then the _most_ simple
solution would be to make it a local rule and avoid submitting to Slurm
altogether.
