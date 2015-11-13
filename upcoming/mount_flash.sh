#!/bin/bash -e
while [ ! -e /dev/disk/by-label/login_data ]; do echo "Waiting for flash to be inserted." ; sleep 1; done
gvfs-mount -u -d /dev/$(basename $(readlink /dev/disk/by-label/login_data ) )
bash /media/login_data/init
gvfs-mount -u /media/login_data
while [ -e /dev/disk/by-label/login_data ]; do echo "Waiting for flash to be removed." ; sleep 1; done

