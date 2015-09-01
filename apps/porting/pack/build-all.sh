#!/bin/bash
PARALLEL=8
SUBDIR=$PACKSDIR

if [ "$SUBDIR" == "" ]; then SUBDIR=/usr/src/packs; fi

JOBS=($(ls $SUBDIR))
index=0
handle_interrupt() {
	echo Killing all subprocesses
    pkill --pgroup 0
	exit 1
}

trap handle_interrupt SIGINT

export FAILLIST=/tmp/$BASHPID-faillist
truncate -s0 $FAILLIST

set -o monitor
function add_next_job {
    if [[ $index -lt ${#JOBS[*]} ]]; then

        do_job ${JOBS[$index]} & 
        index=$(($index+1))
    fi
}

function do_job {
	if ! pack.sh $1; then
		flock -x $FAILLIST -c "echo $1 >> $FAILLIST"
	fi
}
trap add_next_job CHLD 
while [[ $index -lt $PARALLEL ]]; do
    add_next_job
done

wait

FAILED_JOBS=$(cat $FAILLIST)
rm $FAILLIST
if [ "$FAILED_JOBS" != "" ]; then
	echo "**** SOME PACKAGES FAILED ****"
	echo Failed packages: $FAILED_JOBS
else
	echo All packages built successfully
fi

