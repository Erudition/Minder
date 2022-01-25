#!/run/current-system/profile/bin/bash

export PROFILE=$(guix environment --container --network -m ./guix-env/dev-env.scm \
  -- bash -c 'echo $GUIX_ENVIRONMENT')

/home/adroit/android-sdk/platform-tools/adb devices # for some reason deamon should be started outside container


guix environment --container --network --share=$XAUTHORITY --share=/tmp/.X11-unix \
    --share=/dev/shm --expose=/etc/machine-id --share=/home/$USER \
    --expose=$PROFILE/lib=/lib --expose=$PROFILE/lib=/lib64  \
    --share=/dev/kvm \
    --share=/dev/ttyACM0 \
    --share=/dev/serial \
    --share=/dev/bus/usb \
    --expose=/usr/bin/=/usr/bin \
    -m ./guix-env/dev-env.scm \
    -- env XAUTHORITY=$XAUTHORITY DISPLAY=$DISPLAY  \
    TERM=$TERM  \
    fish -C ./guix-env/inside-env.sh
