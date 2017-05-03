**********************
Build Mesos on Core OS
**********************

This repository contains build scripts for generating core os images with mesos binaries.

References:
- https://github.com/drcrallen/mesos-gentoo-overlay

Build
=====

To build everything automatically:

    export SHARED_USER_PASSWORD="console login password"
    ./build-image.sh

To enter into the chroot without building:
    ./build-image.sh enter
