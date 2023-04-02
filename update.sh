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
    echo -e "Usage: ./update.sh
A script to update flipper files based on different sources

\t-h,--help\tDisplay this message
\t-d,--debug\tRun this script with `set -x`

"
    exit
fi

if [[ "${1-}" =~ ^-*d(ebug)?$ ]]; then
    set -x
fi

copy() {
    copy_to_officialFW "${1}" "${2}" "${@:3}"
    copy_to_customFW "${1}" "${2}" "${@:3}"
}

copy_to_officialFW() {
    print_green "Copying $1 to $2 in OFW"
    rsync -a "${1}" "OFW/${2}" --exclude=.* "${@:3}"
}

copy_to_customFW() {
    print_yellow "Copying $1 to $2 in CFW"
    rsync -a "${1}" "CFW/${2}" --exclude=.* "${@:3}"
}

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
	git clone --recursive "$2" "$1" 1> /dev/null
    fi
}

clean_directory() {
    for ext in "${@:2}"
    do
        find "$1" -name "*.$ext" -type f -delete
    done
}

handle_UberGuidoZ-Flipper() {
    DIR_NAME="UberGuidoZ-Flipper"
    GIT_ADDR="git@github.com:UberGuidoZ/Flipper.git"
    check_directory $DIR_NAME $GIT_ADDR
    clean_directory $DIR_NAME 7z AppImage asciidoc c C16 complex16s css cu8 html jpeg jpg JPG js md mov mp4 pdf png PNG py pyc sh wav yaml yml zip
    git -C $DIR_NAME submodule update --remote
    
    # Clean specific
    rm -rf UberGuidoZ-Flipper/Applications/Official/DEV_FW/source
    rm -rf UberGuidoZ-Flipper/BadUSB/ # Removed because too many scripts, I have to sort

    # apps
    copy_to_officialFW $DIR_NAME/Applications/Official/ apps
    copy_to_customFW $DIR_NAME/Applications/Custom\ \(UL\,\ RM\,\ XFW\)/ apps --exclude=*.zip

    # badusb 
    # Not yet sorted

    # nfc
    copy $DIR_NAME/NFC/ nfc --exclude=Documentation/ --exclude=Amiibo/Lanjelin-Converter/
    
    # rfid
    # No data

    # subghz
    copy $DIR_NAME/Sub-GHz/ subghz --exclude=*.pdf --exclude=*.png

    # subplaylist
    copy_to_customFW $DIR_NAME/subplaylist/ subplaylist

    # unirf
    copy_to_customFW $DIR_NAME/unirf/ unirf

    # infrared
    copy $DIR_NAME/Infrared/ infrared --exclude=_\Converted\_
    
    # music_player
    # No wav player transfer due to size
    copy $DIR_NAME/Music_Player/ music_player
}

main() {
    handle_UberGuidoZ-Flipper
    git add OFW/ CFW/
    #git commit -m "Update $(date +"%d/%m/%Y")"
}

main "$@"

#
# OFW/{apps,badusb,infrared,music_player,nfc,subghz}
# CFW/{apps,apps_data,badusb,dolphin,ibtnfuzzer,infrared,lfrfid/rfidfuzzer,music_player¸nfc,picopass,subghz,subplaylist,u2f,unirf,wav_player}
# 
