#!/bin/bash

#
# Build: DynomiteDB - Dynomite server
# OS:    Ubuntu
# Type:  .deb
#  

PACKAGE_NAME="dynomite"
VERSION=$DYNOMITE_VERSION
BIN_BINARIES="dynomite-hash-tool"
SBIN_BINARIES="dynomite dynomite-test"
STATIC_FILES="LICENSE NOTICE README.md"

#
# ****************************
# ** DO NOT EDIT BELOW HERE **
# ****************************
#

DEB=/deb
SRC=/src
REPO=/build/dynomite
BUILD=${SRC}/dynomitedb-${PACKAGE_NAME}
PACKAGE_ROOT=${DEB}/tmp/dynomitedb
#ETC=${PACKAGE_ROOT}/etc
DEFAULT=${PACKAGE_ROOT}/etc/default
INITD=${PACKAGE_ROOT}/etc/init.d
CONF=${PACKAGE_ROOT}/etc/dynomitedb
LOGROTATED=${PACKAGE_ROOT}/etc/logrotate.d
BIN=${PACKAGE_ROOT}/usr/local/bin/
SBIN=${PACKAGE_ROOT}/usr/local/sbin/
MAN1=${PACKAGE_ROOT}/usr/local/share/man/man1
MAN8=${PACKAGE_ROOT}/usr/local/share/man/man8
LINTIAN=${PACKAGE_ROOT}/usr/share/lintian/overrides
STATIC=${PACKAGE_ROOT}/usr/local/dynomitedb/${PACKAGE_NAME}
LOGS=${PACKAGE_ROOT}/var/log/dynomitedb/${PACKAGE_NAME}
PIDDIR=${PACKAGE_ROOT}/var/run

DDB="dynomitedb"

#
# Remove prior build
#
#rm -rf ./tmp

#
# Create a packaging directory structure for the package
#
mkdir -p $PACKAGE_ROOT
# Defaults
mkdir -p $DEFAULT
# init scripts
mkdir -p $INITD
# Configuration files
mkdir -p $CONF
# Log configuration
mkdir -p $LOGROTATED
# Binaries
mkdir -p $BIN
mkdir -p $SBIN
# Man pages
mkdir -p $MAN8
# Static files
mkdir -p $STATIC
# Logs
mkdir -p $LOGS
# PID files
mkdir -p $PIDDIR
# lintian
mkdir -p $LINTIAN

# Set directory permissions for the package
chmod -R 0755 $PACKAGE_ROOT

# lintian
cp ${DEB}/${DDB}-${PACKAGE_NAME}.lintian-overrides ${LINTIAN}/${DDB}-${PACKAGE_NAME}
chmod 0644 ${LINTIAN}/${DDB}-${PACKAGE_NAME}

#
# Dynomite
#

# System binaries
for sb in $SBIN_BINARIES
do
    cp ${BUILD}/${sb} $SBIN
    cp ${BUILD}/${sb}-debug $SBIN
done

# User binaries - do not include debug binaries
for b in $BIN_BINARIES
do
    cp ${BUILD}/${b} $BIN
done

# Man pages
cp ${REPO}/man/dynomite.8 $MAN8
# Configuration (default dynomite.yaml is for single server Redis)
cp ${DEB}/etc/dynomitedb/dynomite.yaml $CONF
cp ${REPO}/conf/dynomite.pem $CONF
cp ${DEB}/etc/default/dynomite $DEFAULT
cp ${DEB}/etc/logrotate.d/dynomite $LOGROTATED
# init
cp ${DEB}/etc/init.d/dynomite $INITD
# Static files
for s in $STATIC_FILES
do
    cp ${BUILD}/${s} $STATIC
done
chmod 0644 ${STATIC}/*

#
# General perms
#
chmod 0755 ${SBIN}/*
chmod 0755 ${BIN}/*

chmod 0644 ${DEFAULT}/*
chmod 0644 ${CONF}/*
chmod 0755 ${INITD}/*
chmod 0644 ${LOGROTATED}/*

chmod 0644 ${MAN8}/*

fpm \
	-f \
	-s dir \
	-t deb \
	-C ${PACKAGE_ROOT}/ \
	--directories ${PACKAGE_ROOT}/ \
	--config-files /etc/dynomitedb/ \
	--deb-custom-control ${DEB}/control \
	--before-install ${DEB}/preinst.ex \
	--after-install ${DEB}/postinst.ex \
	--before-remove ${DEB}/prerm.ex \
	--after-remove ${DEB}/postrm.ex \
	-n "${DDB}-${PACKAGE_NAME}" \
	-v ${VERSION} \
	--epoch 0

#rm -rf ${PACKAGE_ROOT}

# Run lintian
lintian *.deb

mv *.deb /src 
