# Atari cross- and native-binutils/gcc toolchain build Makefile
# Miro Kropacek aka MiKRO / Mystic Bytes
# miro.kropacek@gmail.com
# version 4.0.0 (2017/09/22)

# please note you need the bash shell for correct compilation of mintlib.

REPOSITORY_BINUTILS	= m68k-atari-mint-binutils-gdb
REPOSITORY_GCC		= m68k-atari-mint-gcc
REPOSITORY_MINTLIB	= mintlib

GITHUB_URL_BINUTILS	= https://github.com/freemint/${REPOSITORY_BINUTILS}/archive
GITHUB_URL_GCC		= https://github.com/freemint/${REPOSITORY_GCC}/archive
GITHUB_URL_MINTLIB	= https://github.com/freemint/${REPOSITORY_MINTLIB}/archive

BRANCH_BINUTILS		= binutils-2_28-mint
BRANCH_GCC		= gcc-7-mint
BRANCH_MINTLIB		= master

ARCHIVE_BINUTILS	= ${BRANCH_BINUTILS}.zip
ARCHIVE_GCC		= ${BRANCH_GCC}.zip
ARCHIVE_MINTLIB		= ${BRANCH_MINTLIB}.zip

FOLDER_BINUTILS		= ${REPOSITORY_BINUTILS}-${BRANCH_BINUTILS}
FOLDER_GCC		= ${REPOSITORY_GCC}-${BRANCH_GCC}
FOLDER_MINTLIB		= ${REPOSITORY_MINTLIB}-${BRANCH_MINTLIB}

PATCH_PML		= 20110207

VERSION_BINUTILS	= 2.28
VERSION_GCC		= 7.2.0

VERSION_PML		= 2.03
VERSION_MINTBIN		= 20110527

SH      = $(shell which sh)
BASH    = $(shell which bash)
URLGET	= $(shell which wget || echo "`which curl` -L -O")
UNZIP	= $(shell (which 7za > /dev/null && echo "`which 7za` x") || which unzip)

# set to something like "> /dev/null" or ">> /tmp/mint-build.log"
# to redirect compilation standard output
OUT =

DOWNLOADS = ${ARCHIVE_BINUTILS} ${ARCHIVE_GCC} ${ARCHIVE_MINTLIB} \
        pml-${VERSION_PML}.tar.bz2 \
	    mintbin-CVS-${VERSION_MINTBIN}.tar.gz \
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

${ARCHIVE_BINUTILS}:
	$(URLGET) ${GITHUB_URL_BINUTILS}/$@

${ARCHIVE_GCC}:
	$(URLGET) ${GITHUB_URL_GCC}/$@

${ARCHIVE_MINTLIB}:
	$(URLGET) ${GITHUB_URL_MINTLIB}/$@

pml-${VERSION_PML}.tar.bz2:
	$(URLGET) http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$@

mintbin-CVS-${VERSION_MINTBIN}.tar.gz:
	$(URLGET) http://vincent.riviere.free.fr/soft/m68k-atari-mint/archives/$@

# Download ${TARGET}-specific patches

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

libc-m68k-atari-mint.ok: pml-${VERSION_PML}.ok mintbin-CVS-${VERSION_MINTBIN}.ok mintlib.ok
	# target specific patches here
	touch $@

# Depacking and patching

binutils-${VERSION_BINUTILS}.ok: ${ARCHIVE_BINUTILS}
	rm -rf $@ ${FOLDER_BINUTILS}
	$(UNZIP) ${ARCHIVE_BINUTILS} > /dev/null
	touch $@

gcc-${VERSION_GCC}.ok: ${ARCHIVE_GCC} gmp.patch
	rm -rf $@ ${FOLDER_GCC}
	$(UNZIP) ${ARCHIVE_GCC} > /dev/null
	cd ${FOLDER_GCC} && contrib/download_prerequisites
	cd ${FOLDER_GCC} && patch -p0 < ../gmp.patch
	touch $@

mintlib.ok: ${ARCHIVE_MINTLIB} mintlib.patch
	rm -rf $@ ${FOLDER_MINTLIB}
	$(UNZIP) ${ARCHIVE_MINTLIB} > /dev/null
	cd ${FOLDER_MINTLIB} && patch -p1 < ../mintlib.patch
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
	rm -rf $@ ${FOLDER_BINUTILS}-${CPU}-cross
	mkdir -p ${FOLDER_BINUTILS}-${CPU}-cross
	cd ${FOLDER_BINUTILS}-${CPU}-cross && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../${FOLDER_BINUTILS}/configure --target=${TARGET} --prefix=${INSTALL_DIR} --disable-nls --disable-werror \
					--disable-gdb --disable-libdecnumber --disable-readline --disable-sim && \
	$(MAKE) -j3 $(OUT) && \
	$(MAKE) install-strip $(OUT)
	touch $@

binutils: binutils-${VERSION_BINUTILS}-${CPU}-cross.ok

gcc-${VERSION_GCC}-${CPU}-cross-preliminary.ok: gcc-${TARGET}.ok
	rm -rf $@ ${FOLDER_GCC}-${CPU}-cross-preliminary
	mkdir -p ${FOLDER_GCC}-${CPU}-cross-preliminary
	ln -sfv . ${INSTALL_DIR}/${TARGET}/usr
	cd ${FOLDER_GCC}-${CPU}-cross-preliminary && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../${FOLDER_GCC}/configure \
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
	sed -e "s:\(MULTILIB_OPTIONS =\).*:\1 ${OPTS}:" -e "s:\(MULTILIB_DIRNAMES =\).*:\1 ${DIRS}:" ${FOLDER_GCC}/gcc/config/m68k/t-mint > t-mint.patched
	mv t-mint.patched ${FOLDER_GCC}/gcc/config/m68k/t-mint

