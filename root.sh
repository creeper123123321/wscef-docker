#!/bin/bash

# Very cursed workaround for "not PID 1"
# Note that it will generate SSL CA certs
mv /bin/systemctl /bin/systemctl.bak
apt -y install /src/warsaw.deb

# TODO why is dbus linked?
/etc/init.d/dbus start
/etc/init.d/warsaw start

# Run Firefox as non privileged user
setpriv --reuid=$USER_ID --regid=$GROUP_ID --init-groups --inh-caps=-all --reset-env env DISPLAY=$DISPLAY LANG=$LANG TZ=$TZ startup.sh
