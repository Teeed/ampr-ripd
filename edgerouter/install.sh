#!/bin/bash

cp ampr-ripd /usr/sbin/
chmod +x /usr/sbin/ampr-ripd

mkdir /var/lib/ampr-ripd
cp ampr.sh /etc/
chmod +x /etc/ampr.sh

if [ -f /config/scripts/post-config.d/ampr.sh ];
then
    rm /config/scripts/post-config.d/ampr.sh
fi

if [ -z $(grep "/etc/ampr.sh" "/etc/rc.local") ];
then
    sed -i -e '$i /etc/ampr.sh\n' /etc/rc.local
fi
