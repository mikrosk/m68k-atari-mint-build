# Atari cross- and native-binutils/gcc toolchain build Makefile
# Miro Kropacek aka MiKRO / Mystic Bytes
# miro.kropacek@gmail.com
# version 3.0.0 (2017/01/04)

# please note you need the bash shell for correct compilation of mintlib.

TARGET			= m68k-atari-mint

PATCH_BINUTILS		= 20160320
PATCH_GCC		= 20130415
PATCH_PML		= 20110207

VERSION_BINUTILS	= 2.26
VERSION_GCC		= 4.6.4

VERSION_GMP		= 6.1.1
VERSION_MPFR		= 3.1.5
VERSION_MPC		= 1.0.3

VERSION_PML		= 2.03
VERSION_MINTLIB		:= $(shell date +"%Y%m%d")
VERSION_MINTBIN		= 20110527

SH      = $(shell which sh)
BASH    = $(shell which bash)
URLGET	= $(shell which wget || echo "`which curl` -O")

# set to something like "> /dev/null" or ">> /tmp/mint-build.log"
# to redirect compilation standard output
OUT =

DOWNLOADS_COMMON = binutils-${VERSION_BINUTILS}.tar.bz2 \
		   gcc-${VERSION_GCC}.tar.bz2 \
		   binutils-${VERSION_BINUTILS}-mint-${PATCH_BINUTILS}.patch.bz2 \
		   gcc-${VERSION_GCC}-mint-${PATCH_GCC}.patch.bz2

DOWNLOADS_CROSS  = $(DOWNLOADS_COMMON) \
		   pml-${VERSION_PML}.tar.bz2 \
		   mintbin-CVS-${VERSION_MINTBIN}.tar.gz \
		   pml-${VERSION_PML}-mint-${PATCH_PML}.patch.bz2

DOWNLOADS_NATIVE = $(DOWNLOADS_COMMON) \
		   gmp-${VERSION_GMP}.tar.lz \
		   mpfr-${VERSION_MPFR}.tar.bz2 \
		   mpc-${VERSION_MPC}.tar.gz

DOWNLOADS_ALL	 = $(DOWNLOADS_CROSS) $(DOWNLOADS_NATIVE)

.PHONY: help download clean \
	clean-all       clean-all-skip-native       clean-native           all       all-skip-native       all-native \
	clean-m68000    clean-m68000-skip-native    clean-m68000-native    m68000    m68000-skip-native    m68000-native \
	clean-m68020-60 clean-m68020-60-skip-native clean-m68020-60-native m68020-60 m68020-60-skip-native m68020-60-native \
	clean-5475      clean-5475-skip-native      clean-5475-native      5475      5475-skip-native      5475-native

# display help

help: ./build.sh
	@echo "Makefile targets :"
	@echo "    download"
	@echo "    clean (same as clean-all)"
	@echo "    [clean-]all       / [clean-]all[-skip]-native"
	@echo "    [clean-]m68000    / [clean-]m68000[-skip]-native"
	@echo "    [clean-]m68020-60 / [clean-]m68020-60[-skip]-native"
	@echo "    [clean-]5475      / [clean-]5475[-skip]-native"

# "real" targets

all: ./build.sh $(DOWNLOADS_ALL)
	MAKE=$(MAKE) $(SH) $< --all

all-skip-native: ./build.sh $(DOWNLOADS_CROSS)
	MAKE=$(MAKE) $(SH) $< --all --skip-native

all-native: ./build.sh $(DOWNLOADS_NATIVE)
	MAKE=$(MAKE) $(SH) $< --all --native-only

m68000: ./build.sh $(DOWNLOADS_ALL)
	MAKE=$(MAKE) $(SH) $< m68000

m68000-skip-native: ./build.sh $(DOWNLOADS_CROSS)
	MAKE=$(MAKE) $(SH) $< --skip-native m68000

m68000-native: ./build.sh $(DOWNLOADS_NATIVE)
	MAKE=$(MAKE) $(SH) $< --native-only m68000

m68020-60: ./build.sh $(DOWNLOADS_ALL)
	MAKE=$(MAKE) $(SH) $< m68020-60

m68020-60-skip-native: ./build.sh $(DOWNLOADS_CROSS)
	MAKE=$(MAKE) $(SH) $< --skip-native m68020-60

m68020-60-native: ./build.sh $(DOWNLOADS_NATIVE)
	MAKE=$(MAKE) $(SH) $< --native-only m68020-60

5475: ./build.sh $(DOWNLOADS_ALL)
	MAKE=$(MAKE) $(SH) $< 5475

