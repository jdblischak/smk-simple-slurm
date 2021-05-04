#!/usr/bin/env python

# Summarize jobs-per-second results

import collections
import statistics

submit_times = []

with open(snakemake.input[0]) as fin:
   for line in fin:
       submit_times.append(int(line.strip()))

jobs_per_second = collections.Counter(submit_times).values()

with open(snakemake.output[0], 'w') as fout:
    fout.write("Jobs-per-second results from submitting %d embarrassingly parallel jobs\n"%(len(submit_times)))
    fout.write("min:\t%d\n"%(min(jobs_per_second)))
    fout.write("median:\t%.1f\n"%(statistics.median(jobs_per_second)))
    fout.write("mean:\t%.1f\n"%(statistics.mean(jobs_per_second)))
    fout.write("max:\t%d\n"%(max(jobs_per_second)))
