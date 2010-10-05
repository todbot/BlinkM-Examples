#!/bin/sh
#
# Generate distribution zip files for BlinkMSequencer
#
# 2007-2010 Tod E. Kurt, http://thingm.com/
#

BASEDIR=".."
NAME=BlinkMSequencer
VERSION=001

ARDUINO_WIN_JAVA="$HOME/Desktop/arduino/arduino-0018-win/java"

SRC_ZIP="$NAME$VERSION-src.zip"
WIN_ZIP="$NAME-win.zip"
MAC_ZIP="$NAME-mac.zip"
COMMUNICATOR_ZIP="BlinkMCommunicator.zip"
EXAMPLES_ZIP="blinkm_examples.zip"
SCRIPTTOOL_ZIP="BlinkMScriptTool.zip"

SCRIPTTOOL_BASEDIR="BlinkMScriptTool"

RXTXDIR="rxtx-arduino"

BASEDIR_MAC="../BlinkMSequencer/application.macosx"
BASEDIR_WIN="../BlinkMSequencer/application.windows"

LIBDIR_MAC="$BASEDIR_MAC/BlinkMSequencer.app/Contents/Resources/Java"
LIBDIR_WIN="$BASEDIR_WIN"

JAVADIR_MAC="$LIBDIR_MAC"
JAVADIR_WIN="$BASEDIR_WIN/lib"

FIRMWARE_ZIP="BlinkM-firmware-hex.zip"
FIRMWARE_LICENSE="docs/BlinkM_Firmware_License.txt"
FIRMWARE_BASE="../blinkmv1/blinkmv1"
FIRMWARE_FILES="$FIRMWARE_LICENSE $FIRMWARE_BASE.hex $FIRMWARE_BASE.eep $FIRMWARE_BASE-fuse.txt ../blinkmv1/Makefile-dist"

# FIXME: hack hack hack
FIRMWARE_MAXM_ZIP="BlinkM-MaxM-firmware-hex.zip"
FIRMWARE_MAXM_LICENSE="docs/BlinkM_Firmware_License.txt"
FIRMWARE_MAXM_BASE="../blinkmv2/blinkmv2"
FIRMWARE_MAXM_FILES="$FIRMWARE_MAXM_LICENSE $FIRMWARE_MAXM_BASE.hex $FIRMWARE_MAXM_BASE.eep $FIRMWARE_MAXM_BASE-fuse.txt ../blinkmv2/Makefile-dist"


cmd=$1

if [ -z "$cmd" ] ; then
    echo "Usage: $0 [all | rxtx | java | mac | win | src ]"
cat << EOF
  all  = do everything
  rxtx = update RXTX libraries
  java = copy over windows java 
  mac  = generate BlinkMSequencer Mac application zip file
  win  = generate BlinkMSequencer Windows application zip file
  src  = generate BlinkMSequencer source code zip file
  scripttool = generate BlinkMScriptTool zip file
  communicator = generate BlinkMCommunicator zip file
  examples = generate example_code zip file
  firmware = generate firmware hex zip file
  firmware-maxm = generate firmware maxm hex zip file
EOF
    exit 0
fi

if [ "$cmd" == "examples" ] || [ "$cmd" == "all" ]; then
    echo "Making example code zip file"
    pushd ../..
    echo "removing old $EXAMPLES_ZIP"
    rm -f $EXAMPLES_ZIP
    echo "creating new $EXAMPLES_ZIP"
    zip -r $EXAMPLES_ZIP blinkm_examples -x \*.svn\* -x \*DS_Store\* -x \*~ -x \*applet\* -x \*bundling-tools\*
    popd
    echo "$EXAMPLES_ZIP done"
fi



#########################################
# everything else here doesn't quite work
#

if [ "$cmd" == "rxtx" ] || [ "$cmd" == "all" ]; then
    echo "Updating RXTX jar to work like Arduino's RXTX"
    cp "$RXTXDIR/RXTXcomm.jar" "$JAVADIR_MAC"
    cp "$RXTXDIR/RXTXcomm.jar" "$JAVADIR_WIN"
    echo "Updating RXTX lib to work like Arduino's RXTX"
    cp "$RXTXDIR/librxtxSerial.jnilib" "$LIBDIR_MAC"
    cp "$RXTXDIR/rxtxSerial.dll"       "$LIBDIR_WIN"
    echo "RXTX update done"
fi

if [ "$cmd" == "java" ] || [ "$cmd" == "all" ]; then
    echo "Copying Java over for Windows version"
    pushd $BASEDIR_WIN
    cp -fr $ARDUINO_WIN_JAVA .
    popd
    echo "Java copy done"
fi

if [ "$cmd" == "win" ] || [ "$cmd" == "all" ]; then
    echo "Making Windows zip file"
    pushd $BASEDIR/$NAME
    mv application.windows $NAME-win
    zip -r ../$WIN_ZIP $NAME-win -x \*.svn\* -x \*DS_Store\* -x \*~
    mv $NAME-win application.windows
    popd
    echo "$WIN_ZIP done"
fi

if [ "$cmd" == "mac" ] || [ "$cmd" == "all" ]; then
    echo "Making Mac OS X zip file"
    pushd $BASEDIR/$NAME/application.macosx
    zip -r ../../$MAC_ZIP $NAME.app -x \*.svn\* -x \*DS_Store\* -x \*~
    popd
    echo "$MAC_ZIP done"
fi

if [ "$cmd" == "src" ] || [ "$cmd" == "all" ]; then
    echo "Making source zip file"
    pushd $BASEDIR
    zip -r $SRC_ZIP $NAME -x \*.svn\* -x \*DS_Store\* -x \*~ -x \*application\.\*
    popd
    echo "$SRC_ZIP done"
fi

if [ "$cmd" == "communicator" ] || [ "$cmd" == "all" ]; then
    echo "Making communicator zip file"
    pushd $BASEDIR/arduino
    zip -r $COMMUNICATOR_ZIP BlinkMCommunicator -x \*.svn\* -x \*DS_Store\* -x \*~ -x \*applet\*
    mv $COMMUNICATOR_ZIP $BASEDIR
    popd
    echo "$COMMUNICATOR_ZIP done"
fi

if [ "$cmd" == "scripttool" ] || [ "$cmd" == "all" ]; then
    echo "Making scripttool zip file"
    pushd $BASEDIR
    echo "removing old $SCRIPTTOOL_ZIP"
    rm $SCRIPTTOOL_ZIP
    echo "creating new $SCRIPTTOOL_ZIP"
    zip -r $SCRIPTTOOL_ZIP $SCRIPTTOOL_BASEDIR -x \*.svn\* -x \*DS_Store\* -x \*~ -x \*applet\*
    popd
    echo "$SCRIPTOOL_ZIP done"
fi

if [ "$cmd" == "firmware" ] || [ "$cmd" == "all" ]; then
    echo "Making firmware hex zip file"
    pushd $BASEDIR
    rm $FIRMWARE_ZIP
    zip -j $FIRMWARE_ZIP $FIRMWARE_FILES
    popd
fi

if [ "$cmd" == "firmware-maxm" ] || [ "$cmd" == "all" ]; then
    echo "Making firmware maxm hex zip file"
    pushd $BASEDIR
    rm $FIRMWARE_MAXM_ZIP
    zip -j $FIRMWARE_MAXM_ZIP $FIRMWARE_MAXM_FILES
    popd
fi
