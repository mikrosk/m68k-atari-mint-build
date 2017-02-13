# Atari cross- and native-binutils/gcc toolchain build Makefile
# Miro Kropacek aka MiKRO / Mystic Bytes
# miro.kropacek@gmail.com
# version 3.0.1 (2017/02/13)

# please note you need the bash shell for correct compilation of mintlib.

TARGET			= m68k-atari-mint

PATCH_BINUTILS		= 20160320
PATCH_GCC		= 20130415
PATCH_PML		= 20110207

VERSION_BINUTILS	= 2.26
VERSION_GCC		= 4.6.4

VERSION_PML		= 2.03
VERSION_MINTLIB		:= $(shell date +"%Y%m%d")
VERSION_MINTBIN		= 20110527

SH      = $(shell which sh)
BASH    = $(shell which bash)
URLGET	= $(shell which wget || echo "`which curl` -O")

# set to something like "> /dev/null" or ">> /tmp/mint-build.log"
# to redirect compilation standard output
OUT =

DOWNLOADS = binutils-${VERSION_BINUTILS}.tar.bz2 \
	    gcc-${VERSION_GCC}.tar.bz2 \
	    pml-${VERSION_PML}.tar.bz2 \
	    mintbin-CVS-${VERSION_MINTBIN}.tar.gz \
	    binutils-${VERSION_BINUTILS}-mint-${PATCH_BINUTILS}.patch.bz2 \
	    gcc-${VERSION_GCC}-mint-${PATCH_GCC}.patch.bz2 \
	    pml-${VERSION_PML}-mint-${PATCH_PML}.patch.bz2

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

all: ./build.sh download
	MAKE=$(MAKE) $(SH) $< --all

all-skip-native: ./build.sh download
	MAKE=$(MAKE) $(SH) $< --all --skip-native

all-native: ./build.sh download
	MAKE=$(MAKE) $(SH) $< --all --native-only

m68000: ./build.sh download
	MAKE=$(MAKE) $(SH) $< m68000

m68000-skip-native: ./build.sh download
	MAKE=$(MAKE) $(SH) $< --skip-native m68000

m68000-native: ./build.sh download
	MAKE=$(MAKE) $(SH) $< --native-only m68000

m68020-60: ./build.sh download
	MAKE=$(MAKE) $(SH) $< m68020-60

m68020-60-skip-native: ./build.sh download
	MAKE=$(MAKE) $(SH) $< --skip-native m68020-60

m68020-60-native: ./build.sh download
	MAKE=$(MAKE) $(SH) $< --native-only m68020-60

5475: ./build.sh download
	MAKE=$(MAKE) $(SH) $< 5475

5475-skip-native: ./build.sh download
	MAKE=$(MAKE) $(SH) $< --skip-native 5475

5475-native: ./build.sh download
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

download: $(DOWNLOADS)

# Download libraries

binutils-${VERSION_BINUTILS}.tar.bz2:
	$(URLGET) http://ftp.gnu.org/gnu/binutils/$@

gcc-${VERSION_GCC}.tar.bz2:
	$(URLGET) http://ftp.gnu.org/gnu/gcc/gcc-${VERSION_GCC}/$@

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
# right now we don't support building of more than one target in one go so don't forget 'make clean-source'
# to be sure a fresh copy of binutils and gcc is used (and possibly patched)

.PHONY: binutils-m68k-atari-mint.ok gcc-m68k-atari-mint.ok libc-m68k-atari-mint.ok

binutils-m68k-atari-mint.ok: binutils-${VERSION_BINUTILS}.ok
	# target specific patches here
	touch $@

gcc-m68k-atari-mint.ok: gcc-${VERSION_GCC}.ok
	# target specific patches here
	touch $@

libc-m68k-atari-mint.ok: pml-${VERSION_PML}.ok mintbin-CVS-${VERSION_MINTBIN}.ok mintlib-git-${VERSION_MINTLIB}.ok
	# target specific patches here
	touch $@

