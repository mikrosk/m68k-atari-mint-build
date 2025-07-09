# Atari cross- and native-binutils/gcc toolchain build Makefile
# Miro Kropacek aka MiKRO / Mystic Bytes
# miro.kropacek@gmail.com
# version 5.0.0 (2024/06/05)

# please note you need the bash shell for correct compilation of mintlib.

REPOSITORY_BINUTILS	= m68k-atari-mint-binutils-gdb
REPOSITORY_GCC		= m68k-atari-mint-gcc
REPOSITORY_MINTLIB	= mintlib
REPOSITORY_MINTBIN	= mintbin
REPOSITORY_FDLIBM	= fdlibm

BRANCH_BINUTILS		= binutils-2_42-mintelf
BRANCH_GCC			= gcc-13-mintelf
BRANCH_MINTLIB		= master
BRANCH_MINTBIN		= master
BRANCH_FDLIBM		= master

GITHUB_URL_BINUTILS	= https://github.com/freemint/${REPOSITORY_BINUTILS}/archive/refs/heads/${BRANCH_BINUTILS}.tar.gz
GITHUB_URL_GCC		= https://github.com/freemint/${REPOSITORY_GCC}/archive/refs/heads/${BRANCH_GCC}.tar.gz
GITHUB_URL_MINTLIB	= https://github.com/freemint/${REPOSITORY_MINTLIB}/archive/refs/heads/${BRANCH_MINTLIB}.tar.gz
GITHUB_URL_MINTBIN	= https://github.com/freemint/${REPOSITORY_MINTBIN}/archive/refs/heads/${BRANCH_MINTBIN}.tar.gz
GITHUB_URL_FDLIBM	= https://github.com/freemint/${REPOSITORY_FDLIBM}/archive/refs/heads/${BRANCH_FDLIBM}.tar.gz

FOLDER_BINUTILS		= ${REPOSITORY_BINUTILS}-${BRANCH_BINUTILS}
FOLDER_GCC			= ${REPOSITORY_GCC}-${BRANCH_GCC}
FOLDER_MINTLIB		= ${REPOSITORY_MINTLIB}-${BRANCH_MINTLIB}
FOLDER_MINTBIN		= ${REPOSITORY_MINTBIN}-${BRANCH_MINTBIN}
FOLDER_FDLIBM		= ${REPOSITORY_FDLIBM}-${BRANCH_FDLIBM}

ARCHIVE_BINUTILS	= ${REPOSITORY_BINUTILS}-${BRANCH_BINUTILS}.tar.gz
ARCHIVE_GCC			= ${REPOSITORY_GCC}-${BRANCH_GCC}.tar.gz
ARCHIVE_MINTLIB		= ${REPOSITORY_MINTLIB}-${BRANCH_MINTLIB}.tar.gz
ARCHIVE_MINTBIN		= ${REPOSITORY_MINTBIN}-${BRANCH_MINTBIN}.tar.gz
ARCHIVE_FDLIBM		= ${REPOSITORY_FDLIBM}-${BRANCH_FDLIBM}.tar.gz

DOWNLOADS 			= downloads/${ARCHIVE_BINUTILS} downloads/${ARCHIVE_GCC} downloads/${ARCHIVE_MINTLIB} downloads/${ARCHIVE_MINTBIN} downloads/${ARCHIVE_FDLIBM}
FOLDERS 			= downloads/${FOLDER_BINUTILS}.ok downloads/${FOLDER_GCC}.ok downloads/${FOLDER_MINTLIB}.ok downloads/${FOLDER_MINTBIN}.ok downloads/${FOLDER_FDLIBM}.ok

VERSION_BINUTILS	= 2.42
VERSION_GCC			= 13.4.0

SH      := $(shell which sh)
BASH    := $(shell which bash)
URLGET	:= $(shell if [ -x "`command -v wget`" ]; then echo "wget -q -O -"; else echo "curl -s -L -o -"; fi)
#CPUS	:= $(getconf _NPROCESSORS_ONLN)
CPUS	:= 12

