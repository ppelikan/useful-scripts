#!/bin/bash

ZMNN="avr-gcc -O -mmcu=atmega8 "$1" -o program.hex"  # <<-- Tu edytuj typ mikrokontrolera (domyślnie "atmega16")

echo '=============================================================================='
echo 'START...'
echo '=============================================================================='
echo `$ZMNN`
echo "Kontynuować wgrywanie programu? [T/N]:"
read CTN

funct ()
{
echo `avr-objcopy -O ihex program.hex`
echo `avrdude -c usbasp -p m8 -U flash:w:program.hex` # <<-- Tu edytuj typ mikrokontrolera("m16") i port COM: ("/dev/ttyS0")
echo '---------------------------------   skrypt kompilujący napisał ~hufca~'
echo '=============================================================================='
echo 'GOTOWE...'
echo '=============================================================================='
}

case $CTN in
t)funct ;;
T)funct ;;
Y)funct ;;
y)funct ;;
*)
echo "PRZERWANO..."
echo '==============================================================================';;
esac


# --------------------~ INSTRUKCJA ~----------------------------------
#
# Zainstaluj pakiety:
# > gcc-avr
# > binutils-avr
# > avr-libc
# > avrdude
# Skopiuj ten plik do folderu usera (~/prg)
# Otwórz go i jeśli jest taka potrzeba wpisz we wskazanych miejscach typ swego uC i port COM
# Zapisz i zezwól na wykonywanie tego skryptu we włąściwościach -> uprawnienia
# Program w języku C zapisz do pilku w folderze usera (np. ~/program.c)
# W terminalu wpisz: ~/prg program.c
# gdzie 'program.c' to nazwa pliku w którym jest źrógło programu
# Program po próbie kompilacji zapyta czy zaprogramować mikrokontroler
# Jeśli kompilacja sie powiodła wpisz wciśnij literę T i daj enter
#
#
# by hufca
# c 2010
# ppelikan@gmail.com
#
