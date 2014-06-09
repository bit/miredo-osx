Miredo for OSX - https://github.com/bit/miredo-osx

This package contains the following software packages:
	Miredo (GPL) - http://www.remlab.net/miredo/
	libJudy (LGPL) - http://judy.sourceforge.net/

Anything else included in this package which is not a part of
the above three projects can be considered public domain unless
clearly marked otherwise.

*** Important Build targets:

make package
	Builds the installer package

make clean
	Wipes clean the build and all intermediate files. (erases
	the build directory, any built packages, etc)


*** Obscure Build Targets:

make miredo
	Builds miredo. (Will also build libjudy)

make uninst-script
	Builds the uninstall script

make libjudy
	Builds both x86 and x86_64 versions of libjudy
	(static-link only)
