#!/bin/sh
#
#
#
# Use rsync instead of cp -r so we can exclude the .svn stuff
#

rsync -arvz --exclude=.svn tools application.macosx/ReflashBlinkM.app/Contents/Resources/Java/

rsync -arvz --exclude=.svn tools application.windows
# also need USB driver for some reason, rxtx dll given to us
cp tools/bin-windows/libusb0.dll application.windows

#rsync -arvz --exclude=.svn tools application.linux/lib

# package up

mv application.macosx/ReflashBlinkM.app .
zip -r ReflashBlinkM-macosx.zip ReflashBlinkM.app

mv application.windows ReflashBlinkM-windows
zip -r ReflashBlinkM-windows.zip ReflashBlinkM-windows