5475-skip-native: ./build.sh $(DOWNLOADS_CROSS)
	MAKE=$(MAKE) $(SH) $< --skip-native 5475

5475-native: ./build.sh $(DOWNLOADS_NATIVE)
	MAKE=$(MAKE) $(SH) $< --native-only 5475

clean: clean-all

clean-all: ./build.sh clean-source
	MAKE=$(MAKE) $(SH) $< --clean --all

clean-all-skip-native: ./build.sh clean-source
	MAKE=$(MAKE) $(SH) $< --clean --all --skip-native

clean-all-native: ./build.sh clean-source
	MAKE=$(MAKE) $(SH) $< --clean --all --native-only

clean-m68000: ./build.sh clean-source
	MAKE=$(MAKE) $(SH) $< --clean m68000

clean-m68000-skip-native: ./build.sh clean-source
	MAKE=$(MAKE) $(SH) $< --clean --skip-native m68000

clean-m68000-native: ./build.sh clean-source
	MAKE=$(MAKE) $(SH) $< --clean --native-only m68000

clean-m68020-60: ./build.sh clean-source
	MAKE=$(MAKE) $(SH) $< --clean m68020-60

clean-m68020-60-skip-native: ./build.sh clean-source
	MAKE=$(MAKE) $(SH) $< --clean --skip-native m68020-60

clean-m68020-60-native: ./build.sh clean-source
	MAKE=$(MAKE) $(SH) $< --clean --native-only m68020-60

clean-5475: ./build.sh clean-source
	MAKE=$(MAKE) $(SH) $< --clean 5475

clean-5475-skip-native: ./build.sh clean-source
	MAKE=$(MAKE) $(SH) $< --clean --skip-native 5475

clean-5475-native: ./build.sh clean-source
	MAKE=$(MAKE) $(SH) $< --clean --native-only 5475

download: $(DOWNLOADS_ALL)

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

mintbin-CVS-${VERSION_MINTBIN}.tar.gz:
	$(URLGET) http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$@

# Download ${TARGET}-specific patches

binutils-${VERSION_BINUTILS}-mint-${PATCH_BINUTILS}.patch.bz2:
	$(URLGET) http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$@

gcc-${VERSION_GCC}-mint-${PATCH_GCC}.patch.bz2:
	$(URLGET) http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$@

pml-${VERSION_PML}-mint-${PATCH_PML}.patch.bz2:
	$(URLGET) http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$@

# Target definitions for every new platform (m68k-linux-gnu for instance)
# right now we don't support building of more than one targets in one go so don't forget 'make clean-source'
# to be sure a fresh copy of binutils and gcc is used (and possibly patched)

.PHONY: binutils-m68k-atari-mint gcc-m68k-atari-mint libc-m68k-atari-mint gmp-m68k-atari-mint mpfr-m68k-atari-mint mpc-m68k-atari-mint

binutils-m68k-atari-mint: binutils-${VERSION_BINUTILS}.ok

gcc-m68k-atari-mint: gcc-${VERSION_GCC}.ok

libc-m68k-atari-mint: pml-${VERSION_PML}.ok mintbin-CVS-${VERSION_MINTBIN}.ok mintlib-CVS-${VERSION_MINTLIB}.ok

gmp-m68k-atari-mint: gmp-${VERSION_GMP}.ok
	# nothing else to do
mpfr-m68k-atari-mint: mpfr-${VERSION_MPFR}.ok
	# nothing else to do
mpc-m68k-atari-mint: mpc-${VERSION_MPC}.ok
	# nothing else to do

# Depacking and patching

binutils-${VERSION_BINUTILS}.ok: binutils-${VERSION_BINUTILS}.tar.bz2 binutils-${VERSION_BINUTILS}-mint-${PATCH_BINUTILS}.patch.bz2
	rm -rf binutils-${VERSION_BINUTILS} $@
	tar xjf binutils-${VERSION_BINUTILS}.tar.bz2
	cd binutils-${VERSION_BINUTILS} && bzcat ../binutils-${VERSION_BINUTILS}-mint-${PATCH_BINUTILS}.patch.bz2 | patch -p1
	touch $@

gcc-${VERSION_GCC}.ok: gcc-${VERSION_GCC}.tar.bz2 gcc.patch gcc-${VERSION_GCC}-mint-${PATCH_GCC}.patch.bz2
	rm -rf gcc-${VERSION_GCC}.ok $@
	tar xjf gcc-${VERSION_GCC}.tar.bz2
	cd gcc-${VERSION_GCC} && patch -p1 < ../gcc.patch
	cd gcc-${VERSION_GCC} && bzcat ../gcc-${VERSION_GCC}-mint-${PATCH_GCC}.patch.bz2 | patch -p1
	touch $@

