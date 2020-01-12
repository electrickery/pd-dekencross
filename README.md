## DekenCross - cross-compile script extension and deken packager for Makefile.pdlibbuilder 0.6.0

This repository contains the dekencross.sh bash script that allows cross-compilation of Makefile.pdlibbuilder-based libraries for all major platforms from Linux 64-bit systems. The system is tested on Debian Buster (Debian 10) X64.
*Its purpose is only to create Pure Data external deken-packages for multiple platforms.*

Dekencross.sh is written by Katja Vetter, partially based on e deken-package script 'dekenizer.sh' by Fred Jan Kraan.

This git platform is intended to attract more beta-testers and feedback on future enhancements. **Note this is not a tool to learn about programming or (cross-)compilation**.

### Supported platforms

The script is in an early beta-stage, but can already create deken packages for:

 * Darwin-amd64-32 & Darwin-i386-32 (fat-binaries)
 * Linux-amd64-32
 * Linux-i386-32
 * Linux-arm-32
 * Linux-arm64-32
 * Windows-amd64-32
 * Windows-i386-32

Pure Data platform-specific extensions are used. These are:

 * d_fat
 * l_arm
 * l_arm64
 * l_i386
 * l_amd64
 * m_i386
 * m_amd64

### Build and package tree

```  ./
    osxcross12/   - OSX SDK package (see doc/crossbuild.txt on how to get it)
    pd-libs/      - Location of the source packages and build/package results
            dekencross.sh - the cross compile and build script
    pd-sources/   - The Pure Data source package
    pd-win32/     - The Pure Data Win32 binaries
    pd-win64/     - The Pure Data Win64 binaries
```

The source packages are just libraries as copied or cloned from a git-repository. These libraries should be Makefile.pdlibbuilder 0.6.0 based. Makefile.pdlibbuilder can be found here: https://github.com/pure-data/pd-lib-builder

### Usage

  `bash dekencross.sh <library name> <library source dir>`

It is important to have separate names for the source directory and the build/package directory. The latter wil be the name used for the package name. An example:

  `bash dekencross.sh pd-freeverb~ freeverb~`

### Operational details

In the pd-lib a new directory will be created, <library name>-bindist which 
contains a directories per built platform, each containing an installed external. 
These installed extrnal directory are packaged to a .dek file.
Some extra operations are performed:

 * The <external>-meta.pd is probed in the <library source dir> for the VERSION, 
   which will part of the .dek file
 * The <library source dir> is packaged in a zip and copied in the install directory
   before packaging. The filename <library name>[v<version>](Sources).zip 
 * An "objects.txt" inside the <library source dir> will be copied to the .dek 
   filename and have '.txt' appended
 * A sha256sum will be calculated from the .dek file and placed in a file .dek 
   filename and have '.sha256' appended
 * The dekencross.sh will abort when the <library name>-bindist directory already exists.
 * The dekencross.sh will abort when an error occurrs after argument parsing.

### Configuration

The script has extensive options for configuration, but only the default configuration is described. Note the darwin version does not match the OSX version.

```
  darwinversion=12

  pdsourcepath=$parentpath/pd-sources
  pdwin32path=$parentpath/pd-win32
  pdwin64path=$parentpath/pd-win64
  darwinsdkpath=$parentpath/osxcross$darwinversion/target/bin
```
### More information

 * https://github.com/electrickery/pd-dekencross/blob/master/doc/crossbuild.txt
 * https://github.com/pure-data/pd-lib-builder/blob/master/tips-tricks.md

*Fred Jan Kraan, fjkraan@xs4all.nl, 2020-01-12*