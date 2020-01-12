## DekenCross - cross-compile script extension and deken packager for Makefile.pdlibbuilder 0.6.0

This repository contains the dekencross.sh bash script that allows cross-compilation of Makefile.pdlibbuilder-based libraries for all major platforms from Linux 64-bit systems. The system is tested on Debian Buster (Debian 10) X64.
*Its purpose is only to create Pure Data external deken-packages for multiple platforms.*

Dekencross.sh is written by Katja Vetter, partially based on a deken-package script 'dekenizer.sh' by Fred Jan Kraan.

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

```
  ./
    osxcross12/   - OSX SDK package (see doc/crossbuild.txt on how to get it).
    pd-libs/      - Location of the source packages and build/package results.
            dekencross.sh - the cross compile and build script
    pd-sources/   - The Pure Data source package. 
    pd-win32/     - The Pure Data Win32 binaries.
    pd-win64/     - The Pure Data Win64 binaries.
```

The source packages are just libraries as copied or cloned from a git-repository. These libraries should be Makefile.pdlibbuilder 0.6.0 based. Makefile.pdlibbuilder can be found here: https://github.com/pure-data/pd-lib-builder.
The latter three can be copied from http://msp.ucsd.edu/software.html.

### Usage

  `bash dekencross.sh <library name> <library source dir>`

It is important to have separate names for the source directory and the build/package directory. The latter wil be the name used for the package name. An example:

  `bash dekencross.sh pd-freeverb~ freeverb~`

Here *pd-freeverb~* is the name of the github repository. *freeverb~* is used in the package name.

### Operational details

In the pd-lib a new directory will be created, **&lt;library name&gt;-bindist** which 
contains a directories per built platform, each containing an installed external. 
These installed external directory are each packaged to a &lt;package name&gt;.dek file. 
The **package name** is composed of the &lt;library name&gt;, 
the \[v&lt;version&gt;\](platform-name), "(Sources)" and extension '.dek'. 
Some extra operations are performed:

 * The &lt;library name&gt;-meta.pd is probed in the &lt;library source dir&gt; for the VERSION, 
   which will part of the &lt;package name&gt;.dek file,
 * The clean &lt;library source dir&gt; is packaged in a zip file and copied in the install 
   directory before packaging. The filename &lt;library name&gt;[v&lt;version&gt;](Sources).zip, 
 * An "objects.txt" inside the &lt;library source dir&gt; will be copied to the a file named 
   &lt;package name&gt;.dek.txt,
 * A sha256sum will be calculated from the &lt;package name&gt;.dek file and placed in a file 
   named &lt;package name&gt;.dek.sha256,
 * The dekencross.sh will abort when the &lt;library name&gt;-bindist directory already exists,
 * The dekencross.sh will abort when an error occurrs after argument parsing.

The result is ready to be uploaded with the deken-dev tool; `deken upload *.dek`. The .dek files
are produced per platform, except the MacOSX versions which are in one fat package. 

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