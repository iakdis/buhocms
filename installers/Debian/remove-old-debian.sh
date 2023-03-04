#!/bin/bash

# Specify opt and bin directory for binary data
OPT=BuhoCMS/opt/buhocms
BIN=BuhoCMS/usr/bin

# Bundle information for deleting previous bundles
DATA=data
LIB=lib
EXECUTABLE=buhocms

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

# Go to Debian project directory (buhocms/opt/BuhoCMS)
cd ../../..

# Define link
EXEC=$BIN/buhocms

# Delete old link, if it exists
if [ -L $EXEC ]; then
    rm $EXEC
fi

# Specify the final app name
FINAL=BuhoCMS-Linux.deb

# If the final app exists, remove it
if [ -f $FINAL ]; then
    rm $FINAL
fi