gcc-gmp-patch: gcc-${TARGET}.ok
	sed -e 's/^host_cpu=.*$$/host_cpu=${CPU}/;' ${FOLDER_GCC}/gmp/configure > configure.patched
	mv configure.patched ${FOLDER_GCC}/gmp/configure  && chmod +x ${FOLDER_GCC}/gmp/configure

gcc-preliminary: gcc-${VERSION_GCC}-${CPU}-cross-preliminary.ok

mintlib: libc-${TARGET}.ok
	cd ${FOLDER_MINTLIB} && $(MAKE) OUT= clean $(OUT)
	cd ${FOLDER_MINTLIB} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		$(MAKE) OUT= toolprefix=${TARGET}- SHELL=$(BASH) CROSS=yes WITH_020_LIB=no WITH_V4E_LIB=no CC="${TARGET}-gcc" HOST_CC="$(CC)" $(OUT)
	cd ${FOLDER_MINTLIB} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		$(MAKE) OUT= toolprefix=${TARGET}- SHELL=$(BASH) CROSS=yes WITH_020_LIB=no WITH_V4E_LIB=no install $(OUT)

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
	rm -rf $@ ${FOLDER_GCC}-${CPU}-cross-final
	mkdir -p ${FOLDER_GCC}-${CPU}-cross-final
	cd ${FOLDER_GCC}-${CPU}-cross-final && \
	export PATH=${INSTALL_DIR}/bin:$$PATH CFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" CXXFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" && \
	../${FOLDER_GCC}/configure \
		--prefix=${INSTALL_DIR} \
		--target=${TARGET} \
		--with-sysroot=${INSTALL_DIR}/${TARGET} \
		--disable-nls \
		--enable-languages="c,c++" \
		--disable-libstdcxx-pch \
		--disable-libgomp \
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
	rm -rf $@ ${FOLDER_BINUTILS}-${CPU}-atari
	mkdir -p ${FOLDER_BINUTILS}-${CPU}-atari
	cd ${FOLDER_BINUTILS}-${CPU}-atari && \
	export PATH=${INSTALL_DIR}/bin:$$PATH CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" && \
	../${FOLDER_BINUTILS}/configure --target=${TARGET} --host=${TARGET} --disable-nls --prefix=/usr \
					--disable-gdb --disable-libdecnumber --disable-readline --disable-sim && \
	$(MAKE) -j3 $(OUT) && \
	$(MAKE) install DESTDIR=${PWD}/binary-package/${CPU}/binutils-${VERSION_BINUTILS}	# make install-strip doesn't work properly
	touch $@

binutils-atari: check-target-gcc binutils-${VERSION_BINUTILS}-${CPU}-atari.ok

gcc-${VERSION_GCC}-${CPU}-atari.ok: gcc-${TARGET}.ok disable_ftw.sh
	rm -rf $@ ${FOLDER_GCC}-${CPU}-atari
	mkdir -p ${FOLDER_GCC}-${CPU}-atari
	cd ${FOLDER_GCC}-${CPU}-atari && \
	../disable_ftw.sh && \
	export PATH=${INSTALL_DIR}/bin:$$PATH CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" && \
	../${FOLDER_GCC}/configure \
		--prefix=/usr \
		--host=${TARGET} \
		--target=${TARGET} \
		--disable-nls \
		--enable-languages="c,c++" \
		--disable-libstdcxx-pch \
		--disable-libgomp \
		--with-cpu=${CPU} && \
	$(MAKE) -j3 $(OUT) && \
	$(MAKE) install-strip DESTDIR=${PWD}/binary-package/${CPU}/gcc-${VERSION_GCC} $(OUT)
	touch $@

gcc-atari: check-target-gcc gcc-${VERSION_GCC}-${CPU}-atari.ok

# Cleaning

clean-source:
	rm -rf ${FOLDER_BINUTILS}
	rm -rf ${FOLDER_GCC}
	rm -rf ${FOLDER_MINTLIB}
	rm -rf pml-${VERSION_PML}
	rm -rf mintbin-CVS-${VERSION_MINTBIN}
	rm -f *.ok
	rm -f *~

clean-cross:
	rm -rf ${FOLDER_BINUTILS}-${CPU}-cross
	rm -rf ${FOLDER_GCC}-${CPU}-cross-preliminary
	rm -rf ${FOLDER_GCC}-${CPU}-cross-final

pack-atari:
	for dir in binutils-${VERSION_BINUTILS} gcc-${VERSION_GCC}; \
	do \
		cd ${PWD}/binary-package/${CPU}/$$dir && tar cjf ../$$dir-${CPU}mint.tar.bz2 usr && cd ..; \
	done

strip-atari:
	PATH=${INSTALL_DIR}/bin:$$PATH find ${PWD}/binary-package -type f -perm -a=x -exec ${TARGET}-strip -s {} \;
	PATH=${INSTALL_DIR}/bin:$$PATH find ${PWD}/binary-package -type f -name '*.a' -exec ${TARGET}-strip -S -X -w -N '.L[0-9]*' {} \;

clean-atari:
	rm -rf ${FOLDER_BINUTILS}-${CPU}-atari
	rm -rf ${FOLDER_GCC}-${CPU}-atari
	rm -rf binary-package
