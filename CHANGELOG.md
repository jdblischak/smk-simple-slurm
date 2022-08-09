## dev

New status script `status-sacct-robust.sh` that re-runs `sacct` multiple times
if it fails to return a valid status. This is more robust and is recommended if
you notice Snakemake unexpectedly re-submits jobs that are still pending or
running. See [Issue #9] for discussion

[issue-9]: https://github.com/jdblischak/smk-simple-slurm/issues/9

Example with [job grouping][grouping]

[grouping]: https://snakemake.readthedocs.io/en/stable/executing/grouping.html

Link to [Christian's profile for AWS ParallelCluster][snakemake-aws-parallelcluster-slurm]

[snakemake-aws-parallelcluster-slurm]: https://github.com/cbrueffer/snakemake-aws-parallelcluster-slurm

Example that uses pinned conda environments (`pinned-conda-envs`) (requires
minimum of Snakemake version 7.8.0)

Example that inserts the current date in the log file paths (`log-file-date`)

Example rule with thousands of input files (`many-input-files`)

## v1.2.0 - 2022-03-09

Full support for custom status scripts in a multi-cluster setup (requires
minimum of Snakemake version 7.1.1)

Example with [cluster-cancel][] (requires minimum of Snakemake version 7.0.0)

[cluster-cancel]: https://snakemake.readthedocs.io/en/stable/tutorial/additional_features.html#using-cluster-cancel

## v1.1.0 - 2021-09-17

Reduce the default settings for `max-jobs-per-second` and
`max-status-checks-per-second` to avoid stressing Slurm

Example of running rules in Singularity containers
([CreRecombinase](https://github.com/CreRecombinase),
[#2](https://github.com/jdblischak/smk-simple-slurm/pull/2))

## v1.0.0 - 2021-06-07

Initial release
