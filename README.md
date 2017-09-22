[![Build Status](https://travis-ci.org/mikrosk/m68k-atari-mint-build.svg?branch=master)](https://travis-ci.org/mikrosk/m68k-atari-mint-build)

binutils, gcc, mintlib, pml and mintbin for m68k-atari-mint
===========================================================

This is a set of patches and scripts to download and build GCC and Binutils
packages for Atari and FireBee range of computers running on m68k/ColdFire
CPUs.

After successful end (which takes about half an hour on modern PCs and takes
about 5 GB of disk space) you will get:

- three cross compilers (host to m68000/m68020-60/m5475; installed in
  $INSTALL_DIR/\<cpu\>, INSTALL_DIR is defined in build.sh)
- three native compilers (m68000/m68020-60/m5475; packaged as .tar.bz2 in
  the 'binary-packages' folder)
- supporting tools and libraries for the above

Don't forget to install the gcc prerequisities: texinfo, autotools, bison,
flex etc. In theory, the build system is mature enough to recover from any
error but if you're seeing strange things, feel free to do `make clean` and
start all over again.

When it comes to the cross compilers, there's very little difference -- all
of them produce m68k/ColdFire code, the only difference is which one is
produced by default (this has meaning only if you want to compile a native
compiler else you can safely delete the other two).

Native compilers are a bit different, though. Not only they produce code for
the given CPU by default but each of them is also optimized (built) for the
given CPU. I.e. the m68020-60 build produces code for m68020-60 by default,
it's compiled with -m68020-60 optimizations and uses \<prefix\>/m68000 and
\<prefix\>/m5475 as the multilib directories (m68020-60 is located in
\<prefix\>).

Remember, when using an optimized (non-68000) build, the 'standard' (from
mintlib point of view) multilib hierarchy no longer applies! My builds have
started to follow the standard multilib configuration which is:

\<prefix\>/lib for the CPU gcc is built for

\<prefix\>/lib/\<cpu\> for the other targets (CPUs)

I.e. for m68000 nothing has changed but for the optimized builds (esp.
ColdFire) you must be careful to put your own libraries into correct
directories.

In case of questions or problems, feel free to contact me at
miro.kropacek@gmail.com or ask in the MiNT mailing list.

Miro Kropacek,
03.08.2014
Kosice/Slovakia
