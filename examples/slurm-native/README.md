# Native Slurm support

[Native support for Slurm][docs-native-slurm] with the flag `--slurm` was added
in [Snakemake 7.19.0 (2022-12-13)][7.19.0].

[docs-native-slurm]: https://snakemake.readthedocs.io/en/stable/executing/cluster.html#executing-on-slurm-clusters
[7.19.0]: https://github.com/snakemake/snakemake/blob/main/CHANGELOG.md#7190-2022-12-13

This example demonstrates how to use the new `--slurm` flag within the
smk-simple-slurm framework. Since it is also simple, it is very compatible! The
most noticeable difference is that the log files are saved to
`.snakemake/slurm_logs/` (each rule gets its own subdirectory, but the wildcards
aren't included in the filenames). The native Slurm support also prefers to
explicitly know your Slurm account. If you don't provide it, it will

```sh
# If you don't know your Slurm account, find it here
sacctmgr show user $USER accounts
# and define it in simple/config.yaml

snakemake --profile simple/

ls .snakemake/slurm_logs/
## rule_rule1  rule_rule2  rule_rule3
```

Note that you can either specify `--slurm` and `--default-resources` at the
command line or in `simple/config.yaml`. Don't try to mix and match. When I
defined `--slurm` at the command line, the `default-resources` in
`simple/config.yaml` were ignored.

Also note that I often got a `KeyError` from `slurm_submit.py`. If this happens
to you, try re-running.
