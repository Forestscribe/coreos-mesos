#!/bin/bash

function finish {
    rm -f /tmp/cork-buildscript.sh
    echo "Finished build script"
}
trap finish EXIT

ARG1=$1
shift

DO_BUILD=true
DO_ENTER_AND_LEAVE=false

if [[ $ARG1 == "enter" ]]; then
    DO_BUILD=false
    DO_ENTER_AND_LEAVE=true
fi

echo "Build custom CoreOS image with mesos"
echo "Supported build environments: Ubuntu 17.04"

echo "Enter root password if needed for futur sudo commands:"
sudo -v
if [ -z $SHARED_USER_PASSWORD ]; then
    echo "Please enter console login password"
    read -s "SHARED_USER_PASSWORD"
# echo "SHARED_USER_PASSWORD=$SHARED_USER_PASSWORD" # FOR DEBUG
else
    echo "Console login password set"
fi

which go > /dev/null
[ $? == 1 ] && ( echo "You need Go to compile !" && exit 1)
echo "Found Go: $(go version)"

which git > /dev/null
[ $? == 1 ] && ( echo "You need git to compile !" && exit 1)
echo "Found git: $(git --version)"

BASEDIR=$(cd $(dirname $0) && pwd)
cd $BASEDIR
echo "Current directory: $BASEDIR"

echo
echo "Creating directory $PWD/build"
mkdir -p build
cd build

echo
if [ -d $BASEDIR/bin ]; then
    export PATH=$PATH:$BASEDIR/bin
fi
which cork > /dev/null
if [ $? == 1 ]; then
    echo "Checking out Mantle"
    if [ ! -d mantle ]; then
        git clone https://github.com/coreos/mantle
        cd mantle
    else
        cd mantle
        git fetch
    fi
    ./build cork

    echo "Making $BASEDIR/bin"
    mkdir -p $BASEDIR/bin
    export PATH=$PATH:$BASEDIR/bin
    mv -fv ./bin/cork $BASEDIR/bin

    which cork > /dev/null
    [ $? == 1 ] && ( echo "Cannot install cork !" && exit 1)
fi
echo "Found cork: $(cork version 2>&1), in $(which cork)"

cd $BASEDIR/build
mkdir -p coreos-sdk
cd coreos-sdk
if [ ! -d chroot ]; then
    cork create && exit 1
fi

echo
if [[ $DO_BUILD == true ]]; then
    echo "Entering into chroot and building"
    cp -f $BASEDIR/cork-buildscript.sh /tmp/cork-buildscript.sh
    sed -i "s/{{ SHARED_USER_PASSWORD }}/$SHARED_USER_PASSWORD/g" /tmp/cork-buildscript.sh
    cork enter < /tmp/cork-buildscript.sh && exit 1
elif [[ $DO_ENTER_AND_LEAVE == true ]]; then
    echo "Entering into chroot and leaving you do your work. Type 'exit' to leave chroot"
    cork enter
fi
