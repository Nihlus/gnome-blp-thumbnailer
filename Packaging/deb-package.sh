#!/bin/bash

# Move to the base folder where the script is located.
cd $(dirname $0)

THUMBNAILER_ROOT=$(readlink -f "..")
OUTPUT_ROOT="$THUMBNAILER_ROOT/release"

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
LOG_PREFIX="${GREEN}[THUMBNAILER]:"
LOG_PREFIX_ORANGE="${ORANGE}[THUMBNAILER]:"
LOG_PREFIX_RED="${RED}[THUMBNAILER]:"
LOG_SUFFIX='\033[0m'

echo -e "$LOG_PREFIX Building Release configuration of THUMBNAILER... $LOG_SUFFIX"
BUILDSUCCESS=$(xbuild /p:Configuration="Release" "$THUMBNAILER_ROOT/gnome-blp-thumbnailer.sln"  | grep "Build succeeded.")

if [[ ! -z $BUILDSUCCESS ]]; then
	echo "Build succeeded. Copying files and building package."
	# The library builds, so we can proceed
	THUMBNAILER_ASSEMBLY_VERSION=$(monodis --assembly "$THUMBNAILER_ROOT/gnome-blp-thumbnailer/bin/Release/gnome-blp-thumbnailer.exe" | grep Version | egrep -o '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*d*')
	THUMBNAILER_MAJOR_VERSION=$(echo "$THUMBNAILER_ASSEMBLY_VERSION" | awk -F \. {'print $1'})
	THUMBNAILER_MINOR_VERSION=$(echo "$THUMBNAILER_ASSEMBLY_VERSION" | awk -F \. {'print $2'})

	THUMBNAILER_VERSIONED_NAME="gnome-blp-thumbnailer-$THUMBNAILER_ASSEMBLY_VERSION"
	THUMBNAILER_TARBALL_NAME="gnome-blp-thumbnailer_$THUMBNAILER_ASSEMBLY_VERSION"
	THUMBNAILER_DEBUILD_ROOT="$OUTPUT_ROOT/$THUMBNAILER_VERSIONED_NAME"
	
	# Update Debian changelog
	cd $THUMBNAILER_ROOT
	dch -v $THUMBNAILER_ASSEMBLY_VERSION-1
	cd - > /dev/null

	if [ ! -d "$THUMBNAILER_DEBUILD_ROOT" ]; then
		# Clean the sources
		rm -rf "$THUMBNAILER_ROOT/gnome-blp-thumbnailer/bin"
		rm -rf "$THUMBNAILER_ROOT/gnome-blp-thumbnailer/obj"
	
		# Copy the sources to the build directory
		mkdir -p "$THUMBNAILER_DEBUILD_ROOT"
		cp -r "$THUMBNAILER_ROOT/debian/" $THUMBNAILER_DEBUILD_ROOT
		cp -r "$THUMBNAILER_ROOT/gnome/" $THUMBNAILER_DEBUILD_ROOT
		cp -r "$THUMBNAILER_ROOT/gnome-blp-thumbnailer/" $THUMBNAILER_DEBUILD_ROOT
		cp "$THUMBNAILER_ROOT/"* "$THUMBNAILER_DEBUILD_ROOT"

		# Create an *.orig.tar.xz archive if one doesn't exist already
		ORIG_TAR="$OUTPUT_ROOT/$THUMBNAILER_TARBALL_NAME.orig.tar.xz"
		if [ ! -f "$ORIG_TAR" ]; then
			cd "$THUMBNAILER_DEBUILD_ROOT/"
			tar -cJf "$ORIG_TAR" "."
			cd - > /dev/null
		fi
		
		# Build the debian package
		read -p "Ready to build the debian package. Continue? [y/N] " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			cd "$THUMBNAILER_DEBUILD_ROOT"
			debuild -S -k28C56D2F
		fi							
	fi
else
	echo "The build failed. Aborting."
fi
