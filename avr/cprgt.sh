#!/bin/bash

ZMNN="avr-gcc -O -mmcu=attiny2313 "$1" -o program.hex"  # <<-- Tu edytuj typ mikrokontrolera (domyślnie "atmega16")
FUSY="-U lfuse:w:0xce:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m "
echo '=============================================================================='
echo 'START...'
echo '=============================================================================='
echo `$ZMNN`
echo `avr-objcopy -O ihex program.hex`
echo "Kontynuować wgrywanie programu? [T/N]:"
read CTN

funct ()
{
echo `avrdude -c siprog -p t2313 -P /dev/ttyS0 -U flash:w:program.hex $FUSY` # <<-- Tu edytuj typ mikrokontrolera("m16") i port COM: ("/dev/ttyS0")
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
#
#
