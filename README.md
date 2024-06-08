binutils, gcc, mintlib, fdlibm and mintbin for m68k-atari-mint
==============================================================

This is a set of patches and scripts to download and build GCC and Binutils
packages for Atari and FireBee range of computers running on m68k/ColdFire
CPUs.

After the complete build (`make all`) (which takes about 40 minutes on modern PCs
and takes about 6.6 GB of disk space) you will get:

- three cross compilers (host to m68000/m68020-60/m5475; installed in
  `$INSTALL_DIR/<cpu>`; `INSTALL_DIR` is defined in build.sh)
- three native compilers (m68000/m68020-60/m5475; packaged as .tar.bz2 in
  the `binary-packages` folder)
- supporting tools and libraries for the above

Don't forget to install the gcc prerequisities: texinfo, autotools, bison,
flex etc. Typing `make` is usually what you need: this creates just the
classic m68000 cross compiler. `make clean` erases everything except
downloaded archives (and depacked source folders).

When it comes to the cross compilers, there's very little difference -- all
of them produce m68k/ColdFire code, the only difference is which one is
produced by default (this has meaning only if you want to compile a native
compiler).

Native compilers are a bit different, though. Not only they produce code for
the given CPU by default but each of them is also optimized (built) for the
given CPU. I.e. the m68020-60 build produces code for m68020-60 by default,
it's compiled with `-m68020-60` optimizations and uses `<prefix>/m68000` and
`<prefix>/m5475` as the multilib directories (m68020-60 is located in
`<prefix>`).

Remember, when using an optimized (non-68000) build, the 'standard' (from
mintlib point of view) multilib hierarchy no longer applies! My builds have
started to follow the standard multilib configuration which is:

`<prefix>/lib` for the CPU gcc is built for

`<prefix>/lib/<cpu>` for the other targets (CPUs)

I.e. for m68000 nothing has changed but for the optimized builds (esp.
ColdFire) you must be careful to put your own libraries into correct
directories.

In case of questions or problems, feel free to contact me at
miro.kropacek@gmail.com or ask in the MiNT mailing list.

Miro Kropacek,
05.06.2024
Kosice/Slovakia
