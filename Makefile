# You need the bash shell for correct compilation of mintlib.

# Components to build
COMPONENTS			= BINUTILS GCC MINTLIB MINTBIN FDLIBM

VERSION_BINUTILS	= 2.30
VERSION_GCC			= 4.6.4

REPOSITORY_BINUTILS	= m68k-atari-mint-binutils-gdb
REPOSITORY_GCC		= m68k-atari-mint-gcc
REPOSITORY_MINTLIB	= mintlib
REPOSITORY_MINTBIN	= mintbin
REPOSITORY_FDLIBM	= fdlibm

BRANCH_BINUTILS		= binutils-2_30-mint
BRANCH_GCC			= gcc-4_6-mint
BRANCH_MINTLIB		= master
BRANCH_MINTBIN		= master
BRANCH_FDLIBM		= master

GITHUB_URL_BINUTILS	= https://github.com/freemint/${REPOSITORY_BINUTILS}/archive/refs/heads/${BRANCH_BINUTILS}.tar.gz
GITHUB_URL_GCC		= https://github.com/freemint/${REPOSITORY_GCC}/archive/refs/heads/${BRANCH_GCC}.tar.gz
GITHUB_URL_MINTLIB	= https://github.com/freemint/${REPOSITORY_MINTLIB}/archive/refs/heads/${BRANCH_MINTLIB}.tar.gz
GITHUB_URL_MINTBIN	= https://github.com/freemint/${REPOSITORY_MINTBIN}/archive/refs/heads/${BRANCH_MINTBIN}.tar.gz
GITHUB_URL_FDLIBM	= https://github.com/freemint/${REPOSITORY_FDLIBM}/archive/refs/heads/${BRANCH_FDLIBM}.tar.gz

# Auto-generate FOLDER_* definitions (replace / with - in branch names)
$(foreach comp,$(COMPONENTS),$(eval FOLDER_$(comp) = $(REPOSITORY_$(comp))-$(subst /,-,$(BRANCH_$(comp)))))

# Auto-generate ARCHIVE_* from FOLDER_* + extension
$(foreach comp,$(COMPONENTS),$(eval ARCHIVE_$(comp) = $(FOLDER_$(comp)).tar.gz))

SH      := $(shell which sh)
BASH    := $(shell which bash)
URLGET	:= wget -q -O
CPUS	:= $(getconf _NPROCESSORS_ONLN)

.PHONY: default help \
	all       all-skip-native       all-native \
	m68000    m68000-skip-native    m68000-native \
	m68020-60 m68020-60-skip-native m68020-60-native \
	5475      5475-skip-native      5475-native \
	binutils-preliminary gcc-preliminary mintlib-preliminary fdlibm-preliminary \
	binutils gcc mintlib fdlibm mintbin \
	binutils-atari gcc-atari mintbin-atari \
	strip-atari pack-atari check-target-gcc

default: m68000-skip-native

help: ./build.sh
	@echo "Makefile targets :"
	@echo "    all       / all[-skip]-native"
	@echo "    m68000    / m68000[-skip]-native"
	@echo "    m68020-60 / m68020-60[-skip]-native"
	@echo "    5475      / 5475[-skip]-native"

# "real" targets

all: ./build.sh
	MAKE=$(MAKE) $(SH) $< --all

all-skip-native: ./build.sh
	MAKE=$(MAKE) $(SH) $< --all --skip-native

all-native: ./build.sh
	MAKE=$(MAKE) $(SH) $< --all --native-only

m68000: ./build.sh
	MAKE=$(MAKE) $(SH) $< m68000

m68000-skip-native: ./build.sh
	MAKE=$(MAKE) $(SH) $< --skip-native m68000

m68000-native: ./build.sh
	MAKE=$(MAKE) $(SH) $< --native-only m68000

m68020-60: ./build.sh
	MAKE=$(MAKE) $(SH) $< m68020-60

m68020-60-skip-native: ./build.sh
	MAKE=$(MAKE) $(SH) $< --skip-native m68020-60

m68020-60-native: ./build.sh
	MAKE=$(MAKE) $(SH) $< --native-only m68020-60

5475: ./build.sh
	MAKE=$(MAKE) $(SH) $< 5475

5475-skip-native: ./build.sh
	MAKE=$(MAKE) $(SH) $< --skip-native 5475

5475-native: ./build.sh
	MAKE=$(MAKE) $(SH) $< --native-only 5475

# Downloading

define DOWNLOAD_RULE
archives/$(ARCHIVE_$(1)).ok:
	@mkdir -p archives
	@$(RM) archives/$(ARCHIVE_$(1))
	$(URLGET) archives/$(ARCHIVE_$(1)) $(GITHUB_URL_$(1))
	@touch $$@
endef

$(foreach comp,$(COMPONENTS),$(eval $(call DOWNLOAD_RULE,$(comp))))

# Depacking and patching

