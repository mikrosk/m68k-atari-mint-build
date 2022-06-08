# Atari cross- and native-binutils/gcc toolchain build Makefile
# Miro Kropacek aka MiKRO / Mystic Bytes
# miro.kropacek@gmail.com
# version 4.3.2 (2022/06/08)

# please note you need the bash shell for correct compilation of mintlib.

REPOSITORY_BINUTILS	= m68k-atari-mint-binutils-gdb
REPOSITORY_GCC		= m68k-atari-mint-gcc
REPOSITORY_MINTLIB	= mintlib
REPOSITORY_MINTBIN	= mintbin
REPOSITORY_FDLIBM	= fdlibm

BRANCH_BINUTILS		= binutils-2_30-mint
BRANCH_GCC		= gcc-7-mint
BRANCH_MINTLIB		= master
BRANCH_MINTBIN		= master
BRANCH_FDLIBM		= master

GITHUB_URL_BINUTILS	= https://github.com/freemint/${REPOSITORY_BINUTILS}/archive/refs/heads/${BRANCH_BINUTILS}.tar.gz
GITHUB_URL_GCC		= https://github.com/freemint/${REPOSITORY_GCC}/archive/refs/heads/${BRANCH_GCC}.tar.gz
GITHUB_URL_MINTLIB	= https://github.com/freemint/${REPOSITORY_MINTLIB}/archive/refs/heads/${BRANCH_MINTLIB}.tar.gz
GITHUB_URL_MINTBIN	= https://github.com/freemint/${REPOSITORY_MINTBIN}/archive/refs/heads/${BRANCH_MINTBIN}.tar.gz
GITHUB_URL_FDLIBM	= https://github.com/freemint/${REPOSITORY_FDLIBM}/archive/refs/heads/${BRANCH_FDLIBM}.tar.gz

FOLDER_BINUTILS		= ${REPOSITORY_BINUTILS}-${BRANCH_BINUTILS}
FOLDER_GCC		= ${REPOSITORY_GCC}-${BRANCH_GCC}
FOLDER_MINTLIB		= ${REPOSITORY_MINTLIB}-${BRANCH_MINTLIB}
FOLDER_MINTBIN		= ${REPOSITORY_MINTBIN}-${BRANCH_MINTBIN}
FOLDER_FDLIBM		= ${REPOSITORY_FDLIBM}-${BRANCH_FDLIBM}

VERSION_BINUTILS	= 2.30
VERSION_GCC		= 7.5.0

SH      := $(shell which sh)
BASH    := $(shell which bash)
URLGET	:= $(shell if [ -x "`command -v wget`" ]; then echo "wget -q -O -"; else echo "curl -s -L -o -"; fi)
UNTAR	:= tar xzf -

# set to something like "> /dev/null" or ">> /tmp/mint-build.log"
# to redirect compilation standard output
OUT =

DOWNLOADS = binutils-${VERSION_BINUTILS}.ok gcc-${VERSION_GCC}.ok mintlib.ok mintbin.ok fdlibm.ok

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

libc-m68k-atari-mint.ok: fdlibm.ok mintbin.ok mintlib.ok
	# target specific patches here
	touch $@

# Downloading, depacking and patching

binutils-${VERSION_BINUTILS}.ok:
	rm -rf $@ ${FOLDER_BINUTILS}
	$(URLGET) ${GITHUB_URL_BINUTILS} | $(UNTAR) > /dev/null
	touch $@

gcc-${VERSION_GCC}.ok: gmp.patch download_prerequisites.patch
	rm -rf $@ ${FOLDER_GCC}
	$(URLGET) ${GITHUB_URL_GCC} | $(UNTAR) > /dev/null
	cd ${FOLDER_GCC} && patch -p1 < ../download_prerequisites.patch
	cd ${FOLDER_GCC} && contrib/download_prerequisites
	cd ${FOLDER_GCC} && patch -p1 < ../gmp.patch
	touch $@

mintlib.ok:
	rm -rf $@ ${FOLDER_MINTLIB}
	$(URLGET) ${GITHUB_URL_MINTLIB} | $(UNTAR) > /dev/null
	touch $@

mintbin.ok:
	rm -rf $@ ${FOLDER_MINTBIN}
	$(URLGET) ${GITHUB_URL_MINTBIN} | $(UNTAR) > /dev/null
	touch $@
	
fdlibm.ok:
	rm -rf $@ ${FOLDER_FDLIBM}
	$(URLGET) ${GITHUB_URL_FDLIBM} | $(UNTAR) > /dev/null
	touch $@

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

# Preliminary build

gcc-${VERSION_GCC}-${CPU}-cross-preliminary.ok: gcc-${TARGET}.ok
	rm -rf $@ ${FOLDER_GCC}-${CPU}-cross-preliminary
	mkdir -p ${FOLDER_GCC}-${CPU}-cross-preliminary
	cd ${FOLDER_GCC}-${CPU}-cross-preliminary && \
	export PATH=${INSTALL_DIR}/bin:$$PATH && \
	../${FOLDER_GCC}/configure \
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
		--disable-multilib \
		--disable-libstdcxx-pch \
		--disable-lto && \
	$(MAKE) -j3 all-gcc all-target-libgcc $(OUT) && \
	$(MAKE) install-gcc install-target-libgcc $(OUT)
	touch $@

# Shortcuts

gcc-preliminary: gcc-${VERSION_GCC}-${CPU}-cross-preliminary.ok