.PHONY: default help download depack clean \
	clean-all       clean-all-skip-native       clean-all-native       all       all-skip-native       all-native \
	clean-m68000    clean-m68000-skip-native    clean-m68000-native    m68000    m68000-skip-native    m68000-native \
	clean-m68020-60 clean-m68020-60-skip-native clean-m68020-60-native m68020-60 m68020-60-skip-native m68020-60-native \
	clean-5475      clean-5475-skip-native      clean-5475-native      5475      5475-skip-native      5475-native \
	binutils-preliminary gcc-preliminary mintlib-preliminary fdlibm-preliminary \
	binutils gcc mintlib fdlibm mintbin \
	binutils-atari gcc-atari mintbin-atari \
	clean-source clean-preliminary clean-cross clean-atari strip-atari pack-atari check-target-gcc

default: m68000-skip-native

help: ./build.sh
	@echo "Makefile targets :"
	@echo "    download"
	@echo "    clean (same as clean-all)"
	@echo "    [clean-]all       / [clean-]all[-skip]-native"
	@echo "    [clean-]m68000    / [clean-]m68000[-skip]-native"
	@echo "    [clean-]m68020-60 / [clean-]m68020-60[-skip]-native"
	@echo "    [clean-]5475      / [clean-]5475[-skip]-native"

# "real" targets

all: ./build.sh download depack
	MAKE=$(MAKE) $(SH) $< --all

all-skip-native: ./build.sh download depack
	MAKE=$(MAKE) $(SH) $< --all --skip-native

all-native: ./build.sh download depack
	MAKE=$(MAKE) $(SH) $< --all --native-only

m68000: ./build.sh download depack
	MAKE=$(MAKE) $(SH) $< m68000

m68000-skip-native: ./build.sh download depack
	MAKE=$(MAKE) $(SH) $< --skip-native m68000

m68000-native: ./build.sh download depack
	MAKE=$(MAKE) $(SH) $< --native-only m68000

m68020-60: ./build.sh download depack
	MAKE=$(MAKE) $(SH) $< m68020-60

m68020-60-skip-native: ./build.sh download depack
	MAKE=$(MAKE) $(SH) $< --skip-native m68020-60

m68020-60-native: ./build.sh download depack
	MAKE=$(MAKE) $(SH) $< --native-only m68020-60

5475: ./build.sh download depack
	MAKE=$(MAKE) $(SH) $< 5475

5475-skip-native: ./build.sh download depack
	MAKE=$(MAKE) $(SH) $< --skip-native 5475

5475-native: ./build.sh download depack
	MAKE=$(MAKE) $(SH) $< --native-only 5475

clean: ./build.sh
	MAKE=$(MAKE) $(SH) $< --clean --all
	rm -f *~

clean-all: ./build.sh clean-source
	MAKE=$(MAKE) $(SH) $< --clean --all

clean-all-skip-native: ./build.sh
	MAKE=$(MAKE) $(SH) $< --clean --all --skip-native

clean-all-native: ./build.sh
	MAKE=$(MAKE) $(SH) $< --clean --all --native-only

clean-m68000: ./build.sh
	MAKE=$(MAKE) $(SH) $< --clean m68000

clean-m68000-skip-native: ./build.sh
	MAKE=$(MAKE) $(SH) $< --clean --skip-native m68000

clean-m68000-native: ./build.sh
	MAKE=$(MAKE) $(SH) $< --clean --native-only m68000

clean-m68020-60: ./build.sh
	MAKE=$(MAKE) $(SH) $< --clean m68020-60

clean-m68020-60-skip-native: ./build.sh
	MAKE=$(MAKE) $(SH) $< --clean --skip-native m68020-60

clean-m68020-60-native: ./build.sh
	MAKE=$(MAKE) $(SH) $< --clean --native-only m68020-60

clean-5475: ./build.sh
	MAKE=$(MAKE) $(SH) $< --clean 5475

clean-5475-skip-native: ./build.sh
	MAKE=$(MAKE) $(SH) $< --clean --skip-native 5475

clean-5475-native: ./build.sh
	MAKE=$(MAKE) $(SH) $< --clean --native-only 5475

download: $(DOWNLOADS)

depack: $(FOLDERS)

# Downloading

downloads/${ARCHIVE_BINUTILS}:
	mkdir -p downloads
	$(URLGET) ${GITHUB_URL_BINUTILS} > "$@"

downloads/${ARCHIVE_GCC}:
	mkdir -p downloads
	$(URLGET) ${GITHUB_URL_GCC} > "$@"

downloads/${ARCHIVE_MINTLIB}:
	mkdir -p downloads
	$(URLGET) ${GITHUB_URL_MINTLIB} > "$@"

downloads/${ARCHIVE_MINTBIN}:
	mkdir -p downloads
	$(URLGET) ${GITHUB_URL_MINTBIN} > "$@"

downloads/${ARCHIVE_FDLIBM}:
	mkdir -p downloads
	$(URLGET) ${GITHUB_URL_FDLIBM} > "$@"

# Depacking and patching

downloads/${FOLDER_BINUTILS}.ok: downloads/${ARCHIVE_BINUTILS}
	rm -rf downloads/${FOLDER_BINUTILS}
	cd downloads && tar xzf ${ARCHIVE_BINUTILS}
	touch "$@"

downloads/${FOLDER_GCC}.ok: downloads/${ARCHIVE_GCC} gcc-atari.patch
	rm -rf downloads/${FOLDER_GCC}
	cd downloads && tar xzf ${ARCHIVE_GCC}
	cd downloads/${FOLDER_GCC} && contrib/download_prerequisites
	cd downloads/${FOLDER_GCC} && patch -p1 < ../../gcc-atari.patch
	touch "$@"

downloads/${FOLDER_MINTLIB}.ok: downloads/${ARCHIVE_MINTLIB}
	rm -rf downloads/${FOLDER_MINTLIB}
	cd downloads && tar xzf ${ARCHIVE_MINTLIB}
	touch "$@"

downloads/${FOLDER_MINTBIN}.ok: downloads/${ARCHIVE_MINTBIN}
	rm -rf downloads/${FOLDER_MINTBIN}
	cd downloads && tar xzf ${ARCHIVE_MINTBIN}
	touch "$@"

downloads/${FOLDER_FDLIBM}.ok: downloads/${ARCHIVE_FDLIBM}
	rm -rf downloads/${FOLDER_FDLIBM}
	cd downloads && tar xzf ${ARCHIVE_FDLIBM}
	touch "$@"

# binutils (preliminary/full)

binutils-${VERSION_BINUTILS}-cross.ok: downloads/${FOLDER_BINUTILS}.ok
	rm -rf $@ ${FOLDER_BINUTILS}-cross
	mkdir -p ${FOLDER_BINUTILS}-cross
	cd ${FOLDER_BINUTILS}-cross && \
	../downloads/${FOLDER_BINUTILS}/configure --target=${TARGET} --prefix=${PREFIX} --disable-nls --disable-werror \
		--disable-gdb --disable-libdecnumber --disable-readline --disable-sim && \
	$(MAKE) V=1 -j$(CPUS)
	touch $@

binutils-${VERSION_BINUTILS}-cross-preliminary.ok binutils-${VERSION_BINUTILS}-cross-${CPU}.ok: binutils-${VERSION_BINUTILS}-cross.ok
	cd ${FOLDER_BINUTILS}-cross && \
	$(MAKE) install-strip
	touch $@

binutils-preliminary: binutils-${VERSION_BINUTILS}-cross-preliminary.ok
binutils: binutils-${VERSION_BINUTILS}-cross-${CPU}.ok

# gcc (preliminary)

