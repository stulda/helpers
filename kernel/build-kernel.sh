#!/bin/bash

# This script is used to build the kernel (gentoo)

VERSION="6.1.70-gentoo"
EXTRAVERSION="-webnest"
KERNEL_DIR="/usr/src/linux"
CORES=$((`nproc`+1))
USE_LLVM=true

if [ ! -d $KERNEL_DIR ]; then
    echo "Previous kernel version not found."
    exit 1
fi

if [ ! -L $KERNEL_DIR ]; then
    echo "Linux directory is not a symlink."
    exit 1
fi

if [ ! -d $KERNEL_DIR-$VERSION ]; then
    echo "Kernel version directory does not exists."
    exit 1
fi

if [ `readlink -f $KERNEL_DIR` = $KERNEL_DIR-$VERSION ]; then
    echo "Linux symlink already points to the version directory."
    exit 1
fi

if [ ! -f "$KERNEL_DIR/.config" ]; then
    echo "Kernel config file does not exists."
    exit 1
fi

cp $KERNEL_DIR/.config $KERNEL_DIR-$VERSION/.config

unlink $KERNEL_DIR
ln -s $KERNEL_DIR-$VERSION $KERNEL_DIR

cd $KERNEL_DIR

sed -i "s/EXTRAVERSION =.*/EXTRAVERSION = $EXTRAVERSION/" Makefile

if $USE_LLVM;
then
    echo "Using LLVM"
    nice make LLVM=1 LLVM_IAS=1 -j$CORES && make modules_install && make install
else
    echo "Using GCC"
    nice make -j$CORES && make modules_install && make install
fi

grub-mkconfig -o /boot/grub/grub.cfg

echo "Kernel build complete."
