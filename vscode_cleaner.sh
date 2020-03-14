#!/bin/bash

# Visual Studio Code creates heavy hidden directoiries .vscode/ipch when working on C/C++ projects.
# IPCH (IntelliSense Precompiled Header) is cache directory left by IntelliSense
# This script searches for them, and removes after user confirmation. 
#
# (c) 2019 ppelikan
# https://github.com/ppelikan


dira1=".vscode"                 #first folder name
dira2="ipch"                    #name of folder inside the first one

dirb1=".vscode-cpptools"
dirb2="ipch"

done=0

del_dir() {
rm -r $1                       #remove dir recursively
echo " Deleted!"
((done++))
}

ask_dir() {
res=0
sz="$(du -hs $1)"                #get size of the given folder
echo "$sz"
echo -n 'Delete? [Y/N] '
read -n 1 CTN                    #wait for keypress
case $CTN in
y|Y)del_dir $1 ;;
q|Q)res=1 ;;
*) echo " Skipped..." ;;
esac
return 0
}

all=0
#nl='find xxxxx 2>dev/null' #hide unwanted output of find

found_dirs="$(find -name ${dira1} -type d -exec find '{}' -name ${dira2} -type d \;)" #find all dirs1 that contain dirs2
found_dirs+=$'\n'
found_dirs+="$(find -name ${dirb1} -type d -exec find '{}' -name ${dirb2} -type d \;)"
echo " "
IFS=$'\n'                                 #allow to iterate found_dirs separated only by \n not by spaces
for i in $found_dirs; do
    all+=1
    ask_dir $i                          #ask user for response
    if (("$res" == 1)); then            #abandon task if user pressed Q
        echo " Aborted."
        break
    fi
done

if (("$all" == 0)); then
    echo "No directories found."
fi
if (("$done" != 0)); then
    echo "Deleted: $done directories"
fi