gcc-${VERSION_GCC}-cross-stage1.ok: downloads/${FOLDER_GCC}.ok
	rm -rf $@ ${FOLDER_GCC}-cross-stage1
	mkdir -p ${FOLDER_GCC}-cross-stage1
	cd ${FOLDER_GCC}-cross-stage1 && \
	../downloads/${FOLDER_GCC}/configure \
		--prefix=${PREFIX} \
		--target=${TARGET} \
		--with-sysroot \
		--disable-nls \
		--disable-shared \
		--without-headers \
		--with-newlib \
		--disable-decimal-float \
		--disable-libgomp \
		--disable-libssp \
		--disable-libatomic \
		--disable-libquadmath \
		--disable-threads \
		--disable-tls \
		--enable-languages=c \
		--disable-libvtv \
		--disable-libstdcxx \
		--disable-lto \
		--disable-libcc1 \
		--disable-fixincludes \
		--enable-version-specific-runtime-libs && \
	$(MAKE) -j$(CPUS) all-gcc all-target-libgcc && \
	$(MAKE) install-gcc install-target-libgcc
	touch $@

gcc-preliminary: gcc-${VERSION_GCC}-cross-stage1.ok

# Libraries (preliminary/full)

mintlib-build.ok: downloads/${FOLDER_MINTLIB}.ok
	cd downloads/${FOLDER_MINTLIB} && $(MAKE) clean > /dev/null
	cd downloads/${FOLDER_MINTLIB} && \
		$(MAKE) CROSS_TOOL=${TARGET} SHELL=$(BASH) WITH_020_LIB=yes WITH_V4E_LIB=yes WITH_DEBUG_LIB=no
	touch $@

mintlib-preliminary.ok mintlib-${CPU}.ok: mintlib-build.ok
	cd downloads/${FOLDER_MINTLIB} && \
		$(MAKE) CROSS_TOOL=${TARGET} SHELL=$(BASH) WITH_020_LIB=yes WITH_V4E_LIB=yes WITH_DEBUG_LIB=no install
	touch $@

mintlib-preliminary: mintlib-preliminary.ok
mintlib: mintlib-${CPU}.ok

fdlibm-build.ok: downloads/${FOLDER_FDLIBM}.ok
	rm -rf $@ ${FOLDER_FDLIBM}
	mkdir -p ${FOLDER_FDLIBM}
	cd ${FOLDER_FDLIBM} && \
		../downloads/${FOLDER_FDLIBM}/configure --host=${TARGET} --prefix=/usr && \
	$(MAKE)
	touch $@

fdlibm-preliminary.ok fdlibm-${CPU}.ok: fdlibm-build.ok
	cd ${FOLDER_FDLIBM} && $(MAKE) install
	touch $@

fdlibm-preliminary: fdlibm-preliminary.ok
fdlibm: fdlibm-${CPU}.ok

# gcc (full)

gcc-${VERSION_GCC}-cross-stage2-${CPU}.ok: ${INSTALL_DIR}/${TARGET}/sys-root/usr/lib/libc.a ${INSTALL_DIR}/${TARGET}/sys-root/usr/lib/libm.a
	rm -rf $@ ${FOLDER_GCC}-cross-stage2-${CPU}
	mkdir -p ${FOLDER_GCC}-cross-stage2-${CPU}
	cd ${FOLDER_GCC}-cross-stage2-${CPU} && \
	CFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" CXXFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" \
	../downloads/${FOLDER_GCC}/configure \
		--prefix=${INSTALL_DIR} \
		--target=${TARGET} \
		--with-sysroot \
		--disable-nls \
		--enable-lto \
		--enable-languages="c,c++,lto" \
		--disable-libstdcxx-pch \
		--disable-threads \
		--disable-tls \
		--disable-libgomp \
		--disable-sjlj-exceptions \
		--with-cpu=${CPU} \
		--with-libstdcxx-zoneinfo=no \
		--disable-libcc1 \
		--disable-fixincludes \
		--enable-version-specific-runtime-libs && \
	$(MAKE) -j$(CPUS) && \
	$(MAKE) install-strip
	touch $@

