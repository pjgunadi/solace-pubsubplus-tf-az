#!/bin/bash
#Create Physical Volumes
pvcreate /dev/${device_name}

#Create Volume Groups
vgcreate data-vg /dev/${device_name}

#Create Logical Volumes
lvcreate -L ${disk_size}G -n data-lv data-vg

#Create Filesystems
mkfs.ext4 /dev/data-vg/data-lv

#Create Directories
mkdir -p /var/lib/docker

#Add mount in /etc/fstab
cat <<EOL | tee -a /etc/fstab
/dev/mapper/data--vg-data--lv /var/lib/docker ext4 defaults 0 0
EOL

#Mount Filesystems
mount -a
