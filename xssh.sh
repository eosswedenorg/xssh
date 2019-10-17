#!/usr/bin/env bash
#
# Copyright (C) 2019 Henrik Hautakoski <henrik@eossweden.org>. All Rights Reserved.

KEY="default"
CONNECTION="default"
CONFIG_FILE="${HOME}/.ssh/xssh.json"
DEFAULT_CONFIG="./config.json"
VERBOSE=false
COMMAND=
NODE=

parse_args() {

	# Parse general options.
	while getopts ":k:c:vh" arg; do
		case "${arg}" in
		k)	KEY=${OPTARG};;
		c)	CONNECTION=${OPTARG};;
		v)	VERBOSE=true;;
		h)	usage
			help
			exit 1
			;;
		\?) echo "Invalid option: '$OPTARG'"
			exit 1
			;;
		esac
	done
	shift $((OPTIND-1))

	if [ $# -lt 1 ]; then
		usage
		exit 1
	fi

	# Parse command

	COMMAND=$1
	shift 1

	case "${COMMAND}" in
	init) ;;
	connect)
		if [ $# -lt 1 ]; then
			err "Missing <node>"
			usage
			exit 1
		fi
		NODE=$1
		;;
	list) ;;
	*)
		# Default to connect.
	 	NODE=$COMMAND
		COMMAND=connect
		;;
	esac
}

print_vars() {
	echo "Command: ${COMMAND}"
	echo "Node: ${NODE}"
	echo "Connection: ${CONNECTION}"
	echo "Key: ${KEY}"
}

usage() {
	local SCRIPT=$(basename $0)
	echo "usage: $SCRIPT [-vh] [-c name] [-k name] <command>"
	echo " \`$SCRIPT -h\` for more detailed output."
}

help() {
	echo -e "\nOptions:"
	echo " -v		Verbose output"
	echo " -h		Show this help text"
	echo " -c		Name of the connection to use (defined for each node in config file)"
	echo " -k		Name of the SSH Key to use (defined in config file)"

	echo -e "\nCommands:"
	echo " <node>		Shorthand for \`connect <node>\`"
	echo " init		Initialize config."
	echo " connect	Connect to a node using ssh"
	echo " list		List nodes"
}

err() {
	echo "[Error]" $@ 1>&2
	exit 1
}

# --------------------------
#  Commands
# --------------------------

cmd_init() {
	cp -i $DEFAULT_CONFIG $CONFIG_FILE
}

cmd_list() {

	for k in $(jq -M -r ".connections | keys[]" "${CONFIG_FILE}" | sort); do

		local connections=$(jq -M -r ".connections.$k | keys[]" "${CONFIG_FILE}" \
			| tr '\n' "," | sed -E 's/,$//g' | sed 's/,/, /g')

		echo -e " - $k\t($connections)"

	done
}

cmd_connect() {

	# Hack for jq.
	# Could not get it to return non zero status code on error.
	# So what we do is redirect stderr, check if content begin with '{'
	# If so we parsed the json correctly. if not error.
	local config=$(jq "." "${CONFIG_FILE}" 2>&1)
	if [[ ! "${config}" =~ ^\{.* ]]; then
		err "Failed to parse config '$conf'"
	fi

	local ident=$(echo $config | jq -M -r ".keys.${KEY}")
	local con=$(echo $config | jq -M -r ".connections.${NODE}")

	[ "$ident" = "null" ] && [ "${KEY}" != "default" ] && err "Key '${KEY}' not found in config file"
	[ "$con" = "null" ] && err "Did not find node '${NODE}'"

	local params=( $(echo $con | jq -M -r ".${CONNECTION}[]" 2>/dev/null) )

	[ "z$params" = "z" ] && err "Connection '${CONNECTION}' not found for '${NODE}'"

	# Build options
	local opts="${params[0]}"

	[ ${#params[@]} -gt 1 ] && opts+=" -p ${params[1]}"
	[ "${ident}" != "null" ] && opts+=" -i "${ident/#\~/$HOME}""

	# Call SSH
	if [ $VERBOSE = true ]; then
		echo "Command: ssh $opts"
	fi
	ssh $opts
}

# -------------------------
#  Program start.
# -------------------------

parse_args $@

if [ $VERBOSE = true ]; then
	print_vars
fi

cmd_${COMMAND}
