# Build indices from the GDC reference files

<https://gdc.cancer.gov/about-data/gdc-data-processing/gdc-reference-files>


The snakemake workflow will
download references from Entrez and GDC,
add GDC viruses and decoys to the hg19 fasta,
and execute `renee build` for hg38 and hg19 genome version specified in the config file.


```sh
module load snakemake/7
snakemake -j 8
```

after the `renee build` jobs complete, copy files to frce:

```sh
ssh frce
rsync -rLK --progress --ignore-existing helix:/data/CCBR_Pipeliner/db/PipeDB/GDC_refs /mnt/projects/CCBR-Pipelines/db/
```
