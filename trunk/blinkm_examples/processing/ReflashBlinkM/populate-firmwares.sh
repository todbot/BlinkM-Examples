#!/bin/sh
#
#
#
#
#

rsync -arvz --exclude=.svn tools application.macosx/ReflashBlinkM.app/Contents/Resources/Java/

rsync -arvz --exclude=.svn tools application.windows/lib

#rsync -arvz --exclude=.svn tools application.linux/lib

