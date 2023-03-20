for nativescript side
s

guix install openjdk@14.0:jdk unzip

-- :jdk gets you the jdk and not just the jre which is default
-- @14.0 gets you java 14 because the latest in guix (16) seems too new for nativescript
-- ns stuff can crash without unzip

install android sdk in home, set ANDROID_HOME to it, export that variable

install cmdline tools (sdkmanager), build-tools (version 31 is latest allowed), emulator, all through sdkmanager

"platforms;android-28" required despite tns doctor saying "28 or later"

add to .bashrc (? or .bash_profile)
```
export ANDROID_HOME=/home/$USER/android-sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platforms-tools
```

guix install adb

then symlink to that in the place NS expects

ln -s /home/$USER/.guix-profile/bin/adb $ANDROID_HOME/platform-tools/adb
