# always latest LTS
FROM ubuntu:latest AS build
RUN apt -y update && apt -y upgrade
RUN apt -y install binutils bison bzip2 file flex gawk gcc g++ m4 make patch texinfo wget
RUN ln -s bash /bin/sh.bash && mv /bin/sh.bash /bin/sh
WORKDIR /src
COPY gcc-atari.patch .
#RUN chmod +x version-check.sh
#CMD ./version-check.sh

# --progress plain
# docker buildx create --bootstrap --use --name buildkit \
#    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 \
#    --driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1
# docker buildx build --progress plain .

ENV TARGET              m68k-atari-mintelf
ENV INSTALL_DIR         /usr/${TARGET}

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

# gcc preliminary build
RUN mkdir build-gcc-preliminary \
    && cd build-gcc-preliminary \
    && export PATH=${INSTALL_DIR}/bin:$PATH && \
	../${FOLDER_GCC}/configure \
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

ENV REPOSITORY_MINTLIB	mintlib
ENV BRANCH_MINTLIB		master
ENV GITHUB_URL_MINTLIB	https://github.com/freemint/${REPOSITORY_MINTLIB}/archive/refs/heads/${BRANCH_MINTLIB}.tar.gz
ENV FOLDER_MINTLIB		${REPOSITORY_MINTLIB}-${BRANCH_MINTLIB}

ENV REPOSITORY_FDLIBM	fdlibm
ENV BRANCH_FDLIBM		master
ENV GITHUB_URL_FDLIBM	https://github.com/freemint/${REPOSITORY_FDLIBM}/archive/refs/heads/${BRANCH_FDLIBM}.tar.gz
ENV FOLDER_FDLIBM		${REPOSITORY_FDLIBM}-${BRANCH_FDLIBM}

ENV REPOSITORY_MINTBIN	mintbin
ENV BRANCH_MINTBIN		master
ENV GITHUB_URL_MINTBIN	https://github.com/freemint/${REPOSITORY_MINTBIN}/archive/refs/heads/${BRANCH_MINTBIN}.tar.gz
ENV FOLDER_MINTBIN		${REPOSITORY_MINTBIN}-${BRANCH_MINTBIN}

ENV VERSION_BINUTILS	2.41
ENV VERSION_GCC		    13.2.0

CMD ls /usr
