#!/usr/bin/bash -l
#SBATCH -p intel -N 1 -n 32 --mem 256gb --out logs/trinity.%a.log -a 1

module load trinity-rnaseq/2.13.2

MEM=256G

N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi

CPU=1
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi
SAMPLES=samples.csv
IFS=,
INDIR=input
OUTDIR=assembly
tail -n +2 $SAMPLES | sed -n ${N}p | while read STRAIN FILEBASE
do
LEFT=$INDIR/${FILEBASE}1(ls -1 $INDIR/$SAMPLE/*_1.fastq.gz | perl -p -e 's/\s+/,/g;' | perl -p -e 's/,$//')
RIGHT=$(echo -n "$LEFT" | perl -p -e 's/_1\.fastq/_2.fastq/g')
OUT=$OUTDIR/trinity_$SAMPLE
mkdir -p $OUT
if [ ! -d $OUT ]; then
	Trinity --seqType fq --max_memory $MEM --left $LEFT --right $RIGHT --CPU $CPU --trimmomatic --output $OUT
fi


