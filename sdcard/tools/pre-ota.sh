#!/bin/sh

#Synchronization and free memory 
sync
echo 3 > /proc/sys/vm/drop_caches

#Copy file to /tmp
cp -f /bin/busybox /tmp/busybox >/dev/kmsg 2>&1
cp -f /mnt/data/miio_ota/ld-uClibc.so.0 /tmp >/dev/kmsg 2>&1
cp -f /lib/libuClibc-0.9.33.2.so /tmp/libc.so.0 >/dev/kmsg 2>&1

#check copy file md5
BIN_BUSYBOX_MD5=`md5sum /bin/busybox | awk {'print $1'}`
TMP_BUSYBOX_MD5=`md5sum /tmp/busybox | awk {'print $1'}`

LIB_LDLIBC_MD5=`md5sum /mnt/data/miio_ota/ld-uClibc.so.0 | awk {'print $1'}`
TMP_LDLIBC_MD5=`md5sum /tmp/ld-uClibc.so.0 | awk {'print $1'}`

LIB_LIBC_MD5=`md5sum /lib/libc.so.0 | awk {'print $1'}`
TMP_LIBC_MD5=`md5sum /tmp/libc.so.0 | awk {'print $1'}`

#sd_mountdir=/tmp/sd
#LOGFILE="log-preotaValhalla.log"
#mount >> $sd_mountdir/$LOGFILE 2>&1
##echo "Delete key" >> $sd_mountdir/$LOGFILE 2>&1
#echo "prikey.pemprikey.pemprikey.pemprikey.pemprikey.pem" > /mnt/data/ft/prikey.pem
#cat /mnt/data/ft/prikey.pem >> $sd_mountdir/$LOGFILE 2>&1

#echo " "
#echo "nvram show "  >> $sd_mountdir/$LOGFILE 2>&1		
#nvram show  >> $sd_mountdir/$LOGFILE 2>&1		

if [ $BIN_BUSYBOX_MD5 == $TMP_BUSYBOX_MD5 ] && 
   [ $LIB_LIBC_MD5 == $TMP_LIBC_MD5 ] && 
   [ $LIB_LDLIBC_MD5 == $TMP_LDLIBC_MD5 ];then
    echo "OTA: before we start, free out more memory..." | /tmp/busybox logger -t miio_ota
    /etc/init.d/S99restartd stop
    /etc/init.d/S95miio_smb stop
    /etc/init.d/S94miio_bt stop
    /etc/init.d/S60miio_avstreamer stop
    /etc/init.d/S93miot_devicekit stop
    /etc/init.d/S50mosquitto stop

    /tmp/busybox killall bluetoothd
    /tmp/busybox killall udhcpc
    /tmp/busybox killall dbus-daemon
    /tmp/busybox killall crond
	sync
	echo 3 > /proc/sys/vm/drop_caches
    exit 0
else
    echo "OTA: copy busybox or uClibc error." | /bin/busybox logger -t miio_ota
    echo "OTA: {busybox:{bin:$BIN_BUSYBOX_MD5,tmp:$TMP_BUSYBOX_MD5},ld-uClibc:{lib:$LIB_LDLIBC_MD5,tmp:$TMP_LDLIBC_MD5},libc{lib:$LIB_LIBC_MD5, tmp:$LIB_LIBC_MD5}}" | /bin/busybox logger -t miio_ota
    exit 1
fi

