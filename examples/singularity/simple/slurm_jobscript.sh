#!/bin/bash
# properties = {properties}
export SINGULARITY_BIND=$SINGULARITY_BIND,$TMPDIR
{exec_job}
