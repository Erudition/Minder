#!/usr/bin/env fish

echo In env. Setting vars;

# So we can get all these foreign binaries to actually run
set -Ux LD_LIBRARY_PATH /lib:/lib/nss:$ANDROID_HOME/emulator/lib64/qt/lib:$ANDROID_HOME/emulator/lib64:$LIBRARY_PATH

# Nativescript and Android SDK stuff need JAVA_HOME set
set -Ux JAVA_HOME (dirname (dirname (readlink -e (which java))))
# can be gotten with java -XshowSettings:properties -version 2>&1 > /dev/null | grep 'java.home'
# also gradle needs this too

#For convenient access to node programs like nativescript (so you can just type "ns")
fish_add_path ./node_modules/.bin

# Set to wherever your SDK is
set -Ux ANDROID_HOME /home/$USER/android-sdk  #TODO package it and then add as dep

fish_add_path $ANDROID_HOME/platform-tools

# OTHER CHANGES TO MAKE IT WORK
# had to change gradle version to 7.6 as in https://stackoverflow.com/questions/72149907/how-to-change-gradle-version-in-nativescript