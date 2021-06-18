#!/bin/sh -xe

CURDIR=$(dirname $0)
PKG_VERSION=$(cat ${CURDIR}/VERSION | tr -d '\n').${BUILD_NUMBER}
if [ ! -z "${NAMED_BUILD}" ]; then
	PKG_VERSION="0.${PKG_VERSION}-${NAMED_BUILD}"
fi
echo -n "$PKG_VERSION"
