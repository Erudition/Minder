#!/usr/bin/env fish

echo In env. Setting vars;

# So we can get all these foreign binaries to actually run
set -Ux LD_LIBRARY_PATH /lib:/lib/nss  #:$ANDROID_HOME/emulator/lib64/qt/lib:$ANDROID_HOME/emulator/lib64 

# Nativescript and Android SDK stuff need JAVA_HOME set
set -Ux JAVA_HOME (dirname (dirname (readlink -e (which java))))

#For convenient access to node programs like nativescript (so you can just type "ns")
fish_add_path ./node_modules/.bin

# Set to wherever your SDK is
set -Ux ANDROID_HOME /home/adroit/android-sdk  #TODO package it and then add as dep


