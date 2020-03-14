#!/bin/bash

# Script unpacking multiple archives using brute force by trying multiple passwords
# (c) 2018 ppelikan
# https://github.com/ppelikan


IFS=$'\n'                             #ustawiamy separator zamiast spacji, to na nową linię 
PASWORDS=$(cat $1 2>/dev/null)        #wczytujemy plik haseł, wszystkie błędy do null
MAINDIR=$PWD                          #położenie wywołania skrytpu

unpack_rar_file() { #argumenty: nazwa pliku rar
    rar -y -p"$2" x "$1" &>/dev/null   #rozpakowujemy plik $1 przy użyciu hasła 
    return $?
}

unpack_7z_file() { #argumenty: nazwa pliku 7z
    7z -y -p"$2" x "$1" &>/dev/null
    return $?
}

try_all_pass() { #argumenty: wskaźnik funkcji wypakowującej, nazwa pliku
    IFS=$'\n'
    for pass in $PASWORDS; do         #iteracja po wszystkich hasłach z pliku haseł
        echo -n '.'                   #test każdego hasła = print jednej kropki
        $1 $2 $pass                   #wywołaj funkcję rozpakowującą
        if [[ $? == 0 ]]; then        #udało się wypakować
            echo -e -n "\n"           #zamykamy progressbar
            return 0
        fi
    done
    echo -e "\nŻadne hasło nie pasuje!"
    return 1
}

unpack_procedure() { #argumenty: wskaźnik funkcji wypakowującej, nazwa pliku
    IFS=$'\n'
    xbase=${2##*/}                   #z parametru wycinamy nazwę pliku
    temp_dir="_unpack_${xbase%.*}"   #i na podstawie tej nazwy tworzymy nazwę tymczasowego katalogu
    mkdir "$temp_dir" 2>/dev/null    #tworzymy katalog o tej nazwie
    # echo "$PWD"
    #echo "$temp_dir"
    cd "$temp_dir"
    try_all_pass $@                  #próbujemy rozpwakować
    if [[ $? == 0 ]]; then    #jeśli udało się rozpakować
        # echo "OKOKOKOKOKOKOKOK"
        filecount=$(
            shopt -s nullglob
            set -- *
            echo $#
        )
        if [[ $filecount == 1 ]]; then #jeśli nasz katalog zawiera tylko 1 plik
            mv -n * ..                 #przenieś go katalog wyżej
        fi
        filecount=$(
            shopt -s nullglob
            set -- *
            echo $#
        )
        if [[ $filecount == 0 ]]; then #jeśli teraz już katalog jest pusty //TODO Można uprościć!
            # if [ -z "$(ls -A $temp_dir)" ]; then
            cd "$MAINDIR"
            #rm -r "$temp_dir"
            rmdir "$temp_dir"          #usuwamy go
        fi
    else                            #jeśli nie udało się wypakować pliku
        # echo "FAILFAILFAILFIALFIALFIALFIALFAIFAIL"
        filecount=$(
            shopt -s nullglob
            set -- *
            echo $#
        )
        if [[ $filecount == 0 ]]; then  #oraz katalog jest pusty
            cd "$MAINDIR"
            rmdir "$temp_dir"           #kasujemy go
        fi
        return 1                    #oraz zwracamy błąd rozpakowania
    fi
    return 0    #brak blędu
}

iterate() { #argumenty:lista plików, wskaźnik funkcji wypakowującej
    IFS=$'\n'
    for file in $1; do  #iteracja po podanej liście plików
        cd "$MAINDIR"
        echo "Unpacking: $file"
        unpack_procedure $2 "$MAINDIR/$file"     #próbuj wypakować
        if [[ $? != 0 ]]; then
            echo "Nie udało się wypakować pliku!"
        else
            rm -f "$MAINDIR/$file"          #jeśli udało się wypakować, to usuwamy plik (rozpakowanego już) archiwum
        fi
    done
}

if [ -z "$1" ]; then
    echo "Nie podałeś nazwy pliku zawierającego listę haseł!"
    exit 1
fi

if [ -z "$PASWORDS" ]; then
    echo "Podany plik nie zawiera żadnych haseł!"
    exit 1
fi

LIST=$(ls *.rar 2>/dev/null)
iterate "$LIST" unpack_rar_file     #jako drugi parametr podajemy nazwę funkcji rozpakowującej
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
