# Job grouping

Snakemake has the feature to [group jobs][grouping]. This is convenient when you
have rule with a short execution time that has to be run many times. In this
situation, the rule would spend more time in the Slurm queue compared to
actually executing.

[grouping]: https://snakemake.readthedocs.io/en/stable/executing/grouping.html

However, when Snakemake groups multiple instances of a rule into a group to be
submitted to Slurm, many of the job attributes like the name of the rule and its
wildcards are no longer clearly defined. This means you can't use these
attributes when passing arguments to `sbatch`, e.g.
`--job-name=smk-{rule}-{wildcards}` and
`--output=logs/{rule}/{rule}-{wildcards}-%j.out`. This will make it more
difficult to interpret the names of the queued jobs and the output files.

Also note that Snakemake will sum resources like `mem_mb` and `threads`. Thus
you must be careful to avoid requesting impossible configurations like a compute
node with hundreds of cores (which even if possible on your HPC cluster, would
make it take way longer than necessary for your job to be scheduled). To avoid
this, set `--cores` to the maximum number of threads used by any of the
non-grouped rules. This way the grouped jobs will at most use that many cores
(as well as a maximum `mem_mb` of (`mem_mb` per rule times `--cores`)).

The example Snakefile submits 3 very different types of rules:

* Rule `exampleRuleSeparate` is a typical rule that gets submitted once per
  output file (in this case, 1000 times). Because of `jobs: 500` in
  `simple/config.yaml`, up to 500 of these can be in the Slurm queue at once

* Rule `exampleRuleToGroup` is a grouped rule. 100 rules are included in each
  grouped job submitted to Slurm. Because of `cores: 14` in
  `simple/config.yaml`, each grouped job only requests 14 cores and 1400 MB of
  memory (per rule `mem_mb` of 100 * 14 cores)

* Rule `multiThreadedRule` is a single rule that can utilize 14 cores for
  parallel processing. If you wanted to use more cores, you would also need to
  increase the values of `--cores`, but note that this would also result in each
  of the grouped jobs to also request this many cores

```sh
snakemake --profile simple/

# Confirm 1000 output files were created by the 10 grouped jobs
ls output/grouped/ | wc -l
## 1000

# Confirm only 10 jobs were submitted to Slurm
# (1011 = 10 exampleRuleToGroup + 1 multiThreadedRule + 1000 exampleRuleSeparate)
ls logs/ | wc -l
## 1011
```

**Note:** This example was inspired by the discussion in [Issue #10][issue-10]
and [Snakemake Issue #872][snakemake-issue-872]

[issue-10]: https://github.com/jdblischak/smk-simple-slurm/issues/10
[snakemake-issue-872]: https://github.com/snakemake/snakemake/issues/872

**Note:** This example requires Snakemake version 7.11+ to properly allocate the
threads and memory for the grouped jobs
