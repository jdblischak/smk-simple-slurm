fname = "output/qc/result.txt"


rule all:
    input:
        fname,


rule create:
    output:
        fname,
    shell:
        "touch {output}"
