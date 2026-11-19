# You need the bash shell for correct compilation of mintlib.

# Components to build
COMPONENTS			= BINUTILS GCC MINTLIB MINTBIN FDLIBM

VERSION_BINUTILS	= 2.42
VERSION_GCC			= 13.5.0

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

# Auto-generate FOLDER_* definitions (replace / with - in branch names)
$(foreach comp,$(COMPONENTS),$(eval FOLDER_$(comp) = $(REPOSITORY_$(comp))-$(subst /,-,$(BRANCH_$(comp)))))

# Auto-generate ARCHIVE_* from FOLDER_* + extension
$(foreach comp,$(COMPONENTS),$(eval ARCHIVE_$(comp) = $(FOLDER_$(comp)).tar.gz))

BASH    := $(shell which bash)
URLGET	:= wget -q -O
CPUS	:= $(shell getconf _NPROCESSORS_ONLN)

TARGET		?= m68k-atari-mintelf
INSTALL_DIR	?= $(HOME)/gnu-tools
PRELIMINARY	= $(CURDIR)/preliminary

ALL_CPUS	= m68000 m68020-60 5475
cpu_dir		= $(if $(filter 5475,$(1)),m5475,$(1))
cpu_opt		= $(if $(filter 5475,$(1)),mcpu=5475,$(1))
cpu_prefix	= $(INSTALL_DIR)/$(call cpu_dir,$(1))
cpu_sysroot	= $(call cpu_prefix,$(1))/$(TARGET)/sys-root
cross_gcc	= $(call cpu_prefix,$(1))/bin/$(TARGET)-gcc
cross_path	= $(call cpu_prefix,$(1))/bin

# CPU is set on the command line of per-CPU sub-makes
CPU_PREFIX	= $(call cpu_prefix,$(CPU))
SYSROOT		= $(call cpu_sysroot,$(CPU))

.PHONY: default help bootstrap \
	all       all-skip-native       all-native \
	m68000    m68000-skip-native    m68000-native \
	m68020-60 m68020-60-skip-native m68020-60-native \
	5475      5475-skip-native      5475-native \
	$(addprefix cross-,$(ALL_CPUS)) $(addprefix native-,$(ALL_CPUS)) \
	binutils-preliminary gcc-preliminary mintlib-preliminary fdlibm-preliminary \
	binutils gcc sysroot-prebuilt mintbin \
	mintlib fdlibm $(addprefix mintlib-,$(ALL_CPUS)) $(addprefix fdlibm-,$(ALL_CPUS)) \
	binutils-atari gcc-atari mintbin-atari \
	strip-atari pack-atari check-target-gcc

# the steps of each CPU build depend on being run in order
.NOTPARALLEL:

default: m68000-skip-native

help:
	@echo "Makefile targets :"
	@echo "    all       / all[-skip]-native"
	@echo "    m68000    / m68000[-skip]-native"
	@echo "    m68020-60 / m68020-60[-skip]-native"
	@echo "    5475      / 5475[-skip]-native"
	@echo "    mintlib[-<cpu>] / fdlibm[-<cpu>] (reinstall into an installed cross compiler, m68000 by default)"

# "real" targets

# all, all-skip-native and all-native run the per-CPU targets below for each CPU in ALL_CPUS
all: $(ALL_CPUS)
all-skip-native: $(addprefix cross-,$(ALL_CPUS))
all-native: $(addprefix native-,$(ALL_CPUS))

# for each CPU, e.g. m68000:
#   m68000: cross-m68000 native-m68000
#   m68000-skip-native: cross-m68000
#   m68000-native: native-m68000
$(foreach c,$(ALL_CPUS),$(eval $(c): cross-$(c) native-$(c)))
$(foreach c,$(ALL_CPUS),$(eval $(c)-skip-native: cross-$(c)))
$(foreach c,$(ALL_CPUS),$(eval $(c)-native: native-$(c)))

# temporary toolchain, mintlib and fdlibm (fdlibm's configure needs a working mintlib)
bootstrap:
	$(MAKE) PATH="$(PRELIMINARY)/bin:/usr/bin" TARGET=$(TARGET) PREFIX="" DESTDIR="$(PRELIMINARY)" \
		binutils-preliminary gcc-preliminary
	$(MAKE) PATH="$(PRELIMINARY)/bin:/usr/bin" TARGET=$(TARGET) DESTDIR="$(PRELIMINARY)/$(TARGET)/sys-root" \
		mintlib-preliminary fdlibm-preliminary

