#!/usr/bin/bash -l
#SBATCH -p intel,batch -N 1 -n 32 --mem 128gb --out logs/trinity.%a.log -a 1

module load trinity-rnaseq/2.13.2

MEM=128G

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
mkdir -p $OUTDIR

tail -n +2 $SAMPLES | sed -n ${N}p | while read STRAIN LEFT RIGHT
do
    LEFT=$INDIR/$LEFT
    RIGHT=$INDIR/$RIGHT
    OUT=$OUTDIR/trinity_$STRAIN
    #echo "$LEFT $RIGHT $STRAIN"
    if [ ! -f $LEFT ]; then
	echo "no LEFT $LEFT"
	exit
    fi
    if [ ! -f $RIGHT ]; then
	echo "no RIGHT $RIGHT"
	exit
    fi
    if [ ! -d $OUT ]; then
	echo "$LEFT $RIGHT $STRAIN"
  # could add jaccard but not sure if it is necessary
	time Trinity --seqType fq --max_memory $MEM --left $LEFT --right $RIGHT --CPU $CPU --trimmomatic --full_cleanup --output $OUT
    fi

done
