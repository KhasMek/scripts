#!/bin/bash

WORK=`pwd`
DATE=$(date +%m%d)
CONFIG=""
Initramfs_Directory=""
Initramfs_git=""
cd ..

if [ ! -d arm-2009q3 ]; then
        tarball="arm-2009q3-67-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2"
        if [ ! -f "$tarball" ]; then
                wget http://www.codesourcery.com/public/gnu_toolchain/arm-none-linux-gnueabi/"$tarball"
        fi
        tar -xjf "$tarball"
fi

if [ ! -d $Initramfs_Directory ]; then
        git clone $Initramfs_git
fi

cd $WORK
rm -f KhasMek."$CONFIG".Kernel."$DATE".zip
rm "$DATE"_stdlog_"$CONFIG".log
rm "$DATE"_errlog_"$CONFIG".log
make clean mrproper
make ARCH=arm khasmek_"$CONFIG"_defconfig
make -j$(grep processor /proc/cpuinfo | wc -l) CROSS_COMPILE=../arm-2009q3/bin/arm-none-linux-gnueabi- \
        ARCH=arm HOSTCFLAGS="-g -O3" 1> "$DATE"_stdlog_"$CONFIG".log 2> "$DATE"_errlog_"$CONFIG".log

cp -p arch/arm/boot/zImage update/kernel_update
cd update
zip -r -q kernel_update.zip .
mv kernel_update.zip ../KhasMek."$CONFIG".Kernel."$DATE".zip
