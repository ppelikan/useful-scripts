#!/bin/bash

# SKRYPT PROGRAMUJĄCY STM32 przy użyciu openocd
# ABY DOSTOSOWAĆ GO DO WŁASNYCH POTRZEB PRZECZYTAJ PONIŻSZE KOMENTARZE
# > aby zmienić interfejs programowania edytuj fragment:            interface/jlink.cfg 
# > aby zmienić rodzaj programowanego układu edytuj fragment:       target/stm32.cfg 
# > aby zmienić lub wyzerować początkowy adres pamięci 
#    do ktorej będzie zapisywany program edytuj fragment:           0x08000000

MEMADDR="0x08000000" #TUTAJ EDYTOWAĆ: początkowy adres pamięci programu w µC (potrzebne dla plików bin), gdyby były proglemy zostawić puste
AA=""

init ()
{
openocd -f interface/stlink-v2.cfg -f target/stm32f4x_stlink.cfg  #wywołanie OpenOcd, inicjacja połączenia, TUTAJ ZMIENIAJ: programator oraz docelowy µC
}

prog ()
{
 (
sleep 1 
 echo "halt"
 sleep 1
 echo "reset halt"
 sleep 1
 echo $AA
 sleep 30                   # czekaj 4 sekundy, aż zostanie wgrany program
 sleep 1
 echo "resume"
 sleep 1
 echo "reset"
 echo "exit"
 ) | telnet localhost 4444
}

hlp ()
{
echo "  Skrypt programujący STM32 by hufca"
echo "  Składnia:"
echo "   prg NazwaPliku TypPliku"
echo "  TypPliku może być: hex lub bin"
}

case $1 in
"")hlp
   exit 0 ;;
*) ;;
esac

case $2 in
hex) AA="flash write_image erase unlock "$1"" ;;
bin) AA="flash write_image erase unlock "$1" "$MEMADDR" bin" ;;
*) hlp
   exit 0 ;; 
esac

echo "====================================================="
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = ="
init ASDF &      #inicjuje połaczenie
sleep 2
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = ="
prog             #otwiera telnet i wysyła polecenia zaprogramowania µC
sleep 1
killall openocd  #zamyka openocd
echo "= = = = = = = = = = = = = = = = = = = = = = = = = = ="
echo "====================================================="

#
#
# by hufca 
# c 2011
#
#
