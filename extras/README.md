# Cluster status scripts

If snakemake is having trouble detecting job failures, you can provide a custom
script to `--cluster-status`. You can either do this at the command-line or add
it to your `config.yml`.

**Important:** To use any of these, you must add the flag `--parsable` to the
call to `sbatch` in the field `cluster` in `config.yml`

**Important:** These scripts must be executable: `chmod +x <script>`

Sources:

* [Snakemake documentation for `--cluster-status`][cluster-status]
* [`slurm-status.py` from official Slurm profile][slurm-status.py]

Scripts:

* `status-sacct.sh` - Bash script that uses `sacct` to determine job status
  (recommended)

* `status-sacct.py` - Python script that uses `sacct` to determine job status

* `status-scontrol.sh` - Bash script that uses `scontrol` to determine job
  status

* `status-sacct-multi.sh` - Bash script that uses `sacct` to determine job
  status in a multi-cluster setup

* `status-sacct-robust.sh` - Bash script that re-runs `sacct` multiple times if
  it fails to return a valid status

I prefer to keep scripts as simple as possible. However, if none of the above
simple scripts are sufficient for your use case, I recommend you try one of the
following available status scripts:

* [LUMC/slurm-cluster-status](https://github.com/LUMC/slurm-cluster-status)

* [`slurm-status.py`][slurm-status.py] from the official profile

[cluster-status]: https://snakemake.readthedocs.io/en/stable/tutorial/additional_features.html#using-cluster-status
[slurm-status.py]: https://github.com/Snakemake-Profiles/slurm/blob/master/%7B%7Bcookiecutter.profile_name%7D%7D/slurm-status.py