mintlib: libc-${TARGET}.ok
	cd ${FOLDER_MINTLIB} && $(MAKE) OUT= clean $(OUT)
	cd ${FOLDER_MINTLIB} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		$(MAKE) OUT= toolprefix=${TARGET}- SHELL=$(BASH) CROSS=yes WITH_020_LIB=no WITH_V4E_LIB=no $(OUT)
	cd ${FOLDER_MINTLIB} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		$(MAKE) OUT= toolprefix=${TARGET}- SHELL=$(BASH) CROSS=yes WITH_020_LIB=no WITH_V4E_LIB=no install $(OUT)

mintbin: libc-${TARGET}.ok
	-cd ${FOLDER_MINTBIN} && $(MAKE) OUT= distclean $(OUT)
	cd ${FOLDER_MINTBIN} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		./configure --target=${TARGET} --prefix=${INSTALL_DIR} --disable-nls
	cd ${FOLDER_MINTBIN} && $(MAKE) OUT= $(OUT)
	cd ${FOLDER_MINTBIN} && $(MAKE) OUT= install $(OUT)

fdlibm: libc-${TARGET}.ok
	-cd ${FOLDER_FDLIBM} && $(MAKE) OUT= distclean $(OUT)
	cd ${FOLDER_FDLIBM} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		unset CC CXX AR RANLIB LD && \
		./configure --host=${TARGET} --prefix=${INSTALL_DIR} --libdir=${libdir}
	cd ${FOLDER_FDLIBM} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		$(MAKE) OUT= CPU-FPU-TYPES=68000.soft-float $(OUT)
	cd ${FOLDER_FDLIBM} && \
		export PATH=${INSTALL_DIR}/bin:$$PATH && \
		$(MAKE) OUT= CPU-FPU-TYPES=68000.soft-float install $(OUT)

# Full build

gcc-${VERSION_GCC}-${CPU}-cross-final.ok: ${INSTALL_DIR}/${TARGET}/sys-root/usr/lib/libc.a ${INSTALL_DIR}/${TARGET}/sys-root/usr/lib/libm.a
	rm -rf $@ ${FOLDER_GCC}-${CPU}-cross-final
	mkdir -p ${FOLDER_GCC}-${CPU}-cross-final
	cd ${FOLDER_GCC}-${CPU}-cross-final && \
	export PATH=${INSTALL_DIR}/bin:$$PATH CFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" CXXFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" && \
	../${FOLDER_GCC}/configure \
		--prefix=${INSTALL_DIR} \
		--target=${TARGET} \
		--with-sysroot=${INSTALL_DIR}/${TARGET}/sys-root \
		--disable-nls \
		--enable-languages="c,c++" \
		--disable-libstdcxx-pch \
		--disable-libgomp \
		--with-cpu=${CPU} \
		--disable-lto && \
	$(MAKE) -j3 $(OUT) && \
	$(MAKE) install-strip $(OUT)
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

binutils-${VERSION_BINUTILS}-${CPU}-atari.ok: binutils-${TARGET}.ok
	rm -rf $@ ${FOLDER_BINUTILS}-${CPU}-atari
	mkdir -p ${FOLDER_BINUTILS}-${CPU}-atari
	cd ${FOLDER_BINUTILS}-${CPU}-atari && \
	export PATH=${INSTALL_DIR}/bin:$$PATH CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" && \
	../${FOLDER_BINUTILS}/configure --target=${TARGET} --host=${TARGET} --disable-nls --prefix=/usr \
					--disable-gdb --disable-libdecnumber --disable-readline --disable-sim && \
	$(MAKE) -j3 $(OUT) && \
	$(MAKE) install-strip DESTDIR=${PWD}/binary-package/${CPU}/binutils-${VERSION_BINUTILS}
	touch $@

binutils-atari: check-target-gcc binutils-${VERSION_BINUTILS}-${CPU}-atari.ok

gcc-${VERSION_GCC}-${CPU}-atari.ok: gcc-${TARGET}.ok
	rm -rf $@ ${FOLDER_GCC}-${CPU}-atari
	mkdir -p ${FOLDER_GCC}-${CPU}-atari
	cd ${FOLDER_GCC}-${CPU}-atari && \
	export PATH=${INSTALL_DIR}/bin:$$PATH CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" && \
	../${FOLDER_GCC}/configure \
		--prefix=/usr \
		--host=${TARGET} \
		--target=${TARGET} \
		--with-sysroot="/" \
		--with-build-sysroot="${INSTALL_DIR}/${TARGET}/sys-root" \
		--disable-nls \
		--enable-languages="c,c++" \
		--disable-libstdcxx-pch \
		--disable-libgomp \
		--with-cpu=${CPU} \
		--disable-lto && \
	$(MAKE) -j3 $(OUT) && \
	$(MAKE) install-strip DESTDIR=${PWD}/binary-package/${CPU}/gcc-${VERSION_GCC} $(OUT)
	touch $@

gcc-atari: check-target-gcc gcc-${VERSION_GCC}-${CPU}-atari.ok

# Cleaning

clean-source:
	rm -rf ${FOLDER_BINUTILS}
	rm -rf ${FOLDER_GCC}
	rm -rf ${FOLDER_MINTLIB}
	rm -rf ${FOLDER_MINTBIN}
	rm -rf ${FOLDER_FDLIBM}
	rm -f *.ok
	rm -f *~

clean-cross:
	rm -rf ${FOLDER_BINUTILS}-${CPU}-cross
	rm -rf ${FOLDER_GCC}-${CPU}-cross-preliminary
	rm -rf ${FOLDER_GCC}-${CPU}-cross-final

pack-atari:
	cd ${PWD}/binary-package/${CPU}/gcc-${VERSION_GCC}/usr/lib/gcc/${TARGET}/${VERSION_GCC}/include-fixed && \
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
