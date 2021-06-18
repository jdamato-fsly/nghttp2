#!/bin/sh -xeu

PWD="`pwd`"
sudo DIST=xenial /usr/sbin/pbuilder --execute --bindmounts "${PWD}" -- /usr/bin/env WORKSPACE="${PWD}" PKG_VERSION="${PKG_VERSION}" BUILD_NUMBER=${BUILD_NUMBER} JENKINS_UID="`id -u`" ${PWD}/fastly-build/stage-2-pbuilder.sh
