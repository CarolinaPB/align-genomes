configfile: "config.yaml"

pipeline = "align-genomes" # replace your pipeline's name

include: "/lustre/nobackup/WUR/ABGC/moiti001/snakemake-rules/create_file_log.smk"

workdir: config["OUTDIR"]
MUMMER = "/lustre/nobackup/WUR/ABGC/moiti001/TOOLS/mummer-4.0.0beta2/mummer4/bin"

rule all:
    input:
        files_log,
        config["PREFIX"] + ".png"

rule align_nucmer:
    input:
        reference = config["REFERENCE"],
        query = config["QUERY"]
    output:
        config["PREFIX"] + ".delta"
    params:
        prefix = config["PREFIX"],
        mummer = MUMMER
    message:
        "Rule {rule} processing"
    shell:
        # "module load SHARED/MUMmer/3.23 && nucmer -p {params.prefix} {input.reference} {input.query}"
        "{params.mummer}/nucmer -p {params.prefix} {input.reference} {input.query}"

rule filter:
    input:
        rules.align_nucmer.output
    output:
        config["PREFIX"] + ".filter"
    message:
        "Rule {rule} processing"
    shell: 
        # "module load SHARED/MUMmer/3.23 && delta-filter -l 1000 -q -r {input} > {output}"
        "delta-filter -l 5000 -q -r {input} > {output}"


rule dotplot:
    input:
        rules.filter.output
    output:
        config["PREFIX"] + ".png"
    params:
        prefix = config["PREFIX"]
    message:
        "Rule {rule} processing"
    shell:
        # "module load SHARED/MUMmer/3.23 && mummerplot -p {params.prefix} --png {input}"
        "mummerplot -p {params.prefix} --png {input}"