define UNPACK_RULE
sources/$(FOLDER_$(1)).ok: archives/$(ARCHIVE_$(1)).ok
	@mkdir -p sources
	@$(RM) -r sources/$(FOLDER_$(1))
	tar xf archives/$(ARCHIVE_$(1)) -C sources
	@touch $$@
endef

$(foreach comp,$(COMPONENTS),$(eval $(call UNPACK_RULE,$(comp))))

# Custom post-processing rules for specific components

sources/${FOLDER_GCC}.patched: sources/${FOLDER_GCC}.ok gmp-none.patch download_prerequisites.patch
	cd sources/${FOLDER_GCC} && patch -p1 < ../../download_prerequisites.patch
	cd sources/${FOLDER_GCC} && contrib/download_prerequisites --force
	cd sources/${FOLDER_GCC}/gmp && patch -p1 < ../../../gmp-none.patch
	@touch $@

sources/${FOLDER_MINTLIB}.patched: sources/${FOLDER_MINTLIB}.ok mintlib.patch
	cd sources/${FOLDER_MINTLIB} && patch -p1 < ../../mintlib.patch
	@touch $@

# binutils (preliminary/full)

binutils-${VERSION_BINUTILS}-cross.ok: sources/${FOLDER_BINUTILS}.ok
	@$(RM) -r ${FOLDER_BINUTILS}-cross
	@mkdir -p ${FOLDER_BINUTILS}-cross
	cd ${FOLDER_BINUTILS}-cross && \
	../sources/${FOLDER_BINUTILS}/configure --target=${TARGET} --prefix=${PREFIX} --disable-nls --disable-werror \
		--disable-gdb --disable-libdecnumber --disable-readline --disable-sim && \
	$(MAKE) V=1 -j$(CPUS)
	@touch $@

binutils-${VERSION_BINUTILS}-cross-preliminary.ok binutils-${VERSION_BINUTILS}-cross-${CPU}.ok: binutils-${VERSION_BINUTILS}-cross.ok
	cd ${FOLDER_BINUTILS}-cross && \
	$(MAKE) install-strip
	@touch $@

binutils-preliminary: binutils-${VERSION_BINUTILS}-cross-preliminary.ok
binutils: binutils-${VERSION_BINUTILS}-cross-${CPU}.ok

# gcc (preliminary)

gcc-${VERSION_GCC}-cross-stage1.ok: sources/${FOLDER_GCC}.patched
	@$(RM) -r ${FOLDER_GCC}-cross-stage1
	@mkdir -p ${FOLDER_GCC}-cross-stage1
	cd ${FOLDER_GCC}-cross-stage1 && \
	../sources/${FOLDER_GCC}/configure \
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
		--enable-version-specific-runtime-libs \
		--enable-checking=yes && \
	$(MAKE) -j$(CPUS) all-gcc all-target-libgcc && \
	$(MAKE) install-gcc install-target-libgcc
	@touch $@

gcc-preliminary: gcc-${VERSION_GCC}-cross-stage1.ok

# Libraries (preliminary/full)

mintlib-build.ok: sources/${FOLDER_MINTLIB}.patched
	@cd sources/${FOLDER_MINTLIB} && $(MAKE) clean > /dev/null
	cd sources/${FOLDER_MINTLIB} && \
		$(MAKE) CROSS_TOOL=${TARGET} SHELL=$(BASH) WITH_020_LIB=yes WITH_V4E_LIB=yes WITH_DEBUG_LIB=no
	@touch $@

mintlib-preliminary.ok mintlib-${CPU}.ok: mintlib-build.ok
	cd sources/${FOLDER_MINTLIB} && \
		$(MAKE) CROSS_TOOL=${TARGET} SHELL=$(BASH) WITH_020_LIB=yes WITH_V4E_LIB=yes WITH_DEBUG_LIB=no install
	@touch $@

mintlib-preliminary: mintlib-preliminary.ok
mintlib: mintlib-${CPU}.ok

fdlibm-build.ok: sources/${FOLDER_FDLIBM}.ok mintlib-build.ok
	@$(RM) -r ${FOLDER_FDLIBM}
	@mkdir -p ${FOLDER_FDLIBM}
	cd ${FOLDER_FDLIBM} && \
		../sources/${FOLDER_FDLIBM}/configure --host=${TARGET} --prefix=/usr && \
	$(MAKE)
	@touch $@

fdlibm-preliminary.ok fdlibm-${CPU}.ok: fdlibm-build.ok
	cd ${FOLDER_FDLIBM} && $(MAKE) install
	@touch $@

fdlibm-preliminary: fdlibm-preliminary.ok
fdlibm: fdlibm-${CPU}.ok

# gcc (full)

