configfile: "config.yaml"

pipeline = "align-genomes" # replace your pipeline's name

include: "/lustre/nobackup/WUR/ABGC/moiti001/snakemake-rules/create_file_log.smk"

workdir: config["OUTDIR"]
MUMMER = "/lustre/nobackup/WUR/ABGC/moiti001/TOOLS/mummer4.0.0rc1/bin"
DELTA2MAF = "~/miniconda3/pkgs/mugsy-1.2.3-3/bin/MUMmer3.20/delta2maf"

rule all:
    input:
        files_log,
        config["PREFIX"] + ".png",
        # config["PREFIX"] + ".maf",
        config["PREFIX"] + "_R.png",
        # config["PREFIX"] + "_R.maf"

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
        "{params.mummer}/nucmer -p {params.prefix} {input.reference} {input.query}"
        # "nucmer -p {params.prefix} {input.reference} {input.query}"


rule align_nucmer_rev:
    input:
        reference = config["QUERY"],
        query = config["REFERENCE"]
    output:
        config["PREFIX"] + "_R.delta"
    params:
        prefix = config["PREFIX"]+ "_R",
        mummer = MUMMER
    message:
        "Rule {rule} processing"
    shell:
        "{params.mummer}/nucmer -p {params.prefix} {input.reference} {input.query}"

rule filter:
    input:
        rules.align_nucmer.output
    output:
        config["PREFIX"] + ".filter"
    message:
        "Rule {rule} processing"
    params:
        filter = 5000,
        mummer = MUMMER
    shell: 
        "delta-filter -l {params.filter} -q -r {input} > {output}"

rule filter_rev:
    input:
        rules.align_nucmer_rev.output
    output:
        config["PREFIX"] + "_R.filter"
    message:
        "Rule {rule} processing"
    params:
        filter = 5000,
        mummer = MUMMER
    shell: 
        "delta-filter -l {params.filter} -q -r {input} > {output}"


rule dotplot:
    input:
        rules.filter.output
    output:
        config["PREFIX"] + ".png"
    params:
        prefix = config["PREFIX"],
        mummer = MUMMER
    message:
        "Rule {rule} processing"
    shell:
        "mummerplot -p {params.prefix} --png {input}"

rule dotplot_rev:
    input:
        rules.filter_rev.output
    output:
        config["PREFIX"] + "_R.png"
    params:
        prefix = config["PREFIX"]+"_R",
        mummer = MUMMER
    message:
        "Rule {rule} processing"
    shell:
        "mummerplot -p {params.prefix} --png {input}"


rule delta2maf:
    input:
        rules.align_nucmer.output
    output:
        config["PREFIX"] + ".maf"
    message:
        "Rule {rule} processing"
    params:
        delta2maf = DELTA2MAF
    shell:
        "{params.delta2maf} {input} > {output}"

rule delta2maf_rev:
    input:
        rules.align_nucmer_rev.output
    output:
        config["PREFIX"] + "_R.maf"
    message:
        "Rule {rule} processing"
    params:
        delta2maf = DELTA2MAF
    shell:
        "{params.delta2maf} {input} > {output}"
