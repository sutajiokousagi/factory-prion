#!/bin/sh
#
# This burns a Linux image for a Silvermoon device on a Falconwing device.
# It's designed to be used in the factory.
# To use it, copy it to a working Falconwing unit, then copy the following
# to a subdirectory on /mnt/storage:
#       boot.bin
#       bootstream-factory.bin
#       ebr.bin
#       mbr.bin
#       psp-factory/
#       rfs.tar.gz
#       psp.tar.gz
#       write_bootstream
# Then, run:
#   burn_image_linux.sh <sd_device> <path_to_subdirectory>
# The /mnt/storage/factory/userhook0 is called via dot-exec from
# /psp/rfs1/userhook0 with ${BURN_CONFIG} passed as a parameter


# Default to /mnt/storage/factory so die() can work early on.
SOURCE_ARCHIVE=/mnt/storage/factory

die() {
    echo "Fail: $*" > /dev/ttyAM0
    echo "Failed: $*" >> /mnt/storage/burnlog.txt
    imgtool --mode=draw ${SOURCE_ARCHIVE}/fail.jpg
    exit 1
}

unmount_all_partitions() {
    if [ "x$1" = "x" ]
    then
        die "Usage: unmount_all_partitions [device]"
    fi
    
    for i in $(ls $1[0-9]*)
    do
        if [ $(mount | grep $i | wc -l) -gt 0 ]
        then
            umount $i || die "Unable to unmount $i"
        fi
    done
}


if [ "x$1" = "x" -o "x$2" = "x" ]
then
    echo "Usage: $0 [SD image] [target-archive]"
    die "e.g. $0 /dev/sda /mnt/storage/images"
fi

TARGET_DISK="$1"
SOURCE_ARCHIVE="$2"
RFS_MOUNTPOINT=/tmp/install_rfs
MOUNT_OPTIONS=noatime,async
ROM_NAME=rom-${BURN_CONFIG}.img

. /etc/profile


# udev is most likely dead, so make nodes ourselves.
mknod /dev/sda  b 8 0
mknod /dev/sda1 b 8 1
mknod /dev/sda2 b 8 2
mknod /dev/sda3 b 8 3
mknod /dev/sda4 b 8 4
mknod /dev/sda5 b 8 5




# Unmount all of the target disk's partitions.
unmount_all_partitions ${TARGET_DISK}


echo -n "Writing SD card..." > /dev/ttyAM0
FILESIZE=$(ls -l ${SOURCE_ARCHIVE}/${ROM_NAME} | awk '{print $5}')
imgtool --mode=draw ${SOURCE_ARCHIVE}/burning-progress.jpg
cat ${SOURCE_ARCHIVE}/${ROM_NAME} | progress -b ${FILESIZE} -f 0 > ${TARGET_DISK} || die "Couldn't write ROM"
echo " " > /dev/ttyAM0
sleep 1



# Verify that the first 200 megabytes or so matches the known MD5 sum.
imgtool --mode=draw ${SOURCE_ARCHIVE}/verify-progress.jpg
DD_MD5=$(dd skip=1 if=/dev/sda bs=1M count=100 | progress -b $((1024*1024*100)) -f | md5sum | cut -d' ' -f1)
IMG_MD5=$(cat ${SOURCE_ARCHIVE}/${ROM_NAME}.md5)
if [ "x${DD_MD5}" != "x${IMG_MD5}" ]
then
    echo "MD5 sums don't match!  IMG: ${IMG_MD5}  Tested: ${DD_MD5}" > /mnt/storage/burnlog.txt
    echo "MD5 sums don't match!  IMG: ${IMG_MD5}  Tested: ${DD_MD5}" > /dev/ttyAM0
    imgtool --mode=draw --fb=0 ${SOURCE_ARCHIVE}/epic-fail.jpg
    exit 1
fi


# All done, burning was a success.
echo "Image prepared" > /dev/ttyAM0
echo "Please unplug the USB drive" > /dev/ttyAM0
exit 0
