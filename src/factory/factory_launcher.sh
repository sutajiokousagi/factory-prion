#!/bin/sh

die() {
    echo "Fail: $*" > /dev/ttyAM0
    echo "Failed: $*" >> /mnt/storage/burnlog.txt
    rm -f /tmp/burn-in-progress
    exit 1
}
            
            
if [ -e /tmp/burn-in-progress ]
then
    exit 0
fi

# If we haven't fully  booted yet, pass it to the normal mount-adding process
if [ ! -e /tmp/fully-booted ]
then
    exec /usr/chumby/scripts/add-mount.sh $1
fi

# Only allow "/dev/sda" to start us burning.  This means that
# already-partitioned disks won't cause us to fork off lots and lots of
# burner processes.
if [ "x$1" != "x/dev/sda" ]
then
    exit 0
fi

# Get BURN_CONFIG and other vars set at build time
[ -e /mnt/storage/factory/config.vars ] && . /mnt/storage/factory/config.vars

killall udevd


clear > /dev/ttyAM0
imgtool --mode=draw /mnt/storage/factory/burning-1.jpg
echo "Beginning burn..." > /dev/ttyAM0

touch /tmp/burn-in-progress
if /mnt/storage/factory/burn_image_linux.sh /dev/sda /mnt/storage/factory/
then
    echo "Pass" > /dev/ttyAM0
    printpass.pl > /dev/ttyAM0
    imgtool --mode=draw /mnt/storage/factory/pass.jpg
else
    echo "Failed" > /dev/ttyAM0
    imgtool --mode=draw /mnt/storage/factory/fail.jpg
#    printfail.pl
fi
/usr/chumby/scripts/switch_fb.sh 0

rm -f /tmp/burn-in-progress

udevd --daemon
echo "Succeeded" >> /mnt/storage/burnlog.txt
