#!/bin/sh

bootloader==${1%}

sudo ./nvflash --bl bootloader.bin --go
sudo ./nvflash --resume --download 8 "$bootloader"
