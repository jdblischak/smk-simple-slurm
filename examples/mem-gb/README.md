# Specify memory in GB

By default, the argument `--mem` to `sbatch` expects memory to be specified in
MB. However, you can change this by appending a unit to the argument. For GB,
you can append `g`, `G`, or `GB`. This example uses `G` to specify the memory in
GB.

The default `config.v8+.yaml` provided by smk-simple-slurm uses MB, but you can
switch to using GB with the following steps:

* Append a `G` to the argument `--mem` in `config.v8+.yaml`
* Change the value in `default-resources` in `config.v8+.yaml` from `1000` to `1`
  (or any other reasonable value of GB)
* (Recommended) Change all instances of `mem_mb` to `mem_gb` in both
  `config.v8+.yaml` and the `Snakefile`. This isn't technically required since the
  only requirement is consistency, but `mem_gb` will make the pipeline
  configuration more interpretable others, including future you

Alternatively you could instead use strings everywhere, eg `mem_gb=1G`. The main
downside of this approach is that you wouldn't be able to do any computations
with the memory value, eg to [increase the memory for retries based on the
variable `attempt`][attempt].

[attempt]: https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html?highlight=attempt#resources

**Note:** This example was inspired by [Issue
#11](https://github.com/jdblischak/smk-simple-slurm/issues/11)

However, there is a downside to specifying the memory to Slurm in GB. The
resource `mem_mb` is one of Snakemake's [standard
resources][standard-resources]. This means that you will always see `mem_mb`
defined when your jobs are submitted to the cluster. This has no effect since
you are passing `mem_gb` to `sbatch`, but of course it is distracting and
confusing.

[standard-resources]: https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#standard-resources

The example `Snakefile` submits 3 jobs: `default_mem` uses the default memory
defined in `default-resources`, `rule_specific_mem` specifies a custom memory
for that rule only, and `dynamic_resources` requests more memory at each
subsequent attempt (it will always fail).

```sh
# Sumbit the jobs
snakemake --profile simple/

# Confirm the correct number of GB was allocated by Slurm
grep -R "^Requested memory" logs/
grep -R "^Provided memory" logs/
```
