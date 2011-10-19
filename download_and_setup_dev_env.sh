#!/bin/sh
# This script is to assist in the automation of downloading all necessary
# packages for a gingerbread Android platform build enviornment. This has
# been tested only on Ubuntu 11.04 but should work on any Debian based system.
# Made by KhasMek 2011. Use it, don't kang it.
# v1.1
# TODO: add options for sudo passwd, setup git ssh key, custom number of
# threads for repo sync.
#
# What's New:
# Ver. 1.1
# -Fixed custom triggers- If you want to specify a custom branch or working
#  directory you now must do that inside the script (don't think most will
#  use this feature, so I trimmed down the fat a little bit.
# -New way of calling manifests- CM7 is now the default, but additional ones
#  wil now be called via ROM name and not manifest URL, this will make it
#  easier for the average user that doesn't know how to find the manifests
#  on GitHub, etc.
#
# Usage:
#  ./download_and_setup_dev_env.sh Manifest
#    Current available manifests are
#	vanilla (jt1134's vanilla AOSP ROM)
#	OMGB (r2doesinc and companies AOSP ROM)
#	OMFGB (r2doesinc and companies AOSP based ROM)
#	pool_party (Team Sbrissenmod's AOSP based ROM)
#	AOSP (Googles official, stock Android ROM)
#
#  If no manifest is specified, CyanogenMod will be used.
#
# If an option is not called defaults will be used.
# Current defaults are:
# Working_Directory=~/Android
# Custom_Manifest=git://github.com/CyanogenMod/android.git (CM7)
# Manifest_Branch=gingerbread
#

#set -x
# Setting up variables if the user really wants to.
# Defaults are Working_Directory="Android" and Manifest_Branch="gingerbread"
Manifest=${1}
Working_Directory=""
Manifest_Branch=""
repo=http://dl-ssl.google.com/dl/googlesource.com/git-repo/repo

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
	curl "$repo" > ~/bin/repo
	chmod a+x ~/bin/repo
fi

if [ "$Manifest" = "" ]; then
        echo "[}----- You have not specified a platform manifest, defaults will be used (CyanogenMod) -----{]"
        Manifest=git://github.com/CyanogenMod/android.git
else
	if [ "$Manifest" = "vanilla" ]; then
	        echo "[}----- You have chosen jt1134's Vanilla ROM -----{]"
	        Manifest=git://github.com/jt1134/platform_manifest.git
	else
		if [ "$Manifest" = "AOSP" ]; then
		        echo "[}----- You have chosen Googles Stock AOSP ROM -----{]"
		        Manifest=git://android.git.kernel.org/platform/manifest.git
		else
			if [ "$Manifest" = "OMGB" ]; then
			        echo "[}----- You have specified OMGB -----{]"
			        Manifest=git://github.com/OMGB/manifest.git
				if [ "$Manifest_Branch" = "" ]; then
					Manifest_Branch=master
				fi
			else
				if [ "$Manifest" = "OMFGB" ]; then
				        echo "[}----- You have specified OMFGB -----{]"
				        Manifest=git://github.com/OMFGB/manifest.git
					if [ "$Manifest_Branch" = "" ]; then
						Manifest_Branch=master
					fi
				else
					if [ "$Manifest" = "pool_party" ]; then
					        echo "[}----- You have specified Team Sbrissenmod's Pool Party. -----{]"
					        Manifest=git://github.com/teamSbrissenmod/manifest.git
						if [ "$Manifest_Branch" = "" ]; then
							Manifest_Branch=master
					fi
				else
						if [ "$Manifest" != "vanilla" ] && [ "$Manifest" != "AOSP" ] && [ "$Manifest" != "OMGB" ] && [ "$Manifest" != "OMFGB" ] && [ "$Manifest" != "pool_party" ]; then
							echo "[}-!-!- You have not specified a valid platform manifest. -!-!-{]"
							echo "[}-!-!- Halting -!-!-{]"
							exit
						fi
					fi
				fi
			fi
		fi
	fi
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
     mingw32 tofrodos pngcrush schedtool sun-java6-jdk gitk git-gui

# Maybe I'll impliment this at some point, just as a reference for now
#cd ~
#echo "[}----- Downloading arm toolchain to ~ -----{]"
#echo "[}----- Be sure to modify you the toolchain location in your kernel build scripts -----{]"
#wget http://www.codesourcery.com/public/gnu_toolchain/arm-none-linux-gnueabi/arm-2009q3-67-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
#tar -xjf arm-2009q3-67-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2
# rm -f arm-2009q3-67-arm-none-linux-gnueabi-i686-pc-linux-gnu.tar.bz2

cd $Working_Directory
echo "[}----- Initializing repositories -----{]"
repo init -u $Manifest -b $Manifest_Branch
echo "[}----- Syncing repositories -----{]"
repo sync -j20
#echo "[}----- I like to sync once more with just one thread to make sure it synced correctly -----{]"
repo sync
echo "[}----- Sync complete -----{]"
echo "[}----- Build enviornment set up complete -----{]"
exit
