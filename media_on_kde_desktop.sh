#!/bin/bash

# Daemon script that monitors mount & unmount events and creates desktop icons of mounted media.
# Before using, please go to Plasma desktop settings and select Location -> Desktop path.
# Then edit below (DESKTOP_PATH) field in this script by providing proper username and path to your desktop.
# This script should be started when logging into the KDE desktop environment, so add it to startup programs.
# Do not run this script in two or more instances!
# This script has been tested only on Linux Manjaro KDE Plasma.
# After swithing to daemon mode, this script will be frozen (no CPU usage) unil specified DBus event gets received.

# (c) 2022 ppelikan
# https://github.com/ppelikan


# User settings:
DESKTOP_PATH="/home/YOUR_USERNAME/Desktop" # Please provide your desktop folder path here
SKIP_ROOT=false                            # When true, root partition will not be shown on desktop
EJECT_TRANSLATION="Unmount & Eject"        # Yu can edit the translation for right click menu entry
FILE_PREFIX="Mounted_Media"                # Prefix for *.desktop files generated in DESKTOP_PATH path
CLEAN_ON_FINISH=true                       # If true, desktop icons will be removed when this script terminates
SENDER=org.gtk.vfs.UDisks2VolumeMonitor    # DBus event sender of mount & unmount events

ITER=0
update_one() {
    if [ $SKIP_ROOT == true ] && [ $1 == "/" ]; then
        return 0 # do not create icon for root partition
    fi
    let ITER+=1
    LABEL=$(basename -- "$1")
    if [ -n "$2" ]; then
        LABEL=$2 #
    else
        if [ -n "$3" ]; then
            LABEL=$3 # perhaps will never happen
        fi
    fi
    FNAME="$DESKTOP_PATH/$FILE_PREFIX$(printf %02d $ITER).desktop"
    touch "$FNAME"
    printf "[Desktop Entry]\n" >"$FNAME"
    printf "Exec=xdg-open $1\n" >>"$FNAME"
    printf "Icon=drive-harddisk\n" >>"$FNAME" # todo: select icon depending on the volume type (USB/CD/HDD/Network etc)
    printf "Type=Application\n" >>"$FNAME"
    printf "Name=$LABEL\n" >>"$FNAME"
    if [ $1 != "/" ]; then # for mountpoints that are not root add the eject action for right click menu
        printf "Actions=Eject\n\n[Desktop Action Eject]\nName=$EJECT_TRANSLATION\n" >>"$FNAME"
        printf "Exec=sync && umount $1 || kdesu umount $1\n" >>"$FNAME"
        printf "Icon=media-eject\n" >>"$FNAME"
    fi
    chmod +x "$FNAME"
    return 0
}

update_desktop() {
    #https://unix.stackexchange.com/questions/177014/showing-only-interesting-mount-points-filtering-non-interesting-types/177040
    LIST=$(findmnt -uUrn --real -o TARGET,PARTLABEL,LABEL | grep -vE '(/run/user/|/var/|/boot/|/tmp/.|/run/timeshift/)') # get list of mounted volumes, excluding fake/system/not-real ones
    ITER=0
    while IFS= read -r LINE; do
        # echo "Generating: $LINE"
        update_one $LINE
    done <<<"$LIST"

    let ITER+=1
    MAX=$(ls -1 $DESKTOP_PATH/$FILE_PREFIX*.desktop | wc -l)           # get number of icons
    TORM=$(seq -f "$DESKTOP_PATH/$FILE_PREFIX%02g.desktop" $ITER $MAX) # get list of icons to remove
    if [ -n "$TORM" ]; then
        rm $TORM # remove all icons that link to no longer present volumesmount | grep '^/[^/]'
    fi
    mkdir $DESKTOP_PATH/$FILE_PREFIX999.desktop && rm -f $DESKTOP_PATH/$FILE_PREFIX999.desktop # workaround to force refresh (F5) action of the desktop
    return 0
}

finish() {
    echo ""
    echo "Stopping daemon..."
    if [ $CLEAN_ON_FINISH == true ]; then
        echo "Cleaning desktop..."
        CLRLIST=$(ls -1 $DESKTOP_PATH/$FILE_PREFIX*.desktop)
        if [ -n "$CLRLIST" ]; then
            rm $CLRLIST
        fi
    fi
    echo "Finished"
    exit
}

sleep $((RANDOM % 6)).$RANDOM
for pid in $(pidof -x $(basename $0)); do
    if [ $pid != $$ ]; then
        echo "[$(date)] : $(basename $0) : Process is already running with PID $pid"
        exit 1
    fi
done

echo "Initial refresh..."
update_desktop
echo "Initial refresh done successfully"
trap finish EXIT #SIGINT SIGTERM
# dbus-listen --interface 'org.gtk.vfs.UDisks2VolumeMonitor' --member 'VolumeChanged' $(basename "$0")
sleep 2
echo "Daemon started..."

# https://stackoverflow.com/questions/5344390/how-to-continuously-monitor-rhythmbox-for-track-change-using-bash/5345462#5345462
# https://askubuntu.com/questions/150790/how-do-i-run-a-script-on-a-dbus-signal
# https://unix.stackexchange.com/questions/28181/how-to-run-a-script-on-screen-lock-unlock

while :; do
    # dbus-monitor --session --profile "interface='org.gtk.vfs.UDisks2VolumeMonitor',member='VolumeChanged'" |
    gdbus monitor -e -d org.gtk.vfs.UDisks2VolumeMonitor |
        while read -r EMPTY; do
            # echo $EMPTY >>~/LOLO.txt
            # echo etap3
            sleep 0.5
            update_desktop
            for i in {1..10}; do
                read -rt 0.1 EMPTY
                # echo $i
                # echo $EMPTY >>~/LOLO.txt
            done
            # echo etap4
        done
done

# https://stackoverflow.com/questions/1113176/how-could-i-detect-when-a-directory-is-mounted-with-inotify
# https://unix.stackexchange.com/questions/267876/why-doesnt-inotify-work-with-etc-mtab-or-proc-mounts
# https://stackoverflow.com/questions/43078579/systemd-execute-script-on-every-mount
# https://serverfault.com/questions/50585/whats-the-best-way-to-check-if-a-volume-is-mounted-in-a-bash-script