gmp-${VERSION_GMP}.ok: gmp-${VERSION_GMP}.tar.lz
	rm -rf gmp-${VERSION_GMP}.ok $@
	tar --extract --lzip --file gmp-${VERSION_GMP}.tar.lz
	touch $@

mpfr-${VERSION_MPFR}.ok: mpfr-${VERSION_MPFR}.tar.bz2
	rm -rf mpfr-${VERSION_MPFR} $@
	tar xjf mpfr-${VERSION_MPFR}.tar.bz2
	touch $@

mpc-${VERSION_MPC}.ok: mpc-${VERSION_MPC}.tar.gz
	rm -rf mpc-${VERSION_MPC} $@.patched
	tar xzf mpc-${VERSION_MPC}.tar.gz
	touch $@

mintlib-CVS-${VERSION_MINTLIB}.ok:	mintlib.patch
	rm -rf $@ mintlib-CVS-${VERSION_MINTLIB}
	CVSROOT=:pserver:cvsanon:cvsanon@sparemint.org:/mint cvs checkout -d mintlib-CVS-${VERSION_MINTLIB} mintlib $(OUT)
	cd mintlib-CVS-${VERSION_MINTLIB} && patch -p1 < ../mintlib.patch
	touch $@

mintbin-CVS-${VERSION_MINTBIN}.ok: mintbin-CVS-${VERSION_MINTBIN}.tar.gz mintbin.patch
	rm -rf $@ mintbin-CVS-${VERSION_MINTBIN}
	tar xzf mintbin-CVS-${VERSION_MINTBIN}.tar.gz
	cd mintbin-CVS-${VERSION_MINTBIN} && patch -p1 < ../mintbin.patch
	touch $@

pml-${VERSION_PML}.ok: pml-${VERSION_PML}.tar.bz2 pml-${VERSION_PML}-mint-${PATCH_PML}.patch.bz2 pml-${VERSION_PML}-mint-${PATCH_PML}.patch.bz2
	rm -rf pml-${VERSION_PML} $@
	tar xjf pml-${VERSION_PML}.tar.bz2
	cd pml-${VERSION_PML} && bzcat ../pml-${VERSION_PML}-mint-${PATCH_PML}.patch.bz2 | patch -p1
	cd pml-${VERSION_PML} && cat ../pml.patch | patch -p1
	touch $@

# Building

binutils-${VERSION_BINUTILS}-${CPU}-cross: binutils-${TARGET}
	mkdir -p $@
	cd $@ && PATH=${INSTALL_DIR}/bin:$$PATH ../binutils-${VERSION_BINUTILS}/configure --target=${TARGET} --prefix=${INSTALL_DIR} --disable-nls --disable-werror
	cd $@ && $(MAKE) -j3 $(OUT)
	cd $@ && $(MAKE) install-strip $(OUT)

binutils: binutils-${VERSION_BINUTILS}-${CPU}-cross

gcc-${VERSION_GCC}-${CPU}-cross-preliminary: gcc-${TARGET}
	mkdir -p $@
	ln -sfv . ${INSTALL_DIR}/${TARGET}/usr
	cd $@ && PATH=${INSTALL_DIR}/bin:$$PATH ../gcc-${VERSION_GCC}/configure \
		--prefix=${INSTALL_DIR} \
		--target=${TARGET} \
		--with-sysroot=${INSTALL_DIR}/${TARGET} \
		--disable-nls \
		--disable-shared \
		--without-headers \
		--with-newlib \
		--disable-decimal-float \
		--disable-libgomp \
		--disable-libmudflap \
		--disable-libssp \
		--disable-libatomic \
		--disable-libquadmath \
		--disable-threads \
		--enable-languages=c \
		--disable-multilib \
		--disable-libstdcxx-pch
	cd $@ && $(MAKE) -j3 all-gcc all-target-libgcc $(OUT)
	cd $@ && $(MAKE) install-gcc install-target-libgcc $(OUT)

# Shortcuts

gcc-multilib-patch: gcc-${TARGET}
	sed -e "s:\(MULTILIB_OPTIONS =\).*:\1 ${OPTS}:" -e "s:\(MULTILIB_DIRNAMES =\).*:\1 ${DIRS}:" gcc-${VERSION_GCC}/gcc/config/m68k/t-mint > t-mint.patched
	mv t-mint.patched gcc-${VERSION_GCC}/gcc/config/m68k/t-mint

