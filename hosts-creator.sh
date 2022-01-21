#!/bin/sh

#
# Made by XDream8
#

current_dir=$(pwd)
syshosts_file=/etc/hosts
backupfilename=hosts.backup
downloadedhostsfn=hosts-new
downloadprogram=curl

RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

startupcheck() {
	printf '%b\n' "${BLUE}backing up $syshosts_file, if it is not backed up before${NC}"
	[ -f "$current_dir/$backupfilename" ] || cp $syshosts_file $current_dir/$backupfilename

	[ -f "$current_dir/$downloadedhostsfn" ] && printf '%b\n' "${RED}removing old $downloadedhostsfn file${NC}"
	[ -f "$current_dir/$downloadedhostsfn" ] && rm $current_dir/$downloadedhostsfn
}

downloadhosts() {
	n=0 #number
	printf '%b\n' "${BLUE}Downloading host lists${NC}"
	for i in \
		https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts \
		https://raw.githubusercontent.com/bkrucarci/turk-adlist/master/hosts \
		https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt \
		https://badmojr.github.io/1Hosts/Pro/hosts.txt \
		https://hosts.oisd.nl \
		https://block.energized.pro/ultimate/formats/hosts \
		https://block.energized.pro/extensions/xtreme/formats/hosts \
		https://raw.githubusercontent.com/notracking/hosts-blocklists/master/hostnames.txt \
		https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Hosts/GoodbyeAds.txt
	do
		n=$(awk "BEGIN {print $n+1}")
		printf '%b\n' "${CYAN}$n) ${YELLOW}downloading $i${NC}"
		$downloadprogram $i >> $current_dir/$downloadedhostsfn
	done
}

edithostsfile() {
	printf '%b\n' "${BLUE}removing comments, trailingspaces, duplicate lines${NC}"
	awk -i inplace '!/^#/' $current_dir/$downloadedhostsfn
	awk -i inplace '{gsub(/^ +| +$/,"")}1' $current_dir/$downloadedhostsfn
	awk -i inplace '!seen[$0]++' $current_dir/$downloadedhostsfn # duplicate lines
}

checksize() {
	size=$(du -sh "$current_dir/$downloadedhostsfn" | awk '/[MK]/{print $0}')
	if [ "$(printf '%s\n' "${size}" | awk '/M/{print $0}')" ]; then
		if [ $(printf '%s\n' "${size}" | awk '{print $0}' | awk '{print ($0+0)}' ) > 60 ]; then
			printf '%b\n' "${RED}your new hosts file is bigger than 60M${NC}"
		fi
	fi
}

replacehosts() {
	if [ "$(command -v doas)" ]; then
		sudo=doas
	else
		sudo=sudo
	fi

	printf '%b\n' "${BLUE}replacing /etc/hosts with the new one${NC}"
	printf '%b' "${YELLOW}"
	$sudo mv -iv $current_dir/$downloadedhostsfn $syshosts_file || printf '%b\n' "${RED}error: couldn't replace /etc/hosts with the new hosts file";exit 1
	printf '%b' "${NC}"
}

main() {
	startupcheck

	# You should edit this line probably
	printf '%b\n' "127.0.0.1 $(hostname).homenetwork $(hostname) localhost" > $current_dir/$downloadedhostsfn

	downloadhosts
	edithostsfile
	checksize
	replacehosts
}

main
exit 0
