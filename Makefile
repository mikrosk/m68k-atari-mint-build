# Atari cross- and native-binutils/gcc toolchain build Makefile
# Miro Kropacek aka MiKRO / Mystic Bytes
# miro.kropacek@gmail.com
# version 2.0.4 (2016/08/20)

# please note you need the bash shell for correct compilation of mintlib.

PATCH_BINUTILS		= 20160320
PATCH_GCC		= 20130415
PATCH_PML		= 20110207

VERSION_BINUTILS	= 2.26
VERSION_GCC		= 4.6.4

VERSION_GMP		= 6.1.1
VERSION_MPFR		= 3.1.5
VERSION_MPC		= 1.0.3

VERSION_PML		= 2.03
VERSION_MINTLIB		= $(shell date +"%Y%m%d")
VERSION_MINTBIN		= 20110527

BASH	= $(shell which bash)
URLGET	= $(shell which wget || echo "`which curl` -O")


DOWNLOADS	= binutils-${VERSION_BINUTILS}.tar.bz2 gcc-${VERSION_GCC}.tar.bz2 \
		  gmp-${VERSION_GMP}.tar.lz mpfr-${VERSION_MPFR}.tar.bz2 mpc-${VERSION_MPC}.tar.gz \
		  pml-${VERSION_PML}.tar.bz2 binutils-${VERSION_BINUTILS}-mint-${PATCH_BINUTILS}.patch.bz2 \
		  gcc-${VERSION_GCC}-mint-${PATCH_GCC}.patch.bz2 pml-${VERSION_PML}-mint-${PATCH_PML}.patch.bz2

default: ./build.sh $(DOWNLOADS)
	MAKE=$(MAKE) $(BASH) ./build.sh

download: $(DOWNLOADS)

# Download libraries

binutils-${VERSION_BINUTILS}.tar.bz2:
	$(URLGET) http://ftp.gnu.org/gnu/binutils/$@

gcc-${VERSION_GCC}.tar.bz2:
	$(URLGET) http://ftp.gnu.org/gnu/gcc/gcc-${VERSION_GCC}/$@

gmp-${VERSION_GMP}.tar.lz:
	$(URLGET) https://gmplib.org/download/gmp/$@

mpfr-${VERSION_MPFR}.tar.bz2:
	$(URLGET) http://www.mpfr.org/mpfr-current/$@

mpc-${VERSION_MPC}.tar.gz:
	$(URLGET) http://www.multiprecision.org/mpc/download/$@

pml-${VERSION_PML}.tar.bz2:
	$(URLGET) http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$@

mintlib-CVS-${VERSION_MINTLIB}:
	CVSROOT=:pserver:cvsanon:cvsanon@sparemint.org:/mint cvs checkout -d mintlib-CVS-${VERSION_MINTLIB} mintlib

mintbin-CVS-${VERSION_MINTBIN}.tar.gz:
	$(URLGET) http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$@

# Download patches

binutils-${VERSION_BINUTILS}-mint-${PATCH_BINUTILS}.patch.bz2:
	$(URLGET) http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$@

gcc-${VERSION_GCC}-mint-${PATCH_GCC}.patch.bz2:
	$(URLGET) http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$@

pml-${VERSION_PML}-mint-${PATCH_PML}.patch.bz2:
	$(URLGET) http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$@

# Depacking and patching

binutils-${VERSION_BINUTILS}: binutils-${VERSION_BINUTILS}.tar.bz2 binutils-${VERSION_BINUTILS}-mint-${PATCH_BINUTILS}.patch.bz2
	tar xjf binutils-${VERSION_BINUTILS}.tar.bz2
	cd $@ && bzcat ../binutils-${VERSION_BINUTILS}-mint-${PATCH_BINUTILS}.patch.bz2 | patch -p1 && cd ..
	touch $@

gcc-${VERSION_GCC}: gcc-${VERSION_GCC}.tar.bz2 gcc-${VERSION_GCC}-mint-${PATCH_GCC}.patch.bz2
	tar xjf gcc-${VERSION_GCC}.tar.bz2
	cd $@ && bzcat ../gcc-${VERSION_GCC}-mint-${PATCH_GCC}.patch.bz2 | patch -p1 && cat ../gcc.patch | patch -p1 && cd ..
	touch $@

