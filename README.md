# Build indices from the GDC reference files

<https://gdc.cancer.gov/about-data/gdc-data-processing/gdc-reference-files>

This repo is on biowulf at `/data/CCBR_Pipeliner/db/PipeDB/GDC_refs`

The snakemake workflow downloads references from Encode, Entrez, and
[GDC](https://gdc.cancer.gov/about-data/gdc-data-processing/gdc-reference-files),
adds viruses and decoys to the hg19 fasta,
and executes `renee build` for the hg38 and hg19 genome versions specified in the config file.

> The hg38 fasta files were downloaded from the GDC with virus and decoy sequences already added,
> while we added these sequences to the hg19 fasta from Encode using this snakemake workflow.

```sh
module load snakemake/7
snakemake -j 8
chmod -R a+r /data/CCBR_Pipeliner/db/PipeDB/GDC_refs
```

After the `renee build` jobs complete,
copy the genome JSON files to the RENEE repo:

```sh
cp hg*/*.json /data/CCBR_Pipeliner/Pipelines/RENEE/renee-dev-sovacool/config/genomes/biowulf/
```

Make modified versions for FRCE:

```sh
cp hg*/*.json /data/CCBR_Pipeliner/Pipelines/RENEE/renee-dev-sovacool/config/genomes/frce/
sed -i "s|/data/CCBR_Pipeliner/db/PipeDB/GDC_refs/|/mnt/projects/CCBR-Pipelines/db/GDC_refs/|g" \
    config/genomes/frce/*
```

Copy the reference files to FRCE:

```sh
ssh 10.156.101.10
rsync -rLK --progress --ignore-existing --exclude=".*" \
    helix.nih.gov:/data/CCBR_Pipeliner/db/PipeDB/GDC_refs /mnt/projects/CCBR-Pipelines/db/
chmod -R a+r /mnt/projects/CCBR-Pipelines/db/GDC_refs/hg*
exit
```

Finally, contribute the changes to RENEE via a pull request.
