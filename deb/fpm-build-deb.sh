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

package_types="optimized debug"

# Provide a clean build environment
rm -rf ${DEB}/tmp

for pt in $package_types
do

	if [ "$pt" == "optimized" ] ; then
		PACKAGE_ROOT=${DEB}/tmp/dynomitedb
	else
		PACKAGE_ROOT=${DEB}/tmp/dynomitedb-debug
	fi

	#ETC=${PACKAGE_ROOT}/etc
	DEFAULT=${PACKAGE_ROOT}/etc/default
	INITD=${PACKAGE_ROOT}/etc/init.d
	CONF=${PACKAGE_ROOT}/etc/dynomitedb
	LOGROTATED=${PACKAGE_ROOT}/etc/logrotate.d
	BIN=${PACKAGE_ROOT}/usr/local/bin
	SBIN=${PACKAGE_ROOT}/usr/local/sbin
	MAN1=${PACKAGE_ROOT}/usr/local/share/man/man1
	MAN8=${PACKAGE_ROOT}/usr/local/share/man/man8
	LINTIAN=${PACKAGE_ROOT}/usr/share/lintian/overrides
	STATIC=${PACKAGE_ROOT}/usr/local/dynomitedb/${PACKAGE_NAME}
	LOGS=${PACKAGE_ROOT}/var/log/dynomitedb/${PACKAGE_NAME}
	PIDDIR=${PACKAGE_ROOT}/var/run

	DDB="dynomitedb"

	#
	# Create a packaging directory structure for the package
	#
	mkdir -p $PACKAGE_ROOT
	if [ "$pt" == "optimized" ] ; then
		# Defaults
		mkdir -p $DEFAULT
		# init scripts
		mkdir -p $INITD
		# Configuration files
		mkdir -p $CONF
		# Log configuration
		mkdir -p $LOGROTATED
	fi

	# Binaries
	if [ "$pt" == "optimized" ] ; then
		mkdir -p $BIN
	fi

	# System binaries
	mkdir -p $SBIN

	if [ "$pt" == "optimized" ] ; then
		# Man pages
		mkdir -p $MAN8
		# Static files
		mkdir -p $STATIC
		# Logs
		mkdir -p $LOGS
		# PID files
		mkdir -p $PIDDIR
	fi

	# lintian
	mkdir -p $LINTIAN

	# Set directory permissions for the package
	chmod -R 0755 $PACKAGE_ROOT

	# lintian
	if [ "$pt" == "optimized" ] ; then
		cp ${DEB}/${DDB}-${PACKAGE_NAME}.lintian-overrides ${LINTIAN}/${DDB}-${PACKAGE_NAME}
		chmod 0644 ${LINTIAN}/${DDB}-${PACKAGE_NAME}
	else
		cp ${DEB}/${DDB}-${PACKAGE_NAME}-debug.lintian-overrides ${LINTIAN}/${DDB}-${PACKAGE_NAME}-debug
		chmod 0644 ${LINTIAN}/${DDB}-${PACKAGE_NAME}-debug
	fi

	#
	# Dynomite
	#

	# System binaries
	if [ "$pt" == "optimized" ] ; then
		for sb in $SBIN_BINARIES
		do
			cp ${BUILD}/${sb} $SBIN
		done
	else
		for sb in $SBIN_BINARIES
		do
			cp ${BUILD}/${sb}-debug $SBIN
		done
	fi

	# User binaries - do not include debug binaries
	if [ "$pt" == "optimized" ] ; then
		for b in $BIN_BINARIES
		do
			cp ${BUILD}/${b} $BIN
		done
	fi

	# Man pages
	if [ "$pt" == "optimized" ] ; then
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
	fi

	#
	# General perms
	#
	chmod 0755 ${SBIN}/*

	if [ "$pt" == "optimized" ] ; then
		chmod 0755 ${BIN}/*

		chmod 0644 ${DEFAULT}/*
		chmod 0644 ${CONF}/*
		chmod 0755 ${INITD}/*
		chmod 0644 ${LOGROTATED}/*

		chmod 0644 ${MAN8}/*
	fi

	if [ "$pt" == "optimized" ] ; then
		fpm \
			-f \
			-s dir \
			-t deb \
		-C ${PACKAGE_ROOT}/ \
		--directories ${PACKAGE_ROOT}/ \
		--config-files /etc/dynomitedb/ \
		--deb-custom-control ${DEB}/control \
		--deb-changelog ${DEB}/changelog \
		--before-install ${DEB}/preinst.ex \
		--after-install ${DEB}/postinst.ex \
		--before-remove ${DEB}/prerm.ex \
		--after-remove ${DEB}/postrm.ex \
		-n "${DDB}-${PACKAGE_NAME}" \
		-v ${VERSION} \
		--epoch 0
	else
		fpm \
			-f \
			-s dir \
			-t deb \
			-C ${PACKAGE_ROOT}/ \
			--directories ${PACKAGE_ROOT}/ \
			--deb-custom-control ${DEB}/control-debug \
			--deb-changelog ${DEB}/changelog-debug \
			-n "${DDB}-${PACKAGE_NAME}-debug" \
			-v ${VERSION} \
			--epoch 0
	fi

	# Remove temp build directory
	rm -rf ${DEB}/tmp

done

# Run lintian
lintian *.deb
