#!/bin/sh

#
# Made by XDream8
#

current_dir=$(pwd)
syshosts_file=/etc/hosts
backupfilename=hosts.backup
downloadedhostsfn=hosts-new
downloadprogram=curl

[ -f "$current_dir/config" ] && . $current_dir/config

RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[1;32m'
CYAN='\033[0;36m'
NC='\033[0m'

startupcheck() {
	printf '%b\n' "${BLUE}backing up $syshosts_file, if it is not backed up before${NC}"
	[ -f "$current_dir/$backupfilename" ] || cp $syshosts_file $current_dir/$backupfilename

	[ -f "$current_dir/$downloadedhostsfn" ] && printf '%b\n' "${RED}removing old $downloadedhostsfn file${NC}"
	[ -f "$current_dir/$downloadedhostsfn" ] && rm $current_dir/$downloadedhostsfn
}

downloadhosts() {
	# number
	n=0
	printf '%b\n' "${BLUE}Downloading host lists${NC}"
	for i in $HOSTS
	do
		n=$(awk "BEGIN {print $n+1}")
		printf '%b\n' "${CYAN}$n) ${YELLOW}downloading $i${NC}"
		$downloadprogram $i >> $current_dir/$downloadedhostsfn
	done
}

edithostsfile() {
	# comments
	if [ $RM_COMMENTS = 1 ]; then
		printf '%b' "${BLUE}removing comments${NC}"
		awk -i inplace '!/^#/' $current_dir/$downloadedhostsfn && printf '%b' "${BLUE}: ${GREEN}done${NC}"
	fi
	# trailing spaces
	if [ $RM_TRAILING_SPACES = 1 ]; then
		if [ $RM_COMMENTS = 1 ]; then
			printf '\n%b' "${BLUE}removing trailing spaces${NC}"
		else
			printf '%b' "${BLUE}removing trailing spaces${NC}"
		fi
		awk -i inplace '{gsub(/^ +| +$/,"")}1' $current_dir/$downloadedhostsfn && printf '%b' "${BLUE}: ${GREEN}done${NC}"
	fi
	# duplicate lines
	if [ $RM_DUPLICATE_LINES = 1 ]; then
		if [ $RM_TRAILING_SPACES = 1 ]; then
			printf '\n%b' "${BLUE}removing duplicate lines${NC}"
		elif [ $RM_COMMENTS = 0 ] && [ $RM_TRAILING_SPACES = 0 ]; then
			printf '%b' "${BLUE}removing duplicate lines${NC}"
		fi
		awk -i inplace '!seen[$0]++' $current_dir/$downloadedhostsfn && printf '%b' "${BLUE}: ${GREEN}done${NC}"
	fi
}

checksize() {
	size=$(du -sh "$current_dir/$downloadedhostsfn" | awk '/[MK]/{print $0}')
	if [ "$(printf '%s\n' "${size}" | awk '/M/{print $0}')" ]; then
		if [ "$(printf '%s\n' "${size}" | awk '{print $0}' | awk '{print ($0+0)}')" -gt "60" ]; then
			printf '%b\n' "${RED}your new hosts file is bigger than 60M${NC}"
		fi
	fi
}

replacehosts() {
	if [ "$(command -v rdo)" ]; then
		sudo=rdo
	elif [ "$(command -v doas)" ]; then
		sudo=doas
	else
		sudo=sudo
	fi

	printf '\n%b\n' "${BLUE}replacing /etc/hosts with the new one${NC}"
	printf '%b' "${YELLOW}"
	$sudo mv -iv $current_dir/$downloadedhostsfn $syshosts_file || printf '%b\n' "${RED}error: couldn't replace /etc/hosts with the new hosts file";exit 1
	printf '%b' "${NC}"
}

main() {
	startupcheck

	printf '%s\n' "$RESOLVE_HOST" > $current_dir/$downloadedhostsfn

	downloadhosts
	edithostsfile
	checksize
	replacehosts
}

main
exit 0