# Depacking and patching

binutils-${VERSION_BINUTILS}.ok: binutils-${VERSION_BINUTILS}.tar.bz2 binutils-${VERSION_BINUTILS}-mint-${PATCH_BINUTILS}.patch.bz2
	rm -rf $@ binutils-${VERSION_BINUTILS}
	tar xjf binutils-${VERSION_BINUTILS}.tar.bz2
	cd binutils-${VERSION_BINUTILS} && bzcat ../binutils-${VERSION_BINUTILS}-mint-${PATCH_BINUTILS}.patch.bz2 | patch -p1
	touch $@

gcc-${VERSION_GCC}.ok: gcc-${VERSION_GCC}.tar.bz2 gcc.patch gmp.patch gcc-${VERSION_GCC}-mint-${PATCH_GCC}.patch.bz2
	rm -rf $@ gcc-${VERSION_GCC}
	tar xjf gcc-${VERSION_GCC}.tar.bz2
	cd gcc-${VERSION_GCC} && contrib/download_prerequisites
	cd gcc-${VERSION_GCC} && patch -p1 < ../gcc.patch
	cd gcc-${VERSION_GCC} && patch -p1 < ../gmp.patch
	cd gcc-${VERSION_GCC} && bzcat ../gcc-${VERSION_GCC}-mint-${PATCH_GCC}.patch.bz2 | patch -p1
	touch $@

mintlib-git-${VERSION_MINTLIB}.ok: mintlib.patch
	rm -rf $@ mintlib-git-${VERSION_MINTLIB}
	git clone https://github.com/freemint/mintlib.git mintlib-git-${VERSION_MINTLIB} $(OUT)
	cd mintlib-git-${VERSION_MINTLIB} && patch -p1 < ../mintlib.patch
	touch $@

mintbin-CVS-${VERSION_MINTBIN}.ok: mintbin-CVS-${VERSION_MINTBIN}.tar.gz mintbin.patch
	rm -rf $@ mintbin-CVS-${VERSION_MINTBIN}
	tar xzf mintbin-CVS-${VERSION_MINTBIN}.tar.gz
	cd mintbin-CVS-${VERSION_MINTBIN} && patch -p1 < ../mintbin.patch
	touch $@

pml-${VERSION_PML}.ok: pml-${VERSION_PML}.tar.bz2 pml-${VERSION_PML}-mint-${PATCH_PML}.patch.bz2 pml-${VERSION_PML}-mint-${PATCH_PML}.patch.bz2
	rm -rf $@ pml-${VERSION_PML}
	tar xjf pml-${VERSION_PML}.tar.bz2
	cd pml-${VERSION_PML} && bzcat ../pml-${VERSION_PML}-mint-${PATCH_PML}.patch.bz2 | patch -p1
	cd pml-${VERSION_PML} && cat ../pml.patch | patch -p1
	touch $@

# Preliminary build

binutils-${VERSION_BINUTILS}-${CPU}-cross.ok: binutils-${TARGET}.ok
	rm -rf $@ binutils-${VERSION_BINUTILS}-${CPU}-cross
	mkdir -p binutils-${VERSION_BINUTILS}-${CPU}-cross
	cd binutils-${VERSION_BINUTILS}-${CPU}-cross && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../binutils-${VERSION_BINUTILS}/configure --target=${TARGET} --prefix=${INSTALL_DIR} --disable-nls --disable-werror && \
	$(MAKE) -j3 $(OUT) && \
	$(MAKE) install-strip $(OUT)
	touch $@

binutils: binutils-${VERSION_BINUTILS}-${CPU}-cross.ok

