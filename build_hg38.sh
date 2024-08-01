#!/usr/bin/env bash

module load ccbrpipeliner

for gver in 30 34 36 38 41 45; do
    renee build \
        --sif-cache /data/CCBR_Pipeliner/SIFS \
        --ref-fa /data/CCBR_Pipeliner/db/PipeDB/GDC_refs/downloads/GRCh38.d1.vd1.fa \
        --ref-name hg38 \
        --ref-gtf /data/CCBR_Pipeliner/db/PipeDB/Indices/GTFs/hg38/gencode.v${gver}.primary_assembly.annotation.gtf \
        --gtf-ver ${gver} \
        --output /data/CCBR_Pipeliner/db/PipeDB/GDC_refs/hg38_${gver}
done