# cross-m68000, cross-m68020-60, cross-5475: install mintlib/fdlibm built by the preliminary
# compiler, then binutils, gcc and mintbin into $(INSTALL_DIR)/<cpu> (<cpu> as in cpu_dir)
$(addprefix cross-,$(ALL_CPUS)): cross-%: bootstrap
	$(MAKE) PATH="$(PRELIMINARY)/bin:/usr/bin" CPU=$* TARGET=$(TARGET) sysroot-prebuilt
	$(MAKE) PATH="$(call cpu_prefix,$*)/bin:/usr/bin" CPU=$* DESTDIR="$(call cpu_prefix,$*)" binutils
	$(MAKE) PATH="$(call cpu_prefix,$*)/bin:/usr/bin" CPU=$* TARGET=$(TARGET) gcc
	$(MAKE) PATH="$(call cpu_prefix,$*)/bin:/usr/bin" CPU=$* TARGET=$(TARGET) PREFIX="" DESTDIR="$(call cpu_prefix,$*)" mintbin

# native-m68000, native-m68020-60, native-5475: build binutils, gcc and mintbin for the Atari
# with the cross compiler installed by cross-<cpu> and pack them into binary-package/<cpu>
$(addprefix native-,$(ALL_CPUS)): native-%:
	$(MAKE) PATH="$(call cpu_prefix,$*)/bin:/usr/bin" CPU=$* TARGET=$(TARGET) binutils-atari gcc-atari mintbin-atari
	$(MAKE) PATH="$(call cpu_prefix,$*)/bin:/usr/bin" CPU=$* TARGET=$(TARGET) strip-atari pack-atari

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

sources/${FOLDER_GCC}.patched: sources/${FOLDER_GCC}.ok gcc-atari.patch libcody-cxx11.patch
	cd sources/${FOLDER_GCC} && contrib/download_prerequisites --force
	cd sources/${FOLDER_GCC} && patch -p1 < ../../gcc-atari.patch
	cd sources/${FOLDER_GCC} && patch -p1 < ../../libcody-cxx11.patch
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
	CXXFLAGS="-g -O2 -std=gnu++17" \
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
		--disable-fixincludes \
		--enable-version-specific-runtime-libs \
		--enable-checking=yes && \
	$(MAKE) -j$(CPUS) all-gcc all-target-libgcc && \
	$(MAKE) install-gcc install-target-libgcc
	@touch $@

gcc-preliminary: gcc-${VERSION_GCC}-cross-stage1.ok

# Libraries (preliminary/full)

mintlib-build.ok: sources/${FOLDER_MINTLIB}.ok
	@cd sources/${FOLDER_MINTLIB} && $(MAKE) clean > /dev/null
	cd sources/${FOLDER_MINTLIB} && \
		$(MAKE) CROSS_TOOL=${TARGET} SHELL=$(BASH) WITH_020_LIB=yes WITH_V4E_LIB=yes WITH_DEBUG_LIB=no
	@touch $@

mintlib-preliminary.ok: mintlib-build.ok
	cd sources/${FOLDER_MINTLIB} && \
		$(MAKE) CROSS_TOOL=${TARGET} SHELL=$(BASH) WITH_020_LIB=yes WITH_V4E_LIB=yes WITH_DEBUG_LIB=no install
	@touch $@

mintlib-preliminary: mintlib-preliminary.ok

fdlibm-build.ok: sources/${FOLDER_FDLIBM}.ok mintlib-build.ok
	@$(RM) -r ${FOLDER_FDLIBM}
	@mkdir -p ${FOLDER_FDLIBM}
	cd ${FOLDER_FDLIBM} && \
		../sources/${FOLDER_FDLIBM}/configure --host=${TARGET} --prefix=/usr && \
	$(MAKE)
	@touch $@

fdlibm-preliminary.ok: fdlibm-build.ok
	cd ${FOLDER_FDLIBM} && $(MAKE) install
	@touch $@

fdlibm-preliminary: fdlibm-preliminary.ok

# mintlib and fdlibm decide where each library goes by asking the compiler which multilib
# directory it belongs to. Here that is the preliminary compiler, whose default CPU is
# m68000, so the m68000 libraries land in usr/lib and the others in usr/lib/m68020-60 and
# usr/lib/m5475. A cross compiler built for m68020-60 or 5475 expects the opposite for
# its own CPU: its libraries in usr/lib and the m68000 ones in usr/lib/m68000. The
# libraries are therefore installed into STAGE first, rearranged there and only then copied
# into the sys-root, so nothing else in the sys-root is moved.
STAGE		= $(CURDIR)/sysroot-$(CPU)
# multilib directories of the CPUs other than m68000: m68020-60 m5475
OTHER_DIRS	= $(filter-out m68000,$(foreach c,$(ALL_CPUS),$(call cpu_dir,$(c))))

sysroot-${CPU}.ok: mintlib-build.ok fdlibm-build.ok
	@$(RM) -r "$(STAGE)"
	cd sources/${FOLDER_MINTLIB} && \
		$(MAKE) CROSS_TOOL=${TARGET} SHELL=$(BASH) WITH_020_LIB=yes WITH_V4E_LIB=yes WITH_DEBUG_LIB=no DESTDIR="$(STAGE)" install
	cd ${FOLDER_FDLIBM} && $(MAKE) DESTDIR="$(STAGE)" install
	$(RM) -r "$(STAGE)/sbin" "$(STAGE)/usr/sbin"
