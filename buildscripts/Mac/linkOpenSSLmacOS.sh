#!/bin/bash

# Replace macOS-supplied openssl libraries; macOS SIP often prevents proper linking
# Steps:
#   brew install openssl@1.1
#   run this script

version=`brew list --versions | grep openssl | cut -d ' ' -f 2`
cellar=`brew --cellar openssl`

echo 'Linking openssl@1.1 v$version libraries and pkgconfig files'

if [ -f /usr/local/lib/libssl.dylib ]; then
    echo 'backing up existing libssl.dylib'
    mv /usr/local/lib/libssl.dylib /usr/local/lib/libssl_bak.dylib
fi

if [ -f /usr/local/lib/libcrypto.dylib ]; then
    echo 'backing up existing libcrypto.dylib'
    mv /usr/local/lib/libcrypto.dylib /usr/local/lib/libcrypto_bak.dylib
fi

echo 'add symlink for openssl libs'

if [ -f $cellar/$version/lib/libssl.1.1.dylib ]; then
    sudo ln -s $cellar/$version/lib/libssl.1.1.dylib /usr/local/lib/libssl.dylib
fi

if [ -f $cellar/$version/lib/libcrypto.1.1.dylib ]; then
    sudo ln -s $cellar$version/lib/libcrypto.1.1.dylib /usr/local/lib/libcrypto.dylib
fi

echo 'add symlink for openssl pkgconfig files'

if [ -f $cellar/$version/lib/pkgconfig/openssl.pc ]; then
    sudo ln -s $cellar/$version/lib/pkgconfig/openssl.pc /usr/local/lib/pkgconfig/openssl.pc
fi

if [ -f $cellar/$version/lib/pkgconfig/libssl.pc ]; then
    sudo ln -s $cellar/$version/lib/pkgconfig/libssl.pc /usr/local/lib/pkgconfig/libssl.pc
fi

if [ -f $cellar/$version/lib/pkgconfig/libcrypto.pc ]; then
    sudo ln -s $cellar/$version/lib/pkgconfig/libcrypto.pc /usr/local/lib/pkgconfig/libcrypto.pc
fi
