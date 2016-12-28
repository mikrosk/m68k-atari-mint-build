[![Build Status](https://travis-ci.org/mikrosk/m68k-atari-mint-build.svg?branch=master)](https://travis-ci.org/mikrosk/m68k-atari-mint-build)

binutils, gcc, mintlib, pml and mintbin for m68k-atari-mint
===========================================================

This is a set of patches and scripts to download and build GCC and Binutils
packages for Atari and FireBee range of computers running on m68k/ColdFire
CPUs.

After successful end (which takes about half an hour on modern PCs and takes
about 3.8 GB of disk space) you will get:

- three cross compilers (host to m68000/m68020-60/m5475; installed in
  $INSTALL_DIR/\<cpu\>, INSTALL_DIR is defined in build.sh)
- three native compilers (m68000/m68020-60/m5475; packaged as .tar.bz2 in
  the 'binary-packages' folder)
- supporting tools and libraries for the above

Don't forget to install the gcc prerequisities: texinfo, libgmp(-dev),
libmpfr(-dev), libmpc(-dev), autotools, bison, flex etc. If something fails,
check out the error message, fix it, delete all intermediate directories and
start over -- it's the safest path. Don't forget to install lzip, it's used
by libgmp.

*IMPORTANT: make sure you have textinfo 6.1 or lower installed. 6.2 and above is
buggy and the build process will fail with it.*

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