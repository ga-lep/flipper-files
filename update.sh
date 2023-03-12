#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

# Colors
COLOR_OFF='\033[0m'       # Text Reset
RED='\033[0;31m'          # Red
GREEN='\033[0;32m'        # Green
YELLOW='\033[0;33m'       # Yellow
BLUE='\033[0;34m'         # Blue
WHITE='\033[0;37m'        # White

print_red() {
    echo -e "${RED}$*${COLOR_OFF}"
}

print_green() {
    echo -e "${GREEN}$*${COLOR_OFF}"
}

print_yellow() {
    echo -e "${YELLOW}$*${COLOR_OFF}"
}

print_blue() {
    echo -e "${BLUE}$*${COLOR_OFF}"
}

print_white() {
    echo -e "${WHITE}$*${COLOR_OFF}"
}

if [[ "${1-}" =~ ^-*h(elp)?$ ]]; then
    echo 'Usage: ./update.sh

This is an awesome bash script to make your life better.

'
    exit
fi

check_directory() {
    print_red "Handling $1"
    if [ -d "$1" ]; then
	print_blue "$1 directory exists."
	cd "$1"
	print_blue "Updating $1"
	git pull 1> /dev/null
	cd - 1> /dev/null
    else
	print_blue "$1 directory does not exist."
	print_blue "Cloning $2 into $1"
	git clone "$2" "$1" 1> /dev/null
    fi
}

handle_Flipper-IRDB() {
    check_directory "Flipper-IRDB" "git@github.com:logickworkshop/Flipper-IRDB.git"
    rsync -a Flipper-IRDB/ OFW/infrared --exclude=\_Converted\_ --exclude=README.md --exclude=.*
    rsync -a Flipper-IRDB/ CFW/infrared --exclude=\_Converted\_ --exclude=README.md --exclude=.*
}

hangle_UberGuidoZ-Flipper() {
    check_directory "UberGuidoZ-Flipper" "git@github.com:UberGuidoZ/Flipper.git"
}

main() {
    handle_Flipper-IRDB
    hangle_UberGuidoZ-Flipper
}

main "$@"
