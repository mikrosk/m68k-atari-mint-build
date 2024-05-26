# Atari cross- and native-binutils/gcc toolchain build Makefile
# Miro Kropacek aka MiKRO / Mystic Bytes
# miro.kropacek@gmail.com
# version 5.0.0 (2024/05/22)

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
VERSION_GCC			= 13.2.0

SH      := $(shell which sh)
BASH    := $(shell which bash)
URLGET	:= $(shell if [ -x "`command -v wget`" ]; then echo "wget -q -O -"; else echo "curl -s -L -o -"; fi)
#CPUS	:= $(getconf _NPROCESSORS_ONLN)
CPUS	:= 12

.PHONY: default help download depack clean \
	clean-all       clean-all-skip-native       clean-native           all       all-skip-native       all-native \
	clean-m68000    clean-m68000-skip-native    clean-m68000-native    m68000    m68000-skip-native    m68000-native \
	clean-m68020-60 clean-m68020-60-skip-native clean-m68020-60-native m68020-60 m68020-60-skip-native m68020-60-native \
	clean-5475      clean-5475-skip-native      clean-5475-native      5475      5475-skip-native      5475-native

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

# binutils

binutils-${VERSION_BINUTILS}-${CPU}-cross.ok: downloads/${FOLDER_BINUTILS}.ok
	rm -rf $@ ${FOLDER_BINUTILS}-${CPU}-cross
	mkdir -p ${FOLDER_BINUTILS}-${CPU}-cross
	cd ${FOLDER_BINUTILS}-${CPU}-cross && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../downloads/${FOLDER_BINUTILS}/configure --target=${TARGET} --prefix=${INSTALL_DIR} --disable-nls --disable-werror \
					--disable-gdb --disable-libdecnumber --disable-readline --disable-sim && \
	$(MAKE) V=1 -j$(CPUS) && \
	$(MAKE) install-strip
	touch $@

binutils: binutils-${VERSION_BINUTILS}-${CPU}-cross.ok

# Preliminary build

gcc-${VERSION_GCC}-${CPU}-cross-preliminary.ok: downloads/${FOLDER_GCC}.ok
	rm -rf $@ ${FOLDER_GCC}-${CPU}-cross-preliminary
	mkdir -p ${FOLDER_GCC}-${CPU}-cross-preliminary
	cd ${FOLDER_GCC}-${CPU}-cross-preliminary && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../downloads/${FOLDER_GCC}/configure \
		--prefix=${INSTALL_DIR} \
		--target=${TARGET} \
		--with-sysroot=${INSTALL_DIR}/${TARGET}/sys-root \
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
		--disable-libstdcxx-pch \
		--disable-lto \
		--with-libstdcxx-zoneinfo=no \
		--disable-libcc1 \
		--disable-fixincludes \
		--enable-version-specific-runtime-libs && \
	$(MAKE) -j$(CPUS) all-gcc all-target-libgcc && \
	$(MAKE) install-gcc install-target-libgcc
	touch $@

gcc-preliminary: gcc-${VERSION_GCC}-${CPU}-cross-preliminary.ok

# Libraries

mintlib: downloads/${FOLDER_MINTLIB}.ok
	cd downloads/${FOLDER_MINTLIB} && $(MAKE) clean
	cd downloads/${FOLDER_MINTLIB} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		$(MAKE) CROSS_TOOL=${TARGET} SHELL=$(BASH) WITH_020_LIB=yes WITH_V4E_LIB=yes WITH_DEBUG_LIB=no
	cd downloads/${FOLDER_MINTLIB} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		$(MAKE) CROSS_TOOL=${TARGET} SHELL=$(BASH) WITH_020_LIB=yes WITH_V4E_LIB=yes WITH_DEBUG_LIB=no install

mintbin: downloads/${FOLDER_MINTBIN}.ok
	-cd downloads/${FOLDER_MINTBIN} && $(MAKE) distclean
	cd downloads/${FOLDER_MINTBIN} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		./configure --target=${TARGET} --prefix=${INSTALL_DIR} --disable-nls
	cd downloads/${FOLDER_MINTBIN} && $(MAKE)
	cd downloads/${FOLDER_MINTBIN} && $(MAKE) install

