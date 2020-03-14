#!/bin/bash

# Script unpacking multiple archives using brute force by trying multiple passwords
# (c) 2018 ppelikan
# https://github.com/ppelikan


IFS=$'\n'                             #set the separator to new line instead of spaces
PASWORDS=$(cat $1 2>/dev/null)        #loading the password file, all errors sending to null
MAINDIR=$PWD                          #location of the script call

unpack_rar_file() { #arguments: rar file name, password
    rar -y -p"$2" x "$1" &>/dev/null   #unpack the file $1 using the password $2
    return $?
}

unpack_7z_file() { #arguments: 7z file name, password
    7z -y -p"$2" x "$1" &>/dev/null
    return $?
}

try_all_pass() { #arguments: extract function pointer, file name
    IFS=$'\n'
    for pass in $PASWORDS; do         #iteration over all passwords from a password file
        echo -n '.'                   #test of each password = one dot print
        $1 $2 $pass                   #execute unpacking function
        if [[ $? == 0 ]]; then        #unpack succeeded
            echo -e -n "\n"           #closing progressbar
            return 0
        fi
    done
    echo -e "\nNo maching passwords!"
    return 1
}

unpack_procedure() { #arguments: extract function pointer, file name
    IFS=$'\n'
    xbase=${2##*/}                   #cut the file name from the parameter
    temp_dir="_unpack_${xbase%.*}"   #and based on this name we create name of the temporary directory
    mkdir "$temp_dir" 2>/dev/null    #create directory with this name
    # echo "$PWD"
    #echo "$temp_dir"
    cd "$temp_dir"
    try_all_pass $@                  #try to extract
    if [[ $? == 0 ]]; then    #if extract succeded
        # echo "OKOKOKOKOKOKOKOK"
        filecount=$(
            shopt -s nullglob
            set -- *
            echo $#
        )
        if [[ $filecount == 1 ]]; then #if our catalog contains only 1 file
            mv -n * ..                 #move it up higher
        fi
        filecount=$(
            shopt -s nullglob
            set -- *
            echo $#
        )
        if [[ $filecount == 0 ]]; then #if directory is already empty // TODO Can be simplified!
            # if [ -z "$(ls -A $temp_dir)" ]; then
            cd "$MAINDIR"
            #rm -r "$temp_dir"
            rmdir "$temp_dir"          #delete it
        fi
    else                            #if the file could not be extracted
        # echo "FAILFAILFAILFIALFIALFIALFIALFAIFAIL"
        filecount=$(
            shopt -s nullglob
            set -- *
            echo $#
        )
        if [[ $filecount == 0 ]]; then  #and the directory is empty
            cd "$MAINDIR"
            rmdir "$temp_dir"           #delete it
        fi
        return 1                    #and return an unpacking error
    fi
    return 0    #no errors
}

iterate() { #arguments: file list, extract function pointer
    IFS=$'\n'
    for file in $1; do  #iterating the given file list
        cd "$MAINDIR"
        echo "Unpacking: $file"
        unpack_procedure $2 "$MAINDIR/$file"     #try to extract
        if [[ $? != 0 ]]; then
            echo "Could not extract the archive!"
        else
            rm -f "$MAINDIR/$file"          #if it was unpacked, then we delete the (already unpacked) archive file
        fi
    done
}

if [ -z "$1" ]; then
    echo "You haven't provided a file name containing a list of passwords!"
    exit 1
fi

if [ -z "$PASWORDS" ]; then
    echo "The provided file does not contain any passwords!"
    exit 1
fi

LIST=$(ls *.rar 2>/dev/null)
iterate "$LIST" unpack_rar_file     #as the second parameter we give the name of unpacking function
LIST=$(ls *.7z  2>/dev/null)
iterate "$LIST" unpack_7z_file
LIST=$(ls *.zip  2>/dev/null)
iterate "$LIST" unpack_7z_file

LIST=$(ls *.7z.001  2>/dev/null)
iterate "$LIST" unpack_7z_file

# LIST=$(ls *.rar.part  2>/dev/null)
# iterate "$LIST" unpack_rar_file
# LIST=$(ls *.7z.part  2>/dev/null)
# iterate "$LIST" unpack_7z_file