gmp-${VERSION_GMP}: gmp-${VERSION_GMP}.tar.lz
	tar --extract --lzip --file gmp-${VERSION_GMP}.tar.lz
	touch $@

mpfr-${VERSION_MPFR}: mpfr-${VERSION_MPFR}.tar.bz2
	tar xjf mpfr-${VERSION_MPFR}.tar.bz2
	touch $@

mpc-${VERSION_MPC}: mpc-${VERSION_MPC}.tar.gz
	tar xzf mpc-${VERSION_MPC}.tar.gz
	touch $@

mintbin-CVS-${VERSION_MINTBIN}: mintbin-CVS-${VERSION_MINTBIN}.tar.gz
	tar xzf mintbin-CVS-${VERSION_MINTBIN}.tar.gz
	cd $@ && patch -p1 < ../mintbin.patch
	touch $@
	
pml-${VERSION_PML}: pml-${VERSION_PML}.tar.bz2 pml-${VERSION_PML}-mint-${PATCH_PML}.patch.bz2
	tar xjf pml-${VERSION_PML}.tar.bz2
	cd $@ && bzcat ../pml-${VERSION_PML}-mint-${PATCH_PML}.patch.bz2 | patch -p1 && cat ../pml.patch | patch -p1 && cd ..
	touch $@

# Building

binutils-${VERSION_BINUTILS}-${CPU}-cross: binutils-${VERSION_BINUTILS}
	mkdir -p $@
	cd $@ && \
	PATH=${INSTALL_DIR}/bin:$$PATH ../binutils-${VERSION_BINUTILS}/configure --target=m68k-atari-mint --prefix=${INSTALL_DIR} --disable-nls --disable-werror && \
	$(MAKE) && \
	$(MAKE) install-strip

binutils: binutils-${VERSION_BINUTILS}-${CPU}-cross

gcc-${VERSION_GCC}-${CPU}-cross: gcc-${VERSION_GCC}
	mkdir -p $@
	cd $@ && \
	PATH=${INSTALL_DIR}/bin:$$PATH ../gcc-${VERSION_GCC}/configure --target=m68k-atari-mint --prefix=${INSTALL_DIR} --enable-languages="c,c++" --disable-nls --disable-libstdcxx-pch CFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" CXXFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" --with-cpu=${CPU} && \
	$(MAKE) all-target-libgcc && \
	cat ../gcc-${VERSION_GCC}/gcc/limitx.h ../gcc-${VERSION_GCC}/gcc/glimits.h ../gcc-${VERSION_GCC}/gcc/limity.h > gcc/include-fixed/limits.h # Dirty hack to fix the PATH_MAX issue. The good solution would be to configure gcc using --with-headers

# Shortcuts

gcc-multilib-patch: gcc-${VERSION_GCC}
	sed -e "s:\(MULTILIB_OPTIONS =\).*:\1 ${OPTS}:" -e "s:\(MULTILIB_DIRNAMES =\).*:\1 ${DIRS}:" gcc-${VERSION_GCC}/gcc/config/m68k/t-mint > t-mint.patched
	mv t-mint.patched gcc-${VERSION_GCC}/gcc/config/m68k/t-mint

gcc-preliminary: gcc-${VERSION_GCC}-${CPU}-cross

mintlib: mintlib-CVS-${VERSION_MINTLIB}
	cd mintlib-CVS-${VERSION_MINTLIB} && \
	$(MAKE) clean && \
	export GCC_BUILD_DIR="${PWD}/gcc-${VERSION_GCC}-${CPU}-cross" && export PATH=${INSTALL_DIR}/bin:$$PATH && \
	echo "$$GCC_BUILD_DIR/gcc/include -I$$GCC_BUILD_DIR/gcc/include-fixed" > includepath && \
	$(MAKE) SHELL=$(BASH) CROSS=yes WITH_020_LIB=no WITH_V4E_LIB=no CC="$$GCC_BUILD_DIR/gcc/xgcc -B$$GCC_BUILD_DIR/gcc/ -B${INSTALL_DIR}/bin/ -B${INSTALL_DIR}/lib/ -isystem ${INSTALL_DIR}/include -isystem ${INSTALL_DIR}/sys-include" && \
	$(MAKE) SHELL=$(BASH) CROSS=yes WITH_020_LIB=no WITH_V4E_LIB=no install && \
	touch $@

