#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 32 -C xeon --mem 64gb --out logs/transdecoder.%a.log -a 1-20

module load transdecoder
module load hmmer/3.3.2-mpi
module load db-pfam
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
    pushd $OUTDIR
    ASM=trinity_$STRAIN.Trinity.fasta
    TD=$ASM.transdecoder_dir
    if [ ! -f $TD/longest_orfs.pep ]; then
    	TransDecoder.LongOrfs -t $ASM
    fi
    if [ ! -f $TD/longest_orfs.pep ]; then
	echo "Failed to run transdecoder"
	exit
    fi
    if [ ! -f trinity_$STRAIN.Trinity.hmmscan ]; then
    	srun hmmsearch --mpi --cut_ga --domtbl trinity_$STRAIN.Trinity.domtbl -o trinity_$STRAIN.Trinity.hmmscan $PFAM_DB/Pfam-A.hmm $TD/longest_orfs.pep
    fi
    TransDecoder.Predict -t $ASM --retain_pfam_hits trinity_$STRAIN.Trinity.domtbl

done
