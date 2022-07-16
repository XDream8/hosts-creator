#!/bin/sh

#
# Made by XDream8
#

RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[1;32m'
CYAN='\033[0;36m'
NC='\033[0m'

check_dep() {
	if [ ! "$(command -v $1)" ]; then
		printf '%b\n' "${RED}$2${NC}"
		exit 1
	fi
}

startupcheck() {

	[ -d "$current_dir/backups" ] || ( printf '%b\n' "${BLUE}creating backups directory${NC}" && mkdir $current_dir/backups )

	[ -f "$current_dir/backups/$backupfilename.old" ] && printf '%b\n' "${BLUE}there is already 2 backups no need for another${NC}"
	[ -f "$current_dir/backups/$backupfilename.old" ] && no_need="1" || no_need="0"

	if [ "$no_need" -eq "0" ]; then
		[ -f "$current_dir/backups/$backupfilename" ] && ( printf '%b\n' "${BLUE}renaming old backup and copying new $syshosts_file${NC}" && mv $current_dir/backups/$backupfilename $current_dir/backups/$backupfilename.old && cp $syshosts_file $current_dir/backups/$backupfilename )
	fi

	[ -f "$current_dir/backups/$backupfilename" ] || ( printf '%b\n' "${BLUE}backing up $syshosts_file${NC}" && cp $syshosts_file $current_dir/backups/$backupfilename )

	[ -f "$current_dir/$newhostsfn" ] && printf '%b\n' "${RED}removing old $newhostsfn file${NC}"
	[ -f "$current_dir/$newhostsfn" ] && rm $current_dir/$newhostsfn
}

downloadhosts() {
	# number
	n=0
	printf '%b\n' "${BLUE}Downloading host lists${NC}"
	for i in $HOSTS
	do
		n=$(awk "BEGIN {print $n+1}")
		printf '%b\n' "${CYAN}$n) ${YELLOW}downloading $i${NC}"
		$downloader $i >> $current_dir/$newhostsfn
	done
}

edithostsfile() {
	# comments
	if [ $RM_COMMENTS = 1 ]; then
		printf '%b' "${BLUE}removing comments${NC}"
		awk -i inplace '!/^#/' $current_dir/$newhostsfn && printf '%b' "${BLUE}: ${GREEN}done${NC}"
	fi
	# trailing spaces
	if [ $RM_TRAILING_SPACES = 1 ]; then
		if [ $RM_COMMENTS = 1 ]; then
			printf '\n%b' "${BLUE}removing trailing spaces${NC}"
		else
			printf '%b' "${BLUE}removing trailing spaces${NC}"
		fi
		awk -i inplace '{gsub(/^ +| +$/,"")}1' $current_dir/$newhostsfn && printf '%b' "${BLUE}: ${GREEN}done${NC}"
	fi
	# duplicate lines
	if [ $RM_DUPLICATE_LINES = 1 ]; then
		if [ $RM_TRAILING_SPACES = 1 ]; then
			printf '\n%b' "${BLUE}removing duplicate lines${NC}"
		elif [ $RM_COMMENTS = 0 ] && [ $RM_TRAILING_SPACES = 0 ]; then
			printf '%b' "${BLUE}removing duplicate lines${NC}"
		fi
		awk -i inplace '!seen[$0]++' $current_dir/$newhostsfn && printf '%b' "${BLUE}: ${GREEN}done${NC}"
	fi
}

checksize() {
	size=$(du -sh "$current_dir/$newhostsfn" | awk '/[MK]/{print $0}')
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
	$sudo mv -iv $current_dir/$newhostsfn $syshosts_file || printf '%b\n' "${RED}error: couldn't replace /etc/hosts with the new hosts file";exit 1
	printf '%b' "${NC}"
}

main() {

	current_dir=$(pwd)

	[ -f "$current_dir/config" ] && . $current_dir/config

	[ -z "$syshosts_file" ] && syshosts_file=/etc/hosts
	[ -z "$backupfilename" ] && backupfilename=hosts.backup
	[ -z "$newhostsfn" ] && newhostsfn=hosts-new
	[ -z "$downloader" ] && downloader=curl
	[ -z "$replacehosts" ] && replacehosts=1

	check_dep $downloader "$downloader is missing, exiting!"
	check_dep awk "awk is required, exiting!"

	startupcheck

	printf '%s\n' "$RESOLVE_HOST" > $current_dir/$newhostsfn

	downloadhosts
	edithostsfile
	checksize
	if [ $replacehosts = 1 ]; then
		replacehosts
	fi
}

main
exit 0
