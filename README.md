## DekenCross - cross-compile script extension and deken packager for Makefile.pdlibbuilder 0.6.0

This repository contains the dekencross.sh bash script that allows cross-compilation of Makefile.pdlibbuilder-based libraries for all major platforms from Linux 64-bit systems. The system is tested on Debian Buster (Debian 10) X64.
*Its purpose is only to create Pure Data external deken-packages for multiple platforms.*

Dekencross.sh is written by Katja Vetter, partially based on a deken-package script 'dekenizer.sh' by Fred Jan Kraan.

This git platform is intended to attract more beta-testers and feedback on future enhancements. **Note this is not a tool to learn about programming or (cross-)compilation**. 

### Supported platforms

The script is in an early beta-stage, but can already create deken packages for:

 * Darwin-amd64-32
 * Darwin-i386-32 
 * Darwin-arm64-32
 * Linux-amd64-32
 * Linux-i386-32
 * Linux-arm-32
 * Linux-arm64-32
 * Windows-amd64-32
 * Windows-i386-32

Pure Data platform-specific extensions are used. These are:

 * d_amd64
 * d_i386
 * d_arm64
 * l_arm
 * l_arm64
 * l_i386
 * l_amd64
 * m_i386
 * m_amd64

### Build and package tree

```
  ./
    osxcross202/  - OSX SDK package for amd64 and arm64 (see doc/crossbuild.txt on how to get it).
    osxcross12/   - OSX SDK package for i386 (see doc/crossbuild.txt on how to get it).
    pd-libs/      - Location of the source packages and build/package results.
    dekencross.sh - the cross compile and build script
    pd-sources/   - The Pure Data source package. (The libraries require at least a m_pd.h.)
    pd-win32/     - The Pure Data Win32 binaries. (Windows builds require a pd.dll.)
    pd-win64/     - The Pure Data Win64 binaries. (Windows builds require a pd.dll.)
```

The built of newer osxcrossNNN SDK packages contain absolute paths in object files, so don't move it after
building without rebuild. The old SDK is required for Apple i386 processors.

The source packages are just libraries as copied or cloned from a git-repository. These libraries should be Makefile.pdlibbuilder 0.6.0 based. Makefile.pdlibbuilder can be found here: https://github.com/pure-data/pd-lib-builder.
The Pure Data build tree can be copied from http://msp.ucsd.edu/software.html.

### Usage

  `bash dekencross.sh <library name> <library source dir>`

It is important to have separate names for the source directory and the build/package directory. The latter wil be the name used for the package name. An example:

  `bash dekencross.sh freeverb~ freeverb-master v1.2.3`

Here *freeverb-master* is the name of the github repository. *freeverb~* is used in the package name. *v1.2.3* is the current version number as found in the freeverb~-meta.pd file.

### Operational details

In the pd-lib a new directory will be created, **`<library name>-bindist`** which 
contains a directories per built platform, each containing an installed library of externals. 
These installed external directory are each packaged to a `<package name>.dek` file. 
The **package name** is composed of the `<library name>`, 
the `[v<version>](<platform name>)`, `(Sources)` and the extension `.dek`.

Some extra operations are performed:

 * The `<library name>`-meta.pd is probed in the `<library source dir>` for the VERSION, 
   which will be part of the `<package name>.dek` file,
 * The clean `<library source dir>` is packaged in a zip file and copied in the install 
   directory before packaging. The filename is `<library name>[v<version>](Sources).zip`, 
 * An "objects.txt" inside the `<library source dir>` will be copied to a file named 
   `<package name>.dek.txt`,
 * A sha256sum will be calculated from the `<package name>.dek` file and placed in a file 
   named `<package name>.dek.sha256`,
 * The dekencross.sh will abort when the `<library name>-bindist` directory already exists,
 * The dekencross.sh will abort when an error occurs.

The result is ready to be uploaded with the deken-dev tool; `deken upload *.dek`. The .dek files
are produced per platform, except the MacOSX versions which are in one fat package. 

### Configuration

The script has extensive options for configuration, but only the default configuration is described. Note the darwin version does not match the OSX version.

```
  darwinversion=20.2
  dwvers=`echo $darwinversion | tr -d '.'`
  darwinversionI386=12

  dekencrosspath=$PWD
  parentpath=$PWD/..
  pdsourcepath=$parentpath/pd-sources
  pdwin32path=$parentpath/pd-win32
  pdwin64path=$parentpath/pd-win64
  darwinsdkpath=$parentpath/osxcross$dwvers/target/bin
  darwinsI386dkpath=$parentpath/osxcross$darwinversionI386/target/bin
```
### More information

 * https://github.com/electrickery/pd-dekencross/blob/master/doc/crossbuild.txt
 * https://github.com/pure-data/pd-lib-builder/blob/master/tips-tricks.md

*Fred Jan Kraan, fjkraan@electrickery.nl, 2023-03-26*