mintbin: mintbin-CVS-${VERSION_MINTBIN}
	cd mintbin-CVS-${VERSION_MINTBIN} && \
	PATH=${INSTALL_DIR}/bin:$$PATH ./configure --target=m68k-atari-mint --prefix=${INSTALL_DIR} --disable-nls && \
	$(MAKE) && \
	$(MAKE) install && \
	mv ${INSTALL_DIR}/m68k-atari-mint/bin/m68k-atari-mint-* ${INSTALL_DIR}/bin

pml: pml-${VERSION_PML}
	cd pml-${VERSION_PML}/pmlsrc && \
	$(MAKE) clean LIB="$(DIR)" && \
	export GCC_BUILD_DIR="${PWD}/gcc-${VERSION_GCC}-${CPU}-cross" && export PATH=${INSTALL_DIR}/bin:$$PATH && \
	$(MAKE) AR="m68k-atari-mint-ar" CC="$$GCC_BUILD_DIR/gcc/xgcc -B$$GCC_BUILD_DIR/gcc/ -B${INSTALL_DIR}/m68k-atari-mint/bin/ -B${INSTALL_DIR}/m68k-atari-mint/lib/ -isystem ${INSTALL_DIR}/m68k-atari-mint/include" CPU="$(OPTS)" CROSSDIR="${INSTALL_DIR}/m68k-atari-mint" LIB="$(DIR)" && \
	$(MAKE) install AR="m68k-atari-mint-ar" CC="$$GCC_BUILD_DIR/gcc/xgcc -B$$GCC_BUILD_DIR/gcc/ -B${INSTALL_DIR}/m68k-atari-mint/bin/ -B${INSTALL_DIR}/m68k-atari-mint/lib/ -isystem ${INSTALL_DIR}/m68k-atari-mint/include" CPU="$(OPTS)" CROSSDIR="${INSTALL_DIR}/m68k-atari-mint" LIB="$(DIR)"

gcc:
	export PATH=${INSTALL_DIR}/bin:$$PATH && cd gcc-${VERSION_GCC}-${CPU}-cross && $(MAKE) && $(MAKE) install-strip

# Atari building

binutils-${VERSION_BINUTILS}-${CPU}-atari: binutils-${VERSION_BINUTILS}
	mkdir -p $@
	cd $@ && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../binutils-${VERSION_BINUTILS}/configure --target=m68k-atari-mint --host=m68k-atari-mint --disable-nls --prefix=/usr CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" && \
	$(MAKE) && \
	$(MAKE) install DESTDIR=${PWD}/binary-package/${CPU}/binutils-${VERSION_BINUTILS}	# make install-strip doesn't work properly

binutils-atari: binutils-${VERSION_BINUTILS}-${CPU}-atari

gmp-${VERSION_GMP}-${CPU}-atari: gmp-${VERSION_GMP}
	mkdir -p $@
	cd $@ && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../gmp-${VERSION_GMP}/configure $(ASSEMBLY) --host=m68k-atari-mint --prefix=${PWD}/binary-package/${CPU}/gmp-${VERSION_GMP}/usr CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" && \
	$(MAKE) && \
	$(MAKE) install-strip

gmp-atari: gmp-${VERSION_GMP}-${CPU}-atari

mpfr-${VERSION_MPFR}-${CPU}-atari: mpfr-${VERSION_MPFR}
	mkdir -p $@
	cd $@ && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../mpfr-${VERSION_MPFR}/configure --host=m68k-atari-mint --with-gmp=${PWD}/binary-package/${CPU}/gmp-${VERSION_GMP}/usr --prefix=${PWD}/binary-package/${CPU}/mpfr-${VERSION_MPFR}/usr CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" && \
	$(MAKE) && \
	$(MAKE) install-strip

