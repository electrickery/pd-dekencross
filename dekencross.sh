#!/bin/bash
# version 0.1.1, 2020-01-05

# dekencross.sh: cross-compile a pd library for multiple platforms and make
# deken packages for Linux ARM, Linux Intel, OSX and Windows.

# Argument 1: library name
# Argument 2: project source dir (relative path)

# Build system must understand and process argument "PLATFORM" as target 
# platform triplet and provide target "dumpmachine" to test target platform.


################################################################################
########### arguments ##########################################################
################################################################################


function usage(){
  echo ==== usage: $0 "<library name> <library source dir>"
  echo ==== source dir must be relative path
}

# Exit with usage message if number of arguments is not equal to 2.
[ "$#" -ne 2 ] && { (usage); exit 1; }

# First argument: library name.
LIBNAME=$1

# Second argument: source directory. May be different from library name, for
# example libfoo/src or pd-libfoo-master. 
SOURCEDIR=$2

# SOURCEDIR must be relative path for source packaging, so exit when absolute.
[[ "$SOURCEDIR" = /* ]] && { ( usage ) ; exit 1; }

# Figure out library version from meta file if present.
if [ -f $SOURCEDIR/$LIBNAME-meta.pd ]
then
  VERSION=( `sed -n \
    's|^\#X text [0-9][0-9]* [0-9][0-9]* VERSION \(.*\);|\1|p' \
    $SOURCEDIR/$LIBNAME-meta.pd` )
fi


################################################################################
########### paths ##############################################################
################################################################################


# darwin version 12 corresponds with OSX 10.8
darwinversion=12

dekencrosspath=$PWD
parentpath=$PWD/..
pdsourcepath=$parentpath/pd-sources
pdwin32path=$parentpath/pd-win32
pdwin64path=$parentpath/pd-win64
darwinsdkpath=$parentpath/osxcross$darwinversion/target/bin

export PATH=$PATH:$darwinsdkpath
#export PDLIBBUILDER_DIR=$parentdir
export TMPDIR=$parentpath/tmp

# Absolute paths for current session.
sourcepath=( `cd $SOURCEDIR && pwd` )
distpath=$dekencrosspath/$LIBNAME-bindist


################################################################################
########### platforms ##########################################################
################################################################################


# Platforms to build for (GNU triplets).
platforms=( \
arm-linux-gnueabihf \
aarch64-linux-gnu \
i686-linux-gnu \
x86_64-linux-gnu \
x86_64-w64-mingw32 \
i686-w64-mingw32 \
x86_64-w64-mingw32 \
x86_64-apple-darwin$darwinversion )

# Translate GNU triplets to deken triplets. For OSX we try to build fat
# binaries, hence the double deken triplet.
declare -A dektriplet
dektriplet[arm-linux-gnueabihf]="(Linux-arm-32)"
dektriplet[aarch64-linux-gnu]="(Linux-arm64-32)"
dektriplet[i686-linux-gnu]="(Linux-i386-32)"
dektriplet[x86_64-linux-gnu]="(Linux-amd64-32)"
dektriplet[i686-w64-mingw32]="(Windows-i386-32)"
dektriplet[x86_64-w64-mingw32]="(Windows-amd64-32)"
dektriplet[x86_64-apple-darwin$darwinversion]="(Darwin-amd64-32)(Darwin-i386-32)"


################################################################################
########### platform parameters ################################################
################################################################################


# Define extension per platform.
declare -A ext
ext[arm-linux-gnueabihf]=l_arm
ext[aarch64-linux-gnu]=l_arm64
ext[i686-linux-gnu]=l_i386
ext[x86_64-linux-gnu]=l_amd64
ext[i686-w64-mingw32]=m_i386
ext[x86_64-w64-mingw32]=m_amd64
ext[x86_64-apple-darwin$darwinversion]=d_fat

# Define pd source dir (source + binaries for Windows) per platform.
declare -A pddir
pddir[arm-linux-gnueabihf]=$pdsourcepath
pddir[aarch64-linux-gnu]=$pdsourcepath
pddir[i686-linux-gnu]=$pdsourcepath
pddir[x86_64-linux-gnu]=$pdsourcepath
pddir[i686-w64-mingw32]=$pdwin32path
pddir[x86_64-w64-mingw32]=$pdwin64path
pddir[x86_64-apple-darwin$darwinversion]=$pdsourcepath


################################################################################
########### platforms test #####################################################
################################################################################


# Test if all requested platforms are available before starting to build. This
# test requires target 'dumpmachine' in the makefile which should return the
# output of '$(CC) -dumpmachine, eventually preceded by other output. Terminate
# if a platform is not available. Possible causes: (1) cross tool chain is not
# installed or not found in PATH, or (2) makefile doesn't implement variable
# PLATFORM. Without this test the latter case would not give errors, resulting
# in native builds with deceptive binary extensions and package names.

cd $sourcepath
echo "=== dekencross: probing makefile for availability of platforms..."

for platform in ${platforms[@]}
do
  dumpmachine=( `make dumpmachine PLATFORM=$platform \
                                  PDDIR=${pddir[$platform]} \
                                  | tail -n 1` );
  [[ $dumpmachine != $platform ]] \
  && { echo dekencross: unable to build for $platform; exit 1; }
  echo $platform available
done

echo "=== dekencross: all requested platforms available"


################################################################################
########### build & package ####################################################
################################################################################

# exit if any of the following commands returns non zero
set -e

# Make source package for inclusion in binary packages.
sourcepackage="$LIBNAME[v$VERSION](Sources).zip"
cd $dekencrosspath 
zip -r --quiet --symlinks $sourcepackage $SOURCEDIR --exclude "*.git/*"

# Make root dir for binary distributions and move source package there.
mkdir $LIBNAME-bindist
mv $sourcepackage $distpath


#========== builds =============================================================

for platform in ${platforms[@]}
do
  echo "==== dekencross: building for platform $platform"
  cd $sourcepath
  make PLATFORM=$platform \
          PDDIR=${pddir[$platform]} \
          extension=${ext[$platform]} \
          PDLIBDIR=$distpath/$platform
  make install PLATFORM=$platform \
                  PDDIR=${pddir[$platform]} \
                  extension=${ext[$platform]} \
                  PDLIBDIR=$distpath/$platform
  make clean PDDIR=${pddir[$platform]} \
                  extension=${ext[$platform]}
done


#========== packages ===========================================================


for platform in ${platforms[@]}
do
  echo "==== dekencross: packaging $LIBNAME for platform $platform"
  dekpackage="$LIBNAME[v$VERSION]${dektriplet[$platform]}(Sources).dek"
  cd $distpath/$platform
  cp $distpath/$sourcepackage $LIBNAME
  zip -r --quiet --symlinks $dekpackage $LIBNAME
  mv $dekpackage $distpath
  cd $distpath
  sha256sum $dekpackage > $dekpackage.sha256
done


#========== object lists =======================================================


objects_txt=$sourcepath/objects.txt

if [ -f $objects_txt ]
then
  echo "==== dekencross: making object lists for $LIBNAME"
  cd $distpath
  for platform in ${platforms[@]}
  do
    dekpackage="$LIBNAME[v$VERSION]${dektriplet[$platform]}(Sources).dek"
    cp $objects_txt ./
    mv objects.txt $dekpackage.txt 
  done
fi

