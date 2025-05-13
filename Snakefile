from collections import defaultdict
import os
from pprint import pprint

NCBI_API_KEY=os.environ.get('NCBI_API_KEY', None)
if not NCBI_API_KEY:
    raise ValueError("NCBI_API_KEY environment variable is not set.\n"
    "\tPlease obtain an API Key for your NCBI account and set it to the environment variable NCBI_API_KEY.\n"
    "\thttps://support.nlm.nih.gov/knowledgebase/article/KA-05317/en-us")

configfile: 'config.yml'


def list_genome_outputs():
    return [f'{genome}_{gver}/config/build.yml' for genome in config['genomes'] for gver in config['genomes'][genome]]


rule all:
    input:
        'downloads/GRCh37.p13.genome.d1.vd1.genome.fa',
        list_genome_outputs()

checkpoint download_virus_decoys_table:
    output:
        txt='downloads/GRCh83.d1.vd1_virus_decoy.txt'
    shell:
        """
        wget -O {output.txt} https://gdc.cancer.gov/files/public/file/GRCh83.d1.vd1_virus_decoy.txt
        """


def list_virus_decoy_fastas(wildcards):
    decoys_dict = defaultdict(list)
    with open(checkpoints.download_virus_decoys_table.get().output.txt, 'r') as decoys_infile:
        header = next(decoys_infile).strip().split('\t')
        for line in decoys_infile:
            line_spl = line.strip().split('\t')
            if len(line_spl) > 1:
                for index, entry in enumerate(line_spl):
                    decoys_dict[header[index]].append(entry)
    return expand('downloads/decoys/{genbank_id}.fna', genbank_id=decoys_dict['GenBank'])


"""
Download virus decoys as fasta file from Entrez.
Manual: https://www.ncbi.nlm.nih.gov/books/NBK25500/#chapter1.Downloading_Full_Records
"""
rule download_virus_decoy_fasta:
    output:
        fasta='downloads/decoys/{genbank_id}.fna'
    params:
        query=f'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id={{genbank_id}}&rettype=fasta&retmode=text&api_key={NCBI_API_KEY}'
    shell:
        """
        sleep 1
        wget -O {output.fasta} "{params.query}"
        """

rule download_genomic_decoys_fasta:
    output:
        fasta='downloads/GCA_000786075.2_hs38d1_genomic.fna'
    shell:
        """
        sleep 1
        wget -O {output.fasta}.gz \
            https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/786/075/GCA_000786075.2_hs38d1/GCA_000786075.2_hs38d1_genomic.fna.gz \
            && unpigz {output.fasta}.gz
        """

rule download_hg19_fasta:
    output:
        fasta='downloads/GRCh37.p13.genome.fa'
    shell:
        """
        wget -O {output.fasta}.gz \
             https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/GRCh37.p13.genome.fa.gz \
             && unpigz {output.fasta}.gz
        """

rule concat_sequences_hg19:
    input:
        rules.download_hg19_fasta.output.fasta,
        rules.download_genomic_decoys_fasta.output.fasta,
        list_virus_decoy_fastas
    output:
        fasta='downloads/GRCh37.p13.genome.d1.vd1.genome.fa'
    shell:
        """
        cat {input} > {output.fasta}
        """

rule download_gdc_hg38_fasta:
    output:
        fasta='downloads/GRCh38.d1.vd1.fa'
    shell:
        """
        wget -O GRCh38.d1.vd1.fa.tar.gz https://api.gdc.cancer.gov/data/254f697d-310d-4d7d-a27b-27fbf767a834 \
            && \
            tar -C downloads/ -xzvf GRCh38.d1.vd1.fa.tar.gz && \
            rm GRCh38.d1.vd1.fa.tar.gz
        """

rule renee_build_hg19:
    input:
        fasta=rules.concat_sequences_hg19.output.fasta,
        gtf='/data/CCBR_Pipeliner/db/PipeDB/Indices/GTFs/hg19/gencode.v{gver}.annotation.gtf'
    output:
        yml='hg19_{gver}/config/build.yml'
    params:
        outdir='/data/CCBR_Pipeliner/db/PipeDB/GDC_refs/hg19_{gver}'
    shell:
        """
        renee=/data/CCBR_Pipeliner/Pipelines/RENEE/renee-dev-sovacool/src/renee/__main__.py
        $renee build \
            --sif-cache /data/CCBR_Pipeliner/SIFS \
            --ref-fa {input.fasta} \
            --ref-name hg19 \
            --ref-gtf {input.gtf} \
            --gtf-ver {wildcards.gver} \
            --output {params.outdir}
        """

rule renee_build_hg38:
    input:
        fasta=rules.download_gdc_hg38_fasta.output.fasta,
        gtf='/data/CCBR_Pipeliner/db/PipeDB/Indices/GTFs/hg38/gencode.v{gver}.primary_assembly.annotation.gtf'
    output:
        yml='hg38_{gver}/config/build.yml'
    params:
        outdir='/data/CCBR_Pipeliner/db/PipeDB/GDC_refs/hg38_{gver}/'
    shell:
        """
        renee=/data/CCBR_Pipeliner/Pipelines/RENEE/v2.6/bin/renee
        $renee build \
            --sif-cache /data/CCBR_Pipeliner/SIFS \
            --ref-fa {input.fasta} \
            --ref-name hg38 \
            --ref-gtf {input.gtf} \
            --gtf-ver {wildcards.gver} \
            --output {params.outdir}
        """
