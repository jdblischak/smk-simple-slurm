# Pin packages in conda environments

For increased reproducibility and portability, you can [pin the packages in your
conda environments][pinned]. This prevents future updates to conda packages from
breaking the environments, and it's also faster to create the environments since
conda doesn't have to determine which versions to install.

```sh
# Pin the conda environments (already done for this example)
snakedeploy pin-conda-envs envs/py2r3.yaml envs/py3r4.yaml
```

**Note:** This [feature][pinned] was added in Snakemake 7.8.0

[pinned]: https://snakemake.readthedocs.io/en/stable/snakefiles/deployment.html#freezing-environments-to-exactly-pinned-packages

**Note:** The smk-simple-slurm profile isn't doing anything special in regards
to the feature to pin conda environments. This example simply serves as
documentation on how to implement it

```sh
# Sumbit the jobs
snakemake --profile simple/

# Confirm Python and R versions
find output/ -type f | xargs head -n 1
```
