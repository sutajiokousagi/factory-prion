Factory Prion Image
===================


This will build a "Factory Prion" for a chumby One, used to turn it into a
ROM burner for use in a factory.  It has been used to cheaply burn SD images
for everything from chumby One devices to Kovan robotics platforms.

Overview
----------

The prion deposits a payload onto the system that will monitor USB drive
insertions, and will immediately begin to write the contents of the ROM
image to it.  Afterwards, it will read a certain amount of data back and
verify its integrity.  If the sum passes, it will display pass.jpg, and if
it fails it will display fail.jpg.

A log of the prion creation/update process will be saved on /mnt/storage/
as well as on the USB drive that was used to update the chumby One.  The
log is simply ROT-13 translated.


Updating
--------

To update a chumby One that has been turned into a burner, first turn it off,
then insert the factory prion into the USB drive.  Turn the device on, then
wait for it to indicate success.

Note that *any* USB drive inserted into a factory burner while it is
turned on will be burned with the factory image.  Because of this, you *must*
turn the chumby One off and have the USB drive inserted when power is applied
in order for the update to be applied.


Resetting
---------

In order to reset the factory burner to normal functionality, first turn it off,
then hold down the touchscreen and turn it back on.  When the control panel
starts up, select "Restore factory defaults".

When the unit powers up again, no trace of the factory burn process is left.
