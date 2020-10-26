#!/bin/bash

#  
#  Multi Mounter, 2015 by ppelikan
#  Mount images containing multiple partitions
#  USAGE: call multimounter as root and as the parameter provide name of the disk image file
#  Example:
#  user@user:~$ sudo ~/multimounter.sh disk_image.img
#  It will mount (in the current directory that is ~/) partitions from the image in the file disk_image.img
#  Calling it for the second time will unmount the mounted images
#  

if [ -z "$*" ] ; then
echo " ~ Multi Mounter, 2015 by ppelikan ~ "
echo "Mount images containing multiple partitions"
echo "USAGE: call multimounter as root and as the parameter provide name of the disk image file"
echo "Example:"
echo "user@user:~$ sudo ~/multimounter.sh disk_image.img"
echo "It will mount (in the current directory that is ~/) disks from the image in the file disk_image.img"
echo "Calling it for the second time will unmount the mounted images"
exit 0

fi

NAME=$(basename $1)
FDIS=$(fdisk -o device,start -l $1 | awk '/'$NAME'[1-9]/ {print $2}')
UNIT=$(fdisk -u -l $1 | grep -Eo '= [0-9]+' | awk '{print $2}')

PAR1=$(echo $FDIS | awk '{print $1}')
PAR2=$(echo $FDIS | awk '{print $2}')
PAR3=$(echo $FDIS | awk '{print $3}')
PAR4=$(echo $FDIS | awk '{print $4}')
PAR5=$(echo $FDIS | awk '{print $5}')
PAR6=$(echo $FDIS | awk '{print $6}')
PAR7=$(echo $FDIS | awk '{print $7}')
PAR8=$(echo $FDIS | awk '{print $8}')
PAR9=$(echo $FDIS | awk '{print $9}')


DIR="parition1"
if [ -n "$PAR1" ] ; then
	if [ -d "$DIR" ] ; then
	umount $DIR
	rmdir $DIR
	echo "Unmounted " $DIR 
	else
	let OFFSET1=$PAR1*$UNIT
	mkdir $DIR
	mount -o loop,offset=$OFFSET1 $1 $DIR
	echo "Mounted " $DIR 
	fi
fi

DIR="parition2"
if [ -n "$PAR2" ] ; then
	if [ -d "$DIR" ] ; then
	umount $DIR
	rmdir $DIR
echo "Unmounted " $DIR
	else
	let OFFSET2=$PAR2*$UNIT
	mkdir $DIR
	mount -o loop,offset=$OFFSET2 $1 $DIR
echo "Mounted " $DIR 
	fi
fi

DIR="parition3"
if [ -n "$PAR3" ] ; then
	if [ -d "$DIR" ] ; then
	umount $DIR
	rmdir $DIR
echo "Unmounted " $DIR
	else
	let OFFSET3=$PAR3*$UNIT
	mkdir $DIR
	mount -o loop,offset=$OFFSET3 $1 $DIR
echo "Mounted " $DIR 
	fi
fi

DIR="parition4"
if [ -n "$PAR4" ] ; then
	if [ -d "$DIR" ] ; then
	umount $DIR
	rmdir $DIR
echo "Unmounted " $DIR
	else
	let OFFSET4=$PAR4*$UNIT
	mkdir $DIR
	mount -o loop,offset=$OFFSET4 $1 $DIR
echo "Mounted " $DIR 
	fi
fi

DIR="parition5"
if [ -n "$PAR5" ] ; then
	if [ -d "$DIR" ] ; then
	umount $DIR
	rmdir $DIR
echo "Unmounted " $DIR
	else
	let OFFSET5=$PAR5*$UNIT
	mkdir $DIR
	mount -o loop,offset=$OFFSET5 $1 $DIR
echo "Mounted " $DIR 
	fi
fi

DIR="parition6"
if [ -n "$PAR6" ] ; then
	if [ -d "$DIR" ] ; then
	umount $DIR
	rmdir $DIR
echo "Unmounted " $DIR
	else
	let OFFSET6=$PAR6*$UNIT
	mkdir $DIR
	mount -o loop,offset=$OFFSET6 $1 $DIR
echo "Mounted " $DIR 
	fi
fi

DIR="parition7"
if [ -n "$PAR7" ] ; then
	if [ -d "$DIR" ] ; then
	umount $DIR
	rmdir $DIR
echo "Unmounted " $DIR
	else
	let OFFSET7=$PAR7*$UNIT
	mkdir $DIR
	mount -o loop,offset=$OFFSET7 $1 $DIR
echo "Mounted " $DIR 
	fi
fi

DIR="parition8"
if [ -n "$PAR8" ] ; then
	if [ -d "$DIR" ] ; then
	umount $DIR
	rmdir $DIR
echo "Unmounted " $DIR
	else
	let OFFSET8=$PAR8*$UNIT
	mkdir $DIR
	mount -o loop,offset=$OFFSET8 $1 $DIR
echo "Mounted " $DIR 
	fi
fi

