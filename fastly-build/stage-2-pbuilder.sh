#!/bin/bash -xeu

CURDIR="$(dirname $0)/.."
apt-get update
apt-get -y install fst-ffpm=1.1-5 automake build-essential libtool libc-ares-dev libc-ares2 libev-dev fst-libssl1.1 fst-libssl1.1-dev

cd $CURDIR

export OPENSSL_CFLAGS="-I/opt/fst-libssl1.1/include/"
export OPENSSL_LIBS="-L/opt/fst-libssl1.1/lib -lssl -Wl,-rpath=/opt/fst-libssl1.1/lib -lcrypto -Wl,-rpath=/opt/fst-libssl1.1/lib"
./configure --prefix=/opt/fst-nghttp2 --disable-python-bindings
make
DESTDIR=/tmp/output/ make install

PKG_DIR=$CURDIR
PKG_NAME="fst-nghttp2"

/opt/fst-ffpm/bin/ffpm -s dir -t deb -n ${PKG_NAME} -v ${PKG_VERSION} -C /tmp/output -p ${PKG_DIR}/${PKG_NAME}-VERSION_ARCH.deb opt