gcc-${VERSION_GCC}-${CPU}-cross-preliminary.ok: gcc-${TARGET}.ok
	rm -rf $@ gcc-${VERSION_GCC}-${CPU}-cross-preliminary
	mkdir -p gcc-${VERSION_GCC}-${CPU}-cross-preliminary
	ln -sfv . ${INSTALL_DIR}/${TARGET}/usr
	cd gcc-${VERSION_GCC}-${CPU}-cross-preliminary && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../gcc-${VERSION_GCC}/configure \
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
		--disable-libstdcxx-pch && \
	$(MAKE) -j3 all-gcc all-target-libgcc $(OUT) && \
	$(MAKE) install-gcc install-target-libgcc $(OUT)
	touch $@

# Shortcuts

gcc-multilib-patch: gcc-${TARGET}.ok
	sed -e "s:\(MULTILIB_OPTIONS =\).*:\1 ${OPTS}:" -e "s:\(MULTILIB_DIRNAMES =\).*:\1 ${DIRS}:" gcc-${VERSION_GCC}/gcc/config/m68k/t-mint > t-mint.patched
	mv t-mint.patched gcc-${VERSION_GCC}/gcc/config/m68k/t-mint

gcc-gmp-patch: gcc-${TARGET}.ok
	sed -e 's/^host_cpu=.*$$/host_cpu=${CPU}/;' gcc-${VERSION_GCC}/gmp/configure > configure.patched
	mv configure.patched gcc-${VERSION_GCC}/gmp/configure

gcc-preliminary: gcc-${VERSION_GCC}-${CPU}-cross-preliminary.ok

mintlib: libc-${TARGET}.ok
	cd mintlib-git-${VERSION_MINTLIB} && $(MAKE) OUT= clean $(OUT)
	cd mintlib-git-${VERSION_MINTLIB} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		$(MAKE) SHELL=$(BASH) CROSS=yes WITH_020_LIB=no WITH_V4E_LIB=no CC="${TARGET}-gcc" HOST_CC="$(CC)" OUT= $(OUT)
	cd mintlib-git-${VERSION_MINTLIB} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		$(MAKE) SHELL=$(BASH) CROSS=yes WITH_020_LIB=no WITH_V4E_LIB=no OUT= install $(OUT)

mintbin: libc-${TARGET}.ok
	cd mintbin-CVS-${VERSION_MINTBIN} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		./configure --target=${TARGET} --prefix=${INSTALL_DIR} --disable-nls
	cd mintbin-CVS-${VERSION_MINTBIN} && $(MAKE) OUT= $(OUT)
	cd mintbin-CVS-${VERSION_MINTBIN} && $(MAKE) OUT= install $(OUT)
	mv -v ${INSTALL_DIR}/${TARGET}/bin/${TARGET}-* ${INSTALL_DIR}/bin

pml: libc-${TARGET}.ok
	cd pml-${VERSION_PML}/pmlsrc && $(MAKE) clean LIB="$(DIR)" $(OUT)
	cd pml-${VERSION_PML}/pmlsrc && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		$(MAKE) AR="${TARGET}-ar" CC="${TARGET}-gcc" CPU="$(OPTS)" CROSSDIR="${INSTALL_DIR}/${TARGET}" LIB="$(DIR)" $(OUT)
	cd pml-${VERSION_PML}/pmlsrc && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		$(MAKE) install AR="${TARGET}-ar" CC="${TARGET}-gcc" CPU="$(OPTS)" CROSSDIR="${INSTALL_DIR}/${TARGET}" LIB="$(DIR)" $(OUT)

# Full build

