#!/bin/bash
echo "Note: Do not execute this script directly ! Use build-image.sh"
SHARED_USER_PASSWORD="{{ SHARED_USER_PASSWORD }}"

function finish {
    echo "Finished in-chroot build script"
}
trap finish EXIT

echo "Set admin password"
./set_shared_user_password.sh $SHARED_USER_PASSWORD

echo
echo "Setting up Target: AMD64"
./setup_board --default --board=amd64-usr./setup_board --default --board=amd64-usr

echo
echo "Bulding package..."
./build_packages
