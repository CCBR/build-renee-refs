#!/usr/bin/env bash

module load ccbrpipeliner

for gver in 19; do # 36lift37; do
    renee build \
        --sif-cache /data/CCBR_Pipeliner/SIFS \
        --ref-fa /data/CCBR_Pipeliner/db/PipeDB/GDC_refs/downloads/GRCh37.p13.genome.d1.vd1.genome.fa \
        --ref-name hg19 \
        --ref-gtf /data/CCBR_Pipeliner/db/PipeDB/Indices/GTFs/hg19/gencode.v${gver}.annotation.gtf \
        --gtf-ver ${gver} \
        --output /data/CCBR_Pipeliner/db/PipeDB/GDC_refs/hg19_${gver}
done