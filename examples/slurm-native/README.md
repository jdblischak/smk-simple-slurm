# Native Slurm support

[Native support for Slurm][docs-native-slurm] was added in [Snakemake 7.19.0 (2022-12-13)][7.19.0], but has since been removed by the breaking changes in [Snakemake 8.0.0][8.0.0].

[docs-native-slurm]: https://snakemake.readthedocs.io/en/stable/executing/cluster.html#executing-on-slurm-clusters
[7.19.0]: https://github.com/snakemake/snakemake/blob/main/CHANGELOG.md#7190-2022-12-13
[8.0.0]: https://github.com/snakemake/snakemake/blob/main/CHANGELOG.md#800-2023-12-20


With these breaking changes, it is a little more difficult to use slurm (or any cluster, for that matter).

With the introduction of the `--cluster-generic-*-cmd` flags and yaml keys, it no longer makes sense to create an example for native Slurm support, as all cluster support is abstracted into these keys and flags.


If you were previously using the native Slurm support and would like to use `snakemake>8.0.0`, you should rename your `config.yaml` to `config.v8+.yaml` and change the keys according to the following documentation:
-  The general [smk-simple-slurm](https://github.com/jdblischak/smk-simple-slurm) repository
-  The default [smk-simple slurm `config.v8.yaml` example](https://github.com/jdblischak/smk-simple-slurm/blob/main/simple/config.v8+.yaml)
- The [snakemake migration documentation][8.0.0]


If you need help, please [open an issue](https://github.com/jdblischak/smk-simple-slurm/issues) on this repository (and optionally ping/mention [@JoshLoecker](https://github.com/JoshLoecker), as [@jdblischak](https://github.com/jdblischak) is very busy as of now).