#!/bin/bash

# Specify the output name
OUTPUT=BuhoCMS-Linux-Portable.tar.gz
FINAL=../../../../../installers/BuhoCMS-Linux-Portable.tar.gz

# Go into bundle directory and create the archive
cd ../build/linux/x64/release/bundle
tar -czf $OUTPUT data lib buhocms

# If creating the archive was successful, move the archive
if [ -f "$OUTPUT" ]; then
    mv $OUTPUT $FINAL
fi