gcc-${VERSION_GCC}-${CPU}-cross-final.ok: ${INSTALL_DIR}/${TARGET}/lib/libc.a ${INSTALL_DIR}/${TARGET}/lib/libm.a
	rm -rf $@ gcc-${VERSION_GCC}-${CPU}-cross-final
	mkdir -p gcc-${VERSION_GCC}-${CPU}-cross-final
	cd gcc-${VERSION_GCC}-${CPU}-cross-final && \
	export PATH=${INSTALL_DIR}/bin:$$PATH CFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" CXXFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" && \
	../gcc-${VERSION_GCC}/configure \
		--prefix=${INSTALL_DIR} \
		--target=${TARGET} \
		--with-sysroot=${INSTALL_DIR}/${TARGET} \
		--disable-nls \
		--enable-languages=c,c++ \
		--enable-c99 \
		--enable-long-long \
		--disable-libstdcxx-pch \
		--with-cpu=${CPU} && \
	$(MAKE) -j3 $(OUT) && \
	$(MAKE) install-strip $(OUT)
	touch $@

gcc: gcc-${VERSION_GCC}-${CPU}-cross-final.ok

# Atari building

check-target-gcc:
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	multi_dir=`${TARGET}-gcc -${OPT} -print-multi-directory` && \
	if [ $$multi_dir != "." ]; then echo "\n${TARGET}-gcc is not configured for default ${CPU} output\n"; exit 1; fi

binutils-${VERSION_BINUTILS}-${CPU}-atari.ok: binutils-${TARGET}.ok
	rm -rf $@ binutils-${VERSION_BINUTILS}-${CPU}
	mkdir -p binutils-${VERSION_BINUTILS}-${CPU}
	cd binutils-${VERSION_BINUTILS}-${CPU} && \
	export PATH=${INSTALL_DIR}/bin:$$PATH CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" && \
	../binutils-${VERSION_BINUTILS}/configure --target=${TARGET} --host=${TARGET} --disable-nls --prefix=/usr && \
	$(MAKE) -j3 $(OUT) && \
	$(MAKE) install DESTDIR=${PWD}/binary-package/${CPU}/binutils-${VERSION_BINUTILS}	# make install-strip doesn't work properly
	touch $@

binutils-atari: check-target-gcc binutils-${VERSION_BINUTILS}-${CPU}-atari.ok

gcc-${VERSION_GCC}-${CPU}-atari.ok: gcc-${TARGET}.ok
	rm -rf $@ gcc-${VERSION_GCC}-${CPU}-atari
	mkdir -p gcc-${VERSION_GCC}-${CPU}-atari
	cd gcc-${VERSION_GCC}-${CPU}-atari && \
	export PATH=${INSTALL_DIR}/bin:$$PATH CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" && \
	../gcc-${VERSION_GCC}/configure \
		--prefix=/usr \
		--host=${TARGET} \
		--target=${TARGET} \
		--disable-nls \
		--enable-languages="c,c++" \
		--enable-c99 \
		--enable-long-long \
		--disable-libstdcxx-pch \
		 --with-cpu=${CPU} && \
	$(MAKE) -j3 $(OUT) && \
	$(MAKE) install-strip DESTDIR=${PWD}/binary-package/${CPU}/gcc-${VERSION_GCC} $(OUT)
	touch $@

gcc-atari: check-target-gcc gcc-${VERSION_GCC}-${CPU}-atari.ok

# Cleaning

clean-source:
	rm -rf binutils-${VERSION_BINUTILS}
	rm -rf gcc-${VERSION_GCC}
	for dir in $$(ls | grep mintlib-git-????????); \
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
	for dir in binutils-${VERSION_BINUTILS} gcc-${VERSION_GCC}; \
	do \
		cd ${PWD}/binary-package/${CPU}/$$dir && tar cjf ../$$dir-${CPU}mint.tar.bz2 usr && cd ..; \
	done

strip-atari:
	find ${PWD}/binary-package -type f -perm -a=x -exec ${TARGET}-strip -s {} \;
	find ${PWD}/binary-package -type f -name '*.a' -exec ${TARGET}-strip -S -X -w -N '.L[0-9]*' {} \;

clean-atari:
	rm -rf binutils-${VERSION_BINUTILS}-${CPU}-atari
	rm -rf gcc-${VERSION_GCC}-${CPU}-atari
	rm -rf binary-package