# for m68020-60 (5475 likewise):
#   usr/lib/* except m68020-60/ and m5475/ (m68000 libraries and their mshort, ... variants)
#       -> usr/lib/m68000/
#   usr/lib/m68020-60/* -> usr/lib/
ifneq ($(call cpu_dir,$(CPU)),m68000)
	cd "$(STAGE)/usr/lib" && mkdir m68000 && \
		find . -mindepth 1 -maxdepth 1 -not -name m68000 $(addprefix -not -name ,$(OTHER_DIRS)) -exec mv {} m68000 \; && \
		mv $(call cpu_dir,$(CPU))/* . && rmdir $(call cpu_dir,$(CPU))
endif
	mkdir -p "$(SYSROOT)" && cp -a "$(STAGE)/." "$(SYSROOT)"
	@$(RM) -r "$(STAGE)"
	@touch $@

sysroot-prebuilt: sysroot-${CPU}.ok

# Libraries (reinstall into an installed cross compiler)

mintlib: mintlib-m68000
fdlibm: fdlibm-m68000

$(addprefix mintlib-,$(ALL_CPUS)): mintlib-%: sources/${FOLDER_MINTLIB}.ok
	@test -x "$(call cross_gcc,$*)" || { echo "$(call cross_gcc,$*) not found"; exit 1; }
	PATH="$(call cross_path,$*):/usr/bin" $(MAKE) mintlib-build.ok
	cd sources/${FOLDER_MINTLIB} && PATH="$(call cross_path,$*):/usr/bin" \
		$(MAKE) CROSS_TOOL=${TARGET} SHELL=$(BASH) WITH_020_LIB=yes WITH_V4E_LIB=yes WITH_DEBUG_LIB=no DESTDIR="$(call cpu_sysroot,$*)" install
	$(RM) -r "$(call cpu_sysroot,$*)/sbin" "$(call cpu_sysroot,$*)/usr/sbin"

# fdlibm's configure needs libc.a in the sys-root
$(addprefix fdlibm-,$(ALL_CPUS)): fdlibm-%: sources/${FOLDER_FDLIBM}.ok
	@test -f "$(call cpu_sysroot,$*)/usr/lib/libc.a" || { echo "Run 'make mintlib-$*' first"; exit 1; }
	PATH="$(call cross_path,$*):/usr/bin" $(MAKE) fdlibm-build.ok
	PATH="$(call cross_path,$*):/usr/bin" $(MAKE) -C ${FOLDER_FDLIBM} DESTDIR="$(call cpu_sysroot,$*)" install

# gcc (full)

gcc-${VERSION_GCC}-cross-stage2-${CPU}.ok: | $(SYSROOT)/usr/lib/libc.a $(SYSROOT)/usr/lib/libm.a
	@$(RM) -r ${FOLDER_GCC}-cross-stage2-${CPU}
	@mkdir -p ${FOLDER_GCC}-cross-stage2-${CPU}
	cd ${FOLDER_GCC}-cross-stage2-${CPU} && \
	CXXFLAGS="-g -O2 -std=gnu++17" \
	CFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" CXXFLAGS_FOR_TARGET="-O2 -fomit-frame-pointer" \
	../sources/${FOLDER_GCC}/configure \
		--prefix=$(CPU_PREFIX) \
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
	multi_dir=`${TARGET}-gcc -$(call cpu_opt,$(CPU)) -print-multi-directory` && \
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
		--with-build-sysroot="$(SYSROOT)" \
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
		PATH=$(CPU_PREFIX)/bin:$$PATH ${TARGET}-stack --fix=1024k "${PWD}/binary-package/${CPU}/gcc-${VERSION_GCC}/usr/libexec/gcc/${TARGET}/${VERSION_GCC}/$$f"; \
	done
	PATH=$(CPU_PREFIX)/bin:$$PATH ${TARGET}-stack --fix=192k "${PWD}/binary-package/${CPU}/gcc-${VERSION_GCC}/usr/libexec/gcc/${TARGET}/${VERSION_GCC}/collect2"
	for f in c++ cpp g++ gcc ${TARGET}-c++ ${TARGET}-g++ ${TARGET}-gcc ${TARGET}-gcc-${VERSION_GCC}; \
	do \
		PATH=$(CPU_PREFIX)/bin:$$PATH ${TARGET}-stack --fix=192k "${PWD}/binary-package/${CPU}/gcc-${VERSION_GCC}/usr/bin/$$f"; \
	done
	PATH=$(CPU_PREFIX)/bin:$$PATH find "${PWD}/binary-package/${CPU}" -type f -perm -a=x -exec ${TARGET}-strip -s {} \;
	PATH=$(CPU_PREFIX)/bin:$$PATH find "${PWD}/binary-package/${CPU}" -type f -name '*.a' -exec ${TARGET}-strip -S -X -w -N '.L[0-9]*' {} \;