gcc: gcc-${VERSION_GCC}-cross-stage2-${CPU}.ok

# mintbin

mintbin-cross.ok: downloads/${FOLDER_MINTBIN}.ok
	rm -rf $@ ${FOLDER_MINTBIN}-cross
	mkdir -p ${FOLDER_MINTBIN}-cross
	cd ${FOLDER_MINTBIN}-cross && \
		../downloads/${FOLDER_MINTBIN}/configure --target=${TARGET} --prefix=${PREFIX} --disable-nls && \
	$(MAKE)
	touch $@

mintbin-cross-${CPU}.ok: mintbin-cross.ok
	cd ${FOLDER_MINTBIN}-cross && \
	$(MAKE) install-strip
	touch $@

mintbin: mintbin-cross-${CPU}.ok

# Atari building

check-target-gcc:
	multi_dir=`${TARGET}-gcc -${OPT} -print-multi-directory` && \
	if [ $$multi_dir != "." ]; then echo "\n${TARGET}-gcc is not configured for default ${CPU} output\n"; exit 1; fi

binutils-${VERSION_BINUTILS}-atari-${CPU}.ok: downloads/${FOLDER_BINUTILS}.ok
	rm -rf $@ ${FOLDER_BINUTILS}-atari-${CPU}
	mkdir -p ${FOLDER_BINUTILS}-atari-${CPU}
	cd ${FOLDER_BINUTILS}-atari-${CPU} && \
	CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" \
	../downloads/${FOLDER_BINUTILS}/configure --target=${TARGET} --host=${TARGET} --disable-nls --prefix=/usr \
		--disable-gdb --disable-libdecnumber --disable-readline --disable-sim && \
	$(MAKE) -j$(CPUS) V=1 && \
	$(MAKE) install-strip DESTDIR=${PWD}/binary-package/${CPU}/binutils-${VERSION_BINUTILS}
	touch $@

binutils-atari: check-target-gcc binutils-${VERSION_BINUTILS}-atari-${CPU}.ok

gcc-${VERSION_GCC}-atari-${CPU}.ok: downloads/${FOLDER_GCC}.ok
	rm -rf $@ ${FOLDER_GCC}-atari-${CPU}
	mkdir -p ${FOLDER_GCC}-atari-${CPU}
	cd ${FOLDER_GCC}-atari-${CPU} && \
	CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" \
	../downloads/${FOLDER_GCC}/configure \
		--prefix=/usr \
		--host=${TARGET} \
		--target=${TARGET} \
		--with-sysroot="/" \
		--with-build-sysroot="${INSTALL_DIR}/${TARGET}/sys-root" \
		--disable-nls \
		--enable-lto \
		--enable-languages="c,c++,lto" \
		--disable-libstdcxx-pch \
		--disable-threads \
		--disable-tls \
		--disable-libgomp \
		--disable-sjlj-exceptions \
		--with-cpu=${CPU} \
		--with-libstdcxx-zoneinfo=no \
		--disable-libcc1 \
		--disable-fixincludes \
		--enable-version-specific-runtime-libs && \
	$(MAKE) -j$(CPUS) && \
	$(MAKE) install-strip DESTDIR=${PWD}/binary-package/${CPU}/gcc-${VERSION_GCC}
	touch $@

gcc-atari: check-target-gcc gcc-${VERSION_GCC}-atari-${CPU}.ok

mintbin-atari-${CPU}.ok: downloads/${FOLDER_MINTBIN}.ok
	rm -rf $@ ${FOLDER_MINTBIN}-atari-${CPU}
	mkdir -p ${FOLDER_MINTBIN}-atari-${CPU}
	cd ${FOLDER_MINTBIN}-atari-${CPU} && \
	CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" \
	../downloads/${FOLDER_MINTBIN}/configure --target=${TARGET} --host=${TARGET} --disable-nls --prefix=/usr && \
	$(MAKE) && \
	$(MAKE) install-strip DESTDIR=${PWD}/binary-package/${CPU}/mintbin
	touch $@

