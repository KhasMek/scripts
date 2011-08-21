#!/bin/sh
# This script is to assist in the automation of downloading all necessary
# packages for a gingerbread Android platform build enviornment. This has
# been tested only on Ubuntu 11.04 but should work on any Debian based system.
# Made by KhasMek 2011. Use it, don't kang it.
# v0.1
# TODO: add options for sudo passwd, adding custom manifests echoback
# dialog, custom folders, setup git ssh key, custom number of threads for
# repo sync.

#set -x
# Setting up variables
while getopts "d:m:b:" opt
do
        case "$opt" in
                d) Working_Directory=`readlink -f "$OPTARG"`;;
                m) Custom_Manifest=`readlink -f "$OPTARG"`;;
		b) Manifest_Branch=`readlink -f "$OPTARG"`;;
        esac
done

if [ "$Working_Directory" = "" ]; then
        echo "[}-!-!- You have not specified a working directory, defaults will be used (Android) -!-!-{]"
	Working_Directory=~/Android/
else
        echo "[}----- The working directory is $Working_Directory -----{]"
fi

# Setting up the build enviornment
echo "[}----- Checking for necessary directories -----{]"
if test -d ~/bin ; then
	echo "[}----- ~/bin exists, assuming it's already been added to PATH -----{]"
fi
if ! test -d ~/bin ; then
        echo "[}----- ~/bin does not exist, creating it now -----{]"
	mkdir ~/bin
	PATH=~/bin:$PATH
fi

echo "[}----- Checking for repo binary with execute permissions -----{]"
if test -x ~/bin/repo ; then
	echo "[}----- Binary exists with correct permissions -----{]"
fi
if ! test -x ~/bin/repo ; then
        echo "[}----- Downloading repo binary -----{]"
	rm -f ~/bin/repo
	curl https://android.git.kernel.org/repo > ~/bin/repo
	chmod a+x ~/bin/repo
fi

if [ "$Custom_Manifest" = "" ]; then
        echo "[}-!-!- You have not specified a custom platform manifest, defaults will be used (CM7) -!-!-{]"
        Custom_Manifest=git://github.com/CyanogenMod/android.git
else
        echo "[}----- The platform manifest to be used is $Custom_Manifest ----{]"
fi

if [ "$Manifest_Branch" = "" ]; then
        echo "[}-!-!- You have not specified a branch for the platform manifest, defaults will be used (gingerbread) -!-!-{]"
        Manifest_Branch=gingerbread
else
        echo "[}----- The branch to sync is $Manifest_Branch -----{]"
fi

echo "[}----- Checking for $Working_Directory -----{]"
if test -d $Working_Directory ; then
	echo "[}----- $Working_Directory exists, hopefully it's empty -----{]"
fi
if ! test -d $Working_Directory ; then
	echo "[}----- Creating Working Directory -----{]"
	mkdir $Working_Directory
fi

# Checking for and downloading necessary packages
echo "[}----- Adding necessary Ubuntu repositories -----{]"
sudo add-apt-repository "deb http://archive.canonical.com/ lucid partner"
echo "[}----- Updating Ubuntu repository database -----{]"
sudo apt-get -qq update
echo "[}----- Installing all programs necessary for building Android -----{]"

sudo apt-get -q -y install git-core gnupg flex bison gperf build-essential zip curl \
     zlib1g-dev libc6-dev lib32ncurses5-dev ia32-libs x11proto-core-dev \
     libx11-dev lib32readline5-dev lib32z-dev libgl1-mesa-dev g++-multilib \
     mingw32 tofrodos pngcrush schedtool sun-java6-jdk

# Maybe I'll impliment this at some point, just as a reference for now
#cd ~
#echo "[}----- Downloading arm toolchain to ~ -----{]"
#echo "[}----- Be sure to modify you the toolchain location in your kernel build scripts -----{]"
#wget http://www.codesourcery.com/public/gnu_toolchain/arm-none-linux-gnueabi/arm-2009q3-67-arm-none-linux-gnueabi-i686-pc-l$
#tar -xjf arm-2009q3-67-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
# rm -f arm-2009q3-67-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2

cd $Working_Directory
echo "[}----- Initializing repositories -----{]"
repo init -u $Custom_Manifest -b $Manifest_Branch
echo "[}----- Syncing repositories -----{]"
repo sync -j20
#echo "[}----- I like to sync once more with just one thread to make sure it synced correctly -----{]"
repo sync
echo "[}----- Sync complete -----{]"
echo "[}----- Build enviornment set up complete -----{]"
exit
