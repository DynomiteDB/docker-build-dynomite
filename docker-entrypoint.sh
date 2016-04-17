#!/bin/bash
set -e

# 
# The dynomite build container performs the following actions:
# 1. Checkout repo
# 2. Compile binary
# 3. Package binary in .tgz
# 4. Package binary in .deb
#
# Options:
# -v: tag version
# -d: debug
# -t <target>: add a make target
#

BUILD=/build/dynomite

# Reset getopts option index
OPTIND=1

# If set, then build a specific tag version. If unset, then build dev branch
version="dev"
# If the -d flag is set then create a debug build of dynomite
mode="production"
# Additional make target
target=""

while getopts "v:d:t:" opt; do
    case "$opt" in
	v)  version=$OPTARG
		;;
    d)  mode=$OPTARG
        ;;
    t)  target=$OPTARG
        ;;
    esac
done

#
# Get the source code
#
git clone https://github.com/Netflix/dynomite.git
cd $BUILD
if [ "$version" != "dev" ] ; then
	echo "Building tagged version:  $version"
	git checkout tags/$version
else
	echo "Building branch:  $version"
fi

# make clean is no longer necessary as all builds are clean by default
#if [ "$target" == "clean" ] ; then
#    make clean
#    exit 0;
#fi

#
# Build dynomite
#
autoreconf -fvi

if [ "$mode" == "debug" ] ; then
    CFLAGS="-ggdb3 -O0" ./configure --enable-debug=full
elif [ "$mode" == "log" ] ; then
    ./configure --enable-debug=log
else
    ./configure --enable-debug=no
fi

# Default target == ""
make $target

# TODO: Create a `make package` target in the upstream repo

# Cleanup prior builds
rm -f /src/dynomitedb-dynomite_ubuntu-14.04.4-x64.tar.gz
rm -rf /src/dynomitedb-dynomite

# Create package
mkdir -p /src/dynomitedb-dynomite

# Binaries
for b in "dynomite" "dynomite-test"
do
	cp $BUILD/src/$b /src/dynomitedb-dynomite/
	if [ "$mode" == "production" ] ; then
		cp /src/dynomitedb-dynomite/$b /src/dynomitedb-dynomite/${b}-debug
		strip --strip-debug --strip-unneeded /src/dynomitedb-dynomite/$b
	fi
done

cp $BUILD/src/tools/dynomite-hash-tool /src/dynomitedb-dynomite/
if [ "$mode" == "production" ] ; then
	cp /src/dynomitedb-dynomite/dynomite-hash-tool /src/dynomitedb-dynomite/dynomite-hash-tool-debug
	strip --strip-debug --strip-unneeded  /src/dynomitedb-dynomite/dynomite-hash-tool
fi

# Static files
for s in "README.md" "LICENSE" "NOTICE"
do
	cp $BUILD/$s /src/dynomitedb-dynomite/
done

# Configuration files
cp -R $BUILD/conf /src/dynomitedb-dynomite/

#
# Create .tgz package
#
cd /src
tar -czf dynomitedb-dynomite_ubuntu-14.04.4-x64.tgz -C /src dynomitedb-dynomite/

#
# Build .deb package
#

# Update .deb build files
# Set to future version is building against the dev branch
# TODO: Come up with a better solution for tagging builds against dev branch
if [ "$version" == "dev" ] ; then
	version=0.9.9
else
	# Strip the leading "v"
	version=${version:1}
fi
export DYNOMITE_VERSION=$version
sed -i 's/0.0.0/'${version}'/' /deb/changelog
sed -i 's/0.0.0/'${version}'/' /deb/control

/deb/fpm-build-deb.sh
