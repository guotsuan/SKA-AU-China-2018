#!/bin/bash

function print_usage {
	echo "$0 [-h | -?] [-d <data_dir>]  [-o <obs_name>]"
	echo
	echo "-h, -?: Show this help"
	echo "-d <data_dir>:    Provide the directory where all the data resides (or will reside)"
	echo "-o <obs_name>: Provide the observation name"
}

# Where are we?
this_dir=`dirname $0`

# The logical graph we want to submit
lg_dir="$this_dir"/../logical_graphs
lg_file="$lg_dir"/mwa/mwa.json

# Handle command-line arguments
OBS_NAME=observation
DATA_DIR=.

while getopts "d:o:h?" opt
do
	case "$opt" in
		d)
			DATA_DIR="$OPTARG"
			;;
		o)
			OBS_NAME="$OPTARG"
			;;
		[h?])
			print_usage
			exit 0
			;;
		:)
			print_usage 1>&2
			exit 1
	esac
done

now="$(date -u +%F_%T)"

# Replace the placeholder variables (i.e., transition from a Logical Graph
# Template into a Logical Graph).
# Then translate into a physical graph template, partition, etc, and finally submit
sed "s|\${DATA_DIR}|${DATA_DIR}|g; s|\${OBS_NAME}|${OBS_NAME}|g" "$lg_file" \
	| dlg unroll-and-partition | dlg map | dlg submit -s "${OBS_NAME}_${now}"