mintbin-atari: check-target-gcc mintbin-atari-${CPU}.ok

pack-atari:
	for dir in binutils-${VERSION_BINUTILS} gcc-${VERSION_GCC} mintbin; \
	do \
		cd ${PWD}/binary-package/${CPU}/$$dir && tar cjf ../$$dir-${CPU}mint.tar.bz2 usr && cd ..; \
	done

strip-atari:
	for f in cc1 cc1plus; \
	do \
		PATH=${INSTALL_DIR}/bin:$$PATH ${TARGET}-stack --fix=1024k "${PWD}/binary-package/${CPU}/gcc-${VERSION_GCC}/usr/libexec/gcc/${TARGET}/${VERSION_GCC}/$$f"; \
	done
	PATH=${INSTALL_DIR}/bin:$$PATH ${TARGET}-stack --fix=192k "${PWD}/binary-package/${CPU}/gcc-${VERSION_GCC}/usr/libexec/gcc/${TARGET}/${VERSION_GCC}/collect2"
	for f in c++ cpp g++ gcc ${TARGET}-c++ ${TARGET}-g++ ${TARGET}-gcc ${TARGET}-gcc-${VERSION_GCC}; \
	do \
		PATH=${INSTALL_DIR}/bin:$$PATH ${TARGET}-stack --fix=192k "${PWD}/binary-package/${CPU}/gcc-${VERSION_GCC}/usr/bin/$$f"; \
	done
	PATH=${INSTALL_DIR}/bin:$$PATH find "${PWD}/binary-package/${CPU}" -type f -perm -a=x -exec ${TARGET}-strip -s {} \;
	PATH=${INSTALL_DIR}/bin:$$PATH find "${PWD}/binary-package/${CPU}" -type f -name '*.a' -exec ${TARGET}-strip -S -X -w -N '.L[0-9]*' {} \;

# Cleaning

clean-source:
	rm -rf ${FOLDERS}
	rm -f *~

# this removes build folders, too (except mintlib; that one uses explicit make clean to avoid repeated depacking)
clean-preliminary:
	rm -rf ${FOLDER_BINUTILS}-cross   binutils-${VERSION_BINUTILS}-cross.ok binutils-${VERSION_BINUTILS}-cross-preliminary.ok
	rm -rf ${FOLDER_GCC}-cross-stage1 gcc-${VERSION_GCC}-cross-stage1.ok
	rm -f                             mintlib-build.ok                      mintlib-preliminary.ok
	rm -rf ${FOLDER_FDLIBM}           fdlibm-build.ok                       fdlibm-preliminary.ok
	rm -rf ${DESTDIR}

clean-cross:
	# build folder is shared with 'preliminary'
	rm -f                                    binutils-${VERSION_BINUTILS}-cross-${CPU}.ok
	# build folder is not shared
	rm -rf ${FOLDER_GCC}-cross-stage2-${CPU} gcc-${VERSION_GCC}-cross-stage2-${CPU}.ok
	# build folder is shared with 'preliminary'
	rm -f                                    mintlib-${CPU}.ok
	# build folder is shared with 'preliminary'
	rm -f                                    fdlibm-${CPU}.ok
	# build folder is shared only in 'cross'
	rm -rf ${FOLDER_MINTBIN}-cross           mintbin-cross.ok mintbin-cross-${CPU}.ok

clean-atari:
	rm -rf ${FOLDER_BINUTILS}-atari-${CPU} binutils-${VERSION_BINUTILS}-atari-${CPU}.ok
	rm -rf ${FOLDER_GCC}-atari-${CPU}      gcc-${VERSION_GCC}-atari-${CPU}.ok
	rm -rf ${FOLDER_MINTBIN}-atari-${CPU}  mintbin-atari-${CPU}.ok
	rm -rf binary-package
