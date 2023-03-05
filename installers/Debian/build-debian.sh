#!/bin/bash

# Specify opt and bin directory for binary data
OPT=BuhoCMS/opt/buhocms
BIN=BuhoCMS/usr/bin

# Bundle information for deleting previous bundles
DATA=data
LIB=lib
EXECUTABLE=buhocms
INSTALLERS=installers/Debian

# Go to the opt directory
cd $OPT

# Remove data folder, if it exists
if [ -d $DATA ]; then
    rm -r $DATA
fi

# Remove lib folder, if it exists
if [ -d $LIB ]; then
    rm -r $LIB
fi

# Remove executable, if it exists
if [ -f $EXECUTABLE ]; then
    rm $EXECUTABLE
fi

# Go to Flutter project directory (buhocms/opt/BuhoCMS/Debian/installers)
cd ../../../../..

# Build Linux app
flutter build linux

# Copy final bundle into opt directory
cp -r build/linux/x64/release/bundle/* $INSTALLERS/$OPT

# Specify the automatically generated output name in addition to the final name to which the file will be renamed to
OUTPUT=BuhoCMS.deb
FINAL=BuhoCMS-Linux.deb
EXEC=$BIN/buhocms

cd $INSTALLERS

# Delete old link
if [ -f $EXEC ]; then
    rm $EXEC
fi

# Create link
cd $BIN
ln -s ../../opt/buhocms/buhocms buhocms
cd ../../..

# Build Debian package
dpkg-deb --build BuhoCMS

# If the build was successfull, rename the .deb file
if [ -f "$OUTPUT" ]; then
    mv $OUTPUT $FINAL
fi