gcc-preliminary: gcc-${VERSION_GCC}-${CPU}-cross-preliminary

mintlib: libc-${TARGET}
	cd mintlib-CVS-${VERSION_MINTLIB} && $(MAKE) OUT= clean $(OUT)
	cd mintlib-CVS-${VERSION_MINTLIB} && PATH=${INSTALL_DIR}/bin:$$PATH \
		$(MAKE) SHELL=$(BASH) CROSS=yes WITH_020_LIB=no WITH_V4E_LIB=no CC="${TARGET}-gcc" HOST_CC="$(CC)" OUT= $(OUT)
	cd mintlib-CVS-${VERSION_MINTLIB} && PATH=${INSTALL_DIR}/bin:$$PATH \
		$(MAKE) SHELL=$(BASH) CROSS=yes WITH_020_LIB=no WITH_V4E_LIB=no OUT= install $(OUT)

mintbin: libc-${TARGET}
	cd mintbin-CVS-${VERSION_MINTBIN} && PATH=${INSTALL_DIR}/bin:$$PATH ./configure --target=${TARGET} --prefix=${INSTALL_DIR} --disable-nls
	cd mintbin-CVS-${VERSION_MINTBIN} && $(MAKE) OUT= $(OUT)
	cd mintbin-CVS-${VERSION_MINTBIN} && $(MAKE) OUT= install $(OUT)
	mv -v ${INSTALL_DIR}/${TARGET}/bin/${TARGET}-* ${INSTALL_DIR}/bin

pml: libc-${TARGET}
	cd pml-${VERSION_PML}/pmlsrc && $(MAKE) clean LIB="$(DIR)" $(OUT)
	cd pml-${VERSION_PML}/pmlsrc && PATH=${INSTALL_DIR}/bin:$$PATH \
	$(MAKE) AR="${TARGET}-ar" CC="${TARGET}-gcc" CPU="$(OPTS)" CROSSDIR="${INSTALL_DIR}/${TARGET}" LIB="$(DIR)" $(OUT)
	cd pml-${VERSION_PML}/pmlsrc && PATH=${INSTALL_DIR}/bin:$$PATH \
	$(MAKE) install AR="${TARGET}-ar" CC="${TARGET}-gcc" CPU="$(OPTS)" CROSSDIR="${INSTALL_DIR}/${TARGET}" LIB="$(DIR)" $(OUT)

gcc-${VERSION_GCC}-${CPU}-cross-final: ${INSTALL_DIR}/${TARGET}/lib/libc.a ${INSTALL_DIR}/${TARGET}/lib/libm.a
	mkdir -p $@
	cd $@ && PATH=${INSTALL_DIR}/bin:$$PATH ../gcc-${VERSION_GCC}/configure \
		--prefix=${INSTALL_DIR} \
		--target=${TARGET} \
		--with-sysroot=${INSTALL_DIR}/${TARGET} \
		--disable-nls \
		--enable-languages=c,c++ \
		--enable-c99 \
		--enable-long-long \
		--disable-libstdcxx-pch \
		CFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" CXXFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" --with-cpu=${CPU}
	cd $@ && $(MAKE) -j3 $(OUT)
	cd $@ && $(MAKE) install-strip $(OUT)

gcc: gcc-${VERSION_GCC}-${CPU}-cross-final

# Atari building

binutils-${VERSION_BINUTILS}-${CPU}-atari: binutils-${TARGET}
	mkdir -p $@
	cd $@ && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../binutils-${VERSION_BINUTILS}/configure --target=${TARGET} --host=${TARGET} --disable-nls --prefix=/usr CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" && \
	$(MAKE) $(OUT) && \
	$(MAKE) install DESTDIR=${PWD}/binary-package/${CPU}/binutils-${VERSION_BINUTILS}	# make install-strip doesn't work properly

binutils-atari: binutils-${VERSION_BINUTILS}-${CPU}-atari

gmp-${VERSION_GMP}-${CPU}-atari: gmp-${TARGET}
	mkdir -p $@
	cd $@ && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../gmp-${VERSION_GMP}/configure $(ASSEMBLY) --host=${TARGET} --prefix=${PWD}/binary-package/${CPU}/gmp-${VERSION_GMP}/usr CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" && \
	$(MAKE) $(OUT) && \
	$(MAKE) install-strip

gmp-atari: gmp-${VERSION_GMP}-${CPU}-atari