gcc-${VERSION_GCC}-cross-stage2-${CPU}.ok: ${INSTALL_DIR}/${TARGET}/sys-root/usr/lib/libc.a ${INSTALL_DIR}/${TARGET}/sys-root/usr/lib/libm.a
	@$(RM) -r ${FOLDER_GCC}-cross-stage2-${CPU}
	@mkdir -p ${FOLDER_GCC}-cross-stage2-${CPU}
	cd ${FOLDER_GCC}-cross-stage2-${CPU} && \
	CFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" CXXFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" \
	../sources/${FOLDER_GCC}/configure \
		--prefix=${INSTALL_DIR} \
		--target=${TARGET} \
		--with-sysroot \
		--disable-nls \
		--disable-lto \
		--enable-languages="c,c++" \
		--disable-libstdcxx-pch \
		--disable-threads \
		--disable-tls \
		--disable-libgomp \
		--with-cpu=${CPU} \
		--with-libstdcxx-zoneinfo=no \
		--disable-libcc1 \
		--enable-version-specific-runtime-libs && \
	$(MAKE) -j$(CPUS) && \
	$(MAKE) install-strip
	@touch $@

gcc: gcc-${VERSION_GCC}-cross-stage2-${CPU}.ok

# mintbin

mintbin-cross.ok: sources/${FOLDER_MINTBIN}.ok
	@$(RM) -r ${FOLDER_MINTBIN}-cross
	@mkdir -p ${FOLDER_MINTBIN}-cross
	cd ${FOLDER_MINTBIN}-cross && \
		../sources/${FOLDER_MINTBIN}/configure --target=${TARGET} --prefix=${PREFIX} --disable-nls && \
	$(MAKE)
	@touch $@

mintbin-cross-${CPU}.ok: mintbin-cross.ok
	cd ${FOLDER_MINTBIN}-cross && \
	$(MAKE) install-strip
	@touch $@

mintbin: mintbin-cross-${CPU}.ok

# Atari building

check-target-gcc:
	multi_dir=`${TARGET}-gcc -${OPT} -print-multi-directory` && \
	if [ $$multi_dir != "." ]; then echo "\n${TARGET}-gcc is not configured for default ${CPU} output\n"; exit 1; fi

binutils-${VERSION_BINUTILS}-atari-${CPU}.ok: sources/${FOLDER_BINUTILS}.ok
	@$(RM) -r ${FOLDER_BINUTILS}-atari-${CPU}
	@mkdir -p ${FOLDER_BINUTILS}-atari-${CPU}
	cd ${FOLDER_BINUTILS}-atari-${CPU} && \
	CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" \
	../sources/${FOLDER_BINUTILS}/configure --target=${TARGET} --host=${TARGET} --disable-nls --prefix=/usr \
		--disable-gdb --disable-libdecnumber --disable-readline --disable-sim && \
	$(MAKE) -j$(CPUS) V=1 && \
	$(MAKE) install-strip DESTDIR=${PWD}/binary-package/${CPU}/binutils-${VERSION_BINUTILS}
	@touch $@

binutils-atari: check-target-gcc binutils-${VERSION_BINUTILS}-atari-${CPU}.ok

gcc-${VERSION_GCC}-atari-${CPU}.ok: sources/${FOLDER_GCC}.patched
	@$(RM) -r ${FOLDER_GCC}-atari-${CPU}
	@mkdir -p ${FOLDER_GCC}-atari-${CPU}
	cd ${FOLDER_GCC}-atari-${CPU} && \
	CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" \
	../sources/${FOLDER_GCC}/configure \
		--prefix=/usr \
		--host=${TARGET} \
		--target=${TARGET} \
		--with-sysroot="/" \
		--with-build-sysroot="${INSTALL_DIR}/${TARGET}/sys-root" \
		--disable-nls \
		--disable-lto \
		--enable-languages="c,c++" \
		--disable-libstdcxx-pch \
		--disable-threads \
		--disable-tls \
		--disable-libgomp \
		--with-cpu=${CPU} \
		--with-libstdcxx-zoneinfo=no \
		--disable-libcc1 \
		--enable-version-specific-runtime-libs && \
	$(MAKE) -j$(CPUS) && \
	$(MAKE) install-strip DESTDIR=${PWD}/binary-package/${CPU}/gcc-${VERSION_GCC}
	@touch $@

gcc-atari: check-target-gcc gcc-${VERSION_GCC}-atari-${CPU}.ok

mintbin-atari-${CPU}.ok: sources/${FOLDER_MINTBIN}.ok
	@$(RM) -r ${FOLDER_MINTBIN}-atari-${CPU}
	@mkdir -p ${FOLDER_MINTBIN}-atari-${CPU}
	cd ${FOLDER_MINTBIN}-atari-${CPU} && \
	CFLAGS="-O2 -fomit-frame-pointer" CXXFLAGS="-O2 -fomit-frame-pointer" \
	../sources/${FOLDER_MINTBIN}/configure --target=${TARGET} --host=${TARGET} --disable-nls --prefix=/usr && \
	$(MAKE) && \
	$(MAKE) install-strip DESTDIR=${PWD}/binary-package/${CPU}/mintbin
	@touch $@

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
