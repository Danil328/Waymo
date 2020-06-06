#!/usr/bin/env bash
# $1 - path to tar directory
# $1 - path to output directory

set -e

# 1. Create ProgressBar function
# 1.1 Input is currentState($1), totalState($2), seconds($3)
ProgressBar() {
    # Process data
    currentState=$1
    totalState=$2
    seconds=$3

	_progress=$((currentState*100/totalState*100/100))
	_done=$((_progress*4/10))
	_left=$((40-_done))
	_mean_seconds_to_step=`echo "$seconds/$currentState" | bc -l`
#	echo ${_mean_seconds_to_step}
    _steps_letf=$((totalState-currentState))
	_eta=`echo "scale=0;$_steps_letf*$_mean_seconds_to_step" | bc`

    # Build progressbar string lengths
	_done=$(printf "%${_done}s")
	_left=$(printf "%${_left}s")

    printf "\rProgress : [${_done// /#}${_left// /-}] ${_progress}%% Completed - ${1}, Total - ${2}, Elapsed time - ${3} sec, ETA - ${_eta%.*} sec"
}

total_files=`ls $1/*.tar | wc -l`
var=0
SECONDS=0
for tar_path in $1/*.tar
do
    tar -xvf ${tar_path} -C $2
    var=$((var+1))
    ProgressBar ${var} ${total_files} ${SECONDS}
done