mpfr-${VERSION_MPFR}-${CPU}-atari: mpfr-${TARGET}
	mkdir -p $@
	cd $@ && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../mpfr-${VERSION_MPFR}/configure --host=${TARGET} --with-gmp=${PWD}/binary-package/${CPU}/gmp-${VERSION_GMP}/usr --prefix=${PWD}/binary-package/${CPU}/mpfr-${VERSION_MPFR}/usr CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" && \
	$(MAKE) $(OUT) && \
	$(MAKE) install-strip

mpfr-atari: gmp-atari mpfr-${VERSION_MPFR}-${CPU}-atari

mpc-${VERSION_MPC}-${CPU}-atari: mpc-${TARGET}
	mkdir -p $@
	cd $@ && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../mpc-${VERSION_MPC}/configure --host=${TARGET} --with-gmp=${PWD}/binary-package/${CPU}/gmp-${VERSION_GMP}/usr --with-mpfr=${PWD}/binary-package/${CPU}/mpfr-${VERSION_MPFR}/usr --prefix=${PWD}/binary-package/${CPU}/mpc-${VERSION_MPC}/usr CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" --disable-shared && \
	$(MAKE) $(OUT) && \
	$(MAKE) install-strip

mpc-atari: mpfr-atari mpc-${VERSION_MPC}-${CPU}-atari

gcc-${VERSION_GCC}-${CPU}-atari: gcc-${TARGET}
	mkdir -p $@
	cd $@ && PATH=${INSTALL_DIR}/bin:$$PATH ../gcc-${VERSION_GCC}/configure \
		--prefix=/usr \
		--host=${TARGET} \
		--target=${TARGET} \
		--disable-nls \
		--enable-languages="c,c++" \
		--enable-c99 \
		--enable-long-long \
		--disable-libstdcxx-pch \
		--with-gmp=${PWD}/binary-package/${CPU}/gmp-${VERSION_GMP}/usr \
		--with-mpfr=${PWD}/binary-package/${CPU}/mpfr-${VERSION_MPFR}/usr \
		--with-mpc=${PWD}/binary-package/${CPU}/mpc-${VERSION_MPC}/usr \
		CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" --with-cpu=${CPU}
	cd $@ && $(MAKE) -j3 $(OUT)
	cd $@ && $(MAKE) install-strip DESTDIR=${PWD}/binary-package/${CPU}/gcc-${VERSION_GCC} $(OUT)

gcc-atari: mpc-atari gcc-${VERSION_GCC}-${CPU}-atari

# Cleaning

clean-source:
	rm -rf binutils-${VERSION_BINUTILS}
	rm -rf gmp-${VERSION_GMP}
	rm -rf mpfr-${VERSION_MPFR}
	rm -rf mpc-${VERSION_MPC}
	rm -rf gcc-${VERSION_GCC}
	for dir in $$(ls | grep mintlib-CVS-????????); \
	do \
		rm -rf $$dir; \
	done
	rm -rf pml-${VERSION_PML}
	rm -rf mintbin-CVS-${VERSION_MINTBIN}
	rm -f *.ok
	rm -f *~

clean-cross:
	rm -rf binutils-${VERSION_BINUTILS}-${CPU}-cross
	rm -rf gcc-${VERSION_GCC}-${CPU}-cross-preliminary
	rm -rf gcc-${VERSION_GCC}-${CPU}-cross-final

pack-atari:
	for dir in binutils-${VERSION_BINUTILS} gmp-${VERSION_GMP} mpfr-${VERSION_MPFR} mpc-${VERSION_MPC} gcc-${VERSION_GCC}; \
	do \
		cd ${PWD}/binary-package/${CPU}/$$dir && tar cjf ../$$dir-${CPU}mint.tar.bz2 usr && cd ..; \
	done

strip-atari:
	find ${PWD}/binary-package -type f -perm -a=x -exec ${TARGET}-strip -s {} \;
	find ${PWD}/binary-package -type f -name '*.a' -exec ${TARGET}-strip -S -X -w -N '.L[0-9]*' {} \;

clean-atari:
	rm -rf binutils-${VERSION_BINUTILS}-${CPU}-atari
	rm -rf gmp-${VERSION_GMP}-${CPU}-atari
	rm -rf mpfr-${VERSION_MPFR}-${CPU}-atari
	rm -rf mpc-${VERSION_MPC}-${CPU}-atari
	rm -rf gcc-${VERSION_GCC}-${CPU}-atari
	rm -rf binary-package
