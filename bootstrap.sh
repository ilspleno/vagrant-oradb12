#!/bin/bash  -x

#   configure and mount second disk 
#
yum install -y parted
parted /dev/sdb mklabel msdos
parted /dev/sdb mkpart primary 512 100%
mkfs.xfs /dev/sdb1
mkdir /u01
echo `blkid /dev/sdb1 | awk '{print$2}' | sed -e 's/"//g'` /u01   xfs   noatime,nobarrier   0   0 >> /etc/fstab
mount /u01