mpfr-atari: gmp-atari mpfr-${VERSION_MPFR}-${CPU}-atari

mpc-${VERSION_MPC}-${CPU}-atari: mpc-${VERSION_MPC}
	mkdir -p $@
	cd $@ && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../mpc-${VERSION_MPC}/configure --host=m68k-atari-mint --with-gmp=${PWD}/binary-package/${CPU}/gmp-${VERSION_GMP}/usr --with-mpfr=${PWD}/binary-package/${CPU}/mpfr-${VERSION_MPFR}/usr --prefix=${PWD}/binary-package/${CPU}/mpc-${VERSION_MPC}/usr CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" --disable-shared && \
	$(MAKE) && \
	$(MAKE) install-strip

mpc-atari: mpfr-atari mpc-${VERSION_MPC}-${CPU}-atari

gcc-${VERSION_GCC}-${CPU}-atari: gcc-${VERSION_GCC}
	mkdir -p $@
	cd $@ && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../gcc-${VERSION_GCC}/configure --target=m68k-atari-mint --host=m68k-atari-mint --enable-languages="c,c++" --disable-nls --disable-libstdcxx-pch --with-gmp=${PWD}/binary-package/${CPU}/gmp-${VERSION_GMP}/usr --with-mpfr=${PWD}/binary-package/${CPU}/mpfr-${VERSION_MPFR}/usr --with-mpc=${PWD}/binary-package/${CPU}/mpc-${VERSION_MPC}/usr --prefix=/usr CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" --with-cpu=${CPU} && \
	$(MAKE) && \
	$(MAKE) install-strip DESTDIR=${PWD}/binary-package/${CPU}/gcc-${VERSION_GCC}

gcc-atari: mpc-atari gcc-${VERSION_GCC}-${CPU}-atari

# Cleaning

clean:
	rm -rf binutils-${VERSION_BINUTILS}
	rm -rf binutils-${VERSION_BINUTILS}-${CPU}-cross
	rm -rf gmp-${VERSION_GMP}
	rm -rf gmp-${VERSION_GMP}-${CPU}-cross
	rm -rf mpfr-${VERSION_MPFR}
	rm -rf mpfr-${VERSION_MPFR}-${CPU}-cross
	rm -rf mpc-${VERSION_MPC}
	rm -rf mpc-${VERSION_MPC}-${CPU}-cross
	rm -rf gcc-${VERSION_GCC}
	rm -rf gcc-${VERSION_GCC}-${CPU}-cross
	rm -rf mintlib-CVS-${VERSION_MINTLIB}
	rm -rf pml-${VERSION_PML}
	rm -rf mintbin-CVS-${VERSION_MINTBIN}

pack-atari:
	for dir in binutils-${VERSION_BINUTILS} gmp-${VERSION_GMP} mpfr-${VERSION_MPFR} mpc-${VERSION_MPC} gcc-${VERSION_GCC}; \
	do \
		cd ${PWD}/binary-package/${CPU}/$$dir && tar cjf ../$$dir-${CPU}mint.tar.bz2 usr && cd ..; \
	done

strip-atari:
	find ${PWD}/binary-package -type f -executable -exec m68k-atari-mint-strip -s {} \;
	find ${PWD}/binary-package -type f -name '*.a' -exec m68k-atari-mint-strip -S -X -w -N '.L[0-9]*' {} \;

clean-atari:
	rm -rf binutils-${VERSION_BINUTILS}-${CPU}-atari
	rm -rf gmp-${VERSION_GMP}-${CPU}-atari
	rm -rf mpfr-${VERSION_MPFR}-${CPU}-atari
	rm -rf mpc-${VERSION_MPC}-${CPU}-atari
	rm -rf gcc-${VERSION_GCC}-${CPU}-atari
	rm -rf binary-package
