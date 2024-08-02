# Build indices from the GDC reference files

<https://gdc.cancer.gov/about-data/gdc-data-processing/gdc-reference-files>

This repo is on biowulf at `/data/CCBR_Pipeliner/db/PipeDB/GDC_refs`

The snakemake workflow will
download references from Entrez and 
[GDC](https://gdc.cancer.gov/about-data/gdc-data-processing/gdc-reference-files),
add viruses and decoys to the hg19 fasta,
and execute `renee build` for the hg38 and hg19 genome versions specified in the config file.


```sh
module load snakemake/7
snakemake -j 8
chmod -R a+r /data/CCBR_Pipeliner/db/PipeDB/GDC_refs
```

After the `renee build` jobs complete, copy files to frce:

```sh
ssh 10.156.101.10
rsync -rLK --progress --ignore-existing --exclude=".*" \
    helix.nih.gov:/data/CCBR_Pipeliner/db/PipeDB/GDC_refs /mnt/projects/CCBR-Pipelines/db/
chmod -R a+r /mnt/projects/CCBR-Pipelines/db/GDC_refs/hg*
```