fdlibm: downloads/${FOLDER_FDLIBM}.ok
	-cd downloads/${FOLDER_FDLIBM} && $(MAKE) distclean
	cd downloads/${FOLDER_FDLIBM} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		unset CC CXX AR RANLIB LD && \
		./configure --host=${TARGET} --prefix=/usr
	cd downloads/${FOLDER_FDLIBM} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		$(MAKE)
	cd downloads/${FOLDER_FDLIBM} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		$(MAKE) install

# Full build

gcc-${VERSION_GCC}-${CPU}-cross-final.ok: ${INSTALL_DIR}/${TARGET}/sys-root/usr/lib/libc.a ${INSTALL_DIR}/${TARGET}/sys-root/usr/lib/libm.a
	rm -rf $@ ${FOLDER_GCC}-${CPU}-cross-final
	mkdir -p ${FOLDER_GCC}-${CPU}-cross-final
	cd ${FOLDER_GCC}-${CPU}-cross-final && \
	export PATH=${INSTALL_DIR}/bin:$$PATH CFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" CXXFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" && \
	../downloads/${FOLDER_GCC}/configure \
		--prefix=${INSTALL_DIR} \
		--target=${TARGET} \
		--with-sysroot=${INSTALL_DIR}/${TARGET}/sys-root \
		--disable-nls \
		--enable-lto \
		--enable-languages="c,c++,lto" \
		--disable-libstdcxx-pch \
		--disable-threads \
		--disable-libgomp \
		--disable-sjlj-exceptions \
		--with-cpu=${CPU} \
		--with-libstdcxx-zoneinfo=no \
		--disable-libcc1 \
		--disable-fixincludes \
		--enable-version-specific-runtime-libs && \
	$(MAKE) -j$(CPUS) && \
	$(MAKE) install-strip
	cd "${INSTALL_DIR}/lib/gcc/${TARGET}/${VERSION_GCC}/include-fixed" && \
	for f in $$(find . -type f); \
	do \
		case "$$f" in \
			./README | ./limits.h | ./syslimits.h) ;; \
			*) echo "Removing fixed include file $$f"; rm "$$f" ;; \
		esac \
	done && \
	for d in $$(find . -depth -type d); \
	do \
		test "$$d" = "." || rmdir "$$d"; \
	done
	touch $@

gcc: gcc-${VERSION_GCC}-${CPU}-cross-final.ok

# Atari building

check-target-gcc:
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	multi_dir=`${TARGET}-gcc -${OPT} -print-multi-directory` && \
	if [ $$multi_dir != "." ]; then echo "\n${TARGET}-gcc is not configured for default ${CPU} output\n"; exit 1; fi

binutils-${VERSION_BINUTILS}-${CPU}-atari.ok: downloads/${FOLDER_BINUTILS}.ok
	rm -rf $@ ${FOLDER_BINUTILS}-${CPU}-atari
	mkdir -p ${FOLDER_BINUTILS}-${CPU}-atari
	cd ${FOLDER_BINUTILS}-${CPU}-atari && \
	export PATH=${INSTALL_DIR}/bin:$$PATH CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" && \
	../downloads/${FOLDER_BINUTILS}/configure --target=${TARGET} --host=${TARGET} --disable-nls --prefix=/usr \
		--disable-gdb --disable-libdecnumber --disable-readline --disable-sim && \
	$(MAKE) -j$(CPUS) V=1 && \
	$(MAKE) install-strip DESTDIR=${PWD}/binary-package/${CPU}/binutils-${VERSION_BINUTILS}
	touch $@

binutils-atari: check-target-gcc binutils-${VERSION_BINUTILS}-${CPU}-atari.ok

gcc-${VERSION_GCC}-${CPU}-atari.ok: downloads/${FOLDER_GCC}.ok
	rm -rf $@ ${FOLDER_GCC}-${CPU}-atari
	mkdir -p ${FOLDER_GCC}-${CPU}-atari
	cd ${FOLDER_GCC}-${CPU}-atari && \
	export PATH=${INSTALL_DIR}/bin:$$PATH CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" && \
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

gcc-atari: check-target-gcc gcc-${VERSION_GCC}-${CPU}-atari.ok

# Cleaning

clean-source:
	rm -rf ${FOLDERS}
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

clean-atari:
	rm -rf ${FOLDER_BINUTILS}-${CPU}-atari
	rm -rf ${FOLDER_GCC}-${CPU}-atari
	rm -rf binary-package
