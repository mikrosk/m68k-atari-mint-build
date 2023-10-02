# docker buildx build --progress plain .

ARG TARGET=m68k-atari-mintelf
ARG INSTALL_DIR=/usr/${TARGET}

# always latest LTS
FROM ubuntu:latest AS build
RUN apt -y update && apt -y upgrade
RUN apt -y install binutils bison bzip2 file flex gawk gcc g++ m4 make patch texinfo wget
RUN ln -s bash /bin/sh.bash && mv /bin/sh.bash /bin/sh
WORKDIR /src
COPY gcc-atari.patch .

# renew the arguments
ARG TARGET
ARG INSTALL_DIR

# used at a few places
ENV VERSION_BINUTILS	2.41
ENV VERSION_GCC		    13.2.0

# binutils download
ENV REPOSITORY_BINUTILS	m68k-atari-mint-binutils-gdb
ENV BRANCH_BINUTILS		binutils-2_41-mintelf
ENV GITHUB_URL_BINUTILS	https://github.com/freemint/${REPOSITORY_BINUTILS}/archive/refs/heads/${BRANCH_BINUTILS}.tar.gz
ENV FOLDER_BINUTILS		${REPOSITORY_BINUTILS}-${BRANCH_BINUTILS}
RUN wget -q -O - ${GITHUB_URL_BINUTILS} | tar xzf -

# gcc download
ENV REPOSITORY_GCC		m68k-atari-mint-gcc
ENV BRANCH_GCC		    gcc-13-mintelf
ENV GITHUB_URL_GCC		https://github.com/freemint/${REPOSITORY_GCC}/archive/refs/heads/${BRANCH_GCC}.tar.gz
ENV FOLDER_GCC		    ${REPOSITORY_GCC}-${BRANCH_GCC}
RUN wget -q -O - ${GITHUB_URL_GCC} | tar xzf -
RUN cd ${FOLDER_GCC} \
    && ./contrib/download_prerequisites \
    && patch -p1 < ../gcc-atari.patch \
    && cd -

# binutils preliminary build (actually a full one but for preliminary gcc)
RUN mkdir build-binutils-preliminary \
    && cd build-binutils-preliminary \
    && ../${FOLDER_BINUTILS}/configure \
        --target=${TARGET} \
        --prefix=${INSTALL_DIR}-tmp \
        --disable-nls \
        --disable-werror \
        --enable-gprofng=no \
        --disable-gdb --disable-libdecnumber --disable-readline --disable-sim \
    && make \
    && make install-strip \
    && cd -

# gcc preliminary build
RUN mkdir build-gcc-preliminary \
    && cd build-gcc-preliminary \
    && PATH=${INSTALL_DIR}-tmp/bin:$PATH ../${FOLDER_GCC}/configure \
        --prefix=${INSTALL_DIR}-tmp \
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
        --disable-lto \
    && make all-gcc all-target-libgcc \
    && make install-gcc install-target-libgcc \
    && cd -

# mintlib download
ENV REPOSITORY_MINTLIB	mintlib
ENV BRANCH_MINTLIB		master
ENV GITHUB_URL_MINTLIB	https://github.com/freemint/${REPOSITORY_MINTLIB}/archive/refs/heads/${BRANCH_MINTLIB}.tar.gz
ENV FOLDER_MINTLIB		${REPOSITORY_MINTLIB}-${BRANCH_MINTLIB}
RUN wget -q -O - ${GITHUB_URL_MINTLIB} | tar xzf -

# fdlibm download
ENV REPOSITORY_FDLIBM	fdlibm
ENV BRANCH_FDLIBM		master
ENV GITHUB_URL_FDLIBM	https://github.com/freemint/${REPOSITORY_FDLIBM}/archive/refs/heads/${BRANCH_FDLIBM}.tar.gz
ENV FOLDER_FDLIBM		${REPOSITORY_FDLIBM}-${BRANCH_FDLIBM}
RUN wget -q -O - ${GITHUB_URL_FDLIBM} | tar xzf -

# mintbin download
ENV REPOSITORY_MINTBIN	mintbin
ENV BRANCH_MINTBIN		master
ENV GITHUB_URL_MINTBIN	https://github.com/freemint/${REPOSITORY_MINTBIN}/archive/refs/heads/${BRANCH_MINTBIN}.tar.gz
ENV FOLDER_MINTBIN		${REPOSITORY_MINTBIN}-${BRANCH_MINTBIN}
RUN wget -q -O - ${GITHUB_URL_MINTBIN} | tar xzf -

# mintlib build
RUN cd ${FOLDER_MINTLIB} \
    && PATH=${INSTALL_DIR}-tmp/bin:$PATH make toolprefix=${TARGET}- CROSS=yes WITH_DEBUG_LIB=no \
    && make WITH_DEBUG_LIB=no prefix="${INSTALL_DIR}/${TARGET}/sys-root/usr" install \
    && cd -

# fdlibm build
RUN cd ${FOLDER_FDLIBM} \
    && PATH=${INSTALL_DIR}-tmp/bin:$PATH ./configure --host=${TARGET} --prefix="${INSTALL_DIR}/${TARGET}/sys-root/usr" \
    && PATH=${INSTALL_DIR}-tmp/bin:$PATH make \
    && make install \
    && cd -

# remove preliminary binutils/gcc
RUN rm -rf ${INSTALL_DIR}-tmp

# binutils build
RUN mkdir build-binutils \
    && cd build-binutils \
    && ../${FOLDER_BINUTILS}/configure \
        --target=${TARGET} \
        --prefix=${INSTALL_DIR} \
        --disable-nls \
        --disable-werror \
        --enable-gprofng=no \
        --disable-gdb --disable-libdecnumber --disable-readline --disable-sim \
    && make \
    && make install-strip \
    && cd -

# gcc build
RUN mkdir build-gcc \
    && cd build-gcc \
    && PATH=${INSTALL_DIR}/bin:$PATH ../${FOLDER_GCC}/configure \
        --prefix=${INSTALL_DIR} \
        --target=${TARGET} \
        --with-sysroot=${INSTALL_DIR}/${TARGET}/sys-root \
        --disable-nls \
        --disable-shared \
        --without-newlib \
        --disable-decimal-float \
        --disable-libgomp \
        --enable-languages="c,c++,lto" \
        --disable-libstdcxx-pch \
        --with-libstdcxx-zoneinfo=no \
        --disable-sjlj-exceptions \
    && make \
    && make install-strip \
    && cd -

RUN cd "${INSTALL_DIR}/lib/gcc/${TARGET}/${VERSION_GCC}/include-fixed" && \
    for f in $(find . -type f); \
    do \
        case "$f" in \
            ./README | ./limits.h | ./syslimits.h) ;; \
            *) echo "Removing fixed include file $f"; rm "$f" ;; \
        esac \
    done && \
    for d in $(find . -depth -type d); \
    do \
        test "$d" = "." || rmdir "$d"; \
    done

# mintbin build
RUN cd ${FOLDER_MINTBIN} \
    && PATH=${INSTALL_DIR}/bin:$PATH ./configure --target=${TARGET} --prefix=${INSTALL_DIR} --disable-nls \
    && make \
    && make install \
    && cd -

# final build
FROM ubuntu:latest
RUN apt -y update && apt -y upgrade

# renew the arguments
ARG TARGET
ARG INSTALL_DIR

COPY --from=build ${INSTALL_DIR} ${INSTALL_DIR}
