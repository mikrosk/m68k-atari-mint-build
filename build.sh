#!/bin/sh -eux

target=m68k-atari-mint

if [ -z "${INSTALL_DIR}" ] ; then
	INSTALL_DIR="$HOME/gnu-tools-464"
fi

CPU_DIRS="m68000 m68020-60 m5475"		# target directory
CPU_OPTS="m68000 m68020-60 mcpu=5475"	# gcc command line
CPU_CPUS="m68000 m68020-60 5475"		# --with-cpu=
CPU_COUNT=$(echo ${CPU_DIRS} | tr ' ' '\n' | wc -l)

indices=""
indices_all=""
i=1
while [ $i -le $CPU_COUNT ] ; do
	indices_all="$indices_all $i"
	i=$((i + 1))
done
skip_native=0
native_only=0

# parse command line
for arg in $*
do
	case $arg in
	--skip-native)
	skip_native=1
	;;
	--native-only)
	native_only=1
	;;
	--all)
	indices=$indices_all
	;;
	*)
	ok=0
	i=1
	while [ $i -le $CPU_COUNT ] ; do
		cpu=$(echo $CPU_CPUS | cut -d ' ' -f $i)
		if [ "$arg" = "$cpu" ] ; then
			indices="$indices $i"
			ok=1
		fi
		i=$((i + 1))
	done
	if [ $ok -eq 0 ] ; then
		echo "Error : $arg is not a valid CPU."
		echo "Valid CPU are : ${CPU_CPUS}"
		exit 1
	fi
	;;
	esac
done

if [ -z "$indices" ] ; then
	echo "Do not invoke this script directly. Type 'make' or 'make help'."
	exit 1
fi

if [ $native_only -eq 0 ] ; then
	# build & install temporary toolchain
	DESTDIR="$PWD/preliminary"
	${MAKE} PATH="$DESTDIR/bin:/usr/bin" TARGET=$target PREFIX="" DESTDIR="$DESTDIR" binutils-preliminary gcc-preliminary
	# build & install mintlib/fdlibm (to make fdlibm's ./configure happy)
	${MAKE} PATH="$DESTDIR/bin:/usr/bin" TARGET=$target DESTDIR="$DESTDIR/$target/sys-root" mintlib-preliminary fdlibm-preliminary
fi

for i in $indices
do
	dir=$(echo $CPU_DIRS | cut -d ' ' -f $i)
	cpu=$(echo $CPU_CPUS | cut -d ' ' -f $i)
	opt=$(echo $CPU_OPTS | cut -d ' ' -f $i)

	if [ $native_only -eq 0 ] ; then
		DESTDIR="$INSTALL_DIR/$dir/$target/sys-root"

		# install pre-built mintlib/fdlibm (mintlib's make install requires a working compiler)
		${MAKE} PATH="$PWD/preliminary/bin:/usr/bin" CPU="$cpu" TARGET=$target DESTDIR="$DESTDIR" mintlib fdlibm || exit 1

		# remove mintlib m68000 leftovers
		rm -r "$DESTDIR/sbin"
		rm -r "$DESTDIR/usr/sbin"

		# provide proper folders for m68020-60 and m5475 multilib
		if [ "$dir" != "m68000" ]
		then
			target_dirs=""
			for j in $indices_all
			do
				target_dir=$(echo $CPU_DIRS | cut -d ' ' -f $j)
				if [ "$target_dir" != "m68000" ]
				then
					target_dirs="$target_dirs $target_dir"
				fi
			done
			target_dir_1=$(echo $target_dirs | cut -d ' ' -f 1)
			target_dir_2=$(echo $target_dirs | cut -d ' ' -f 2)

			mkdir "$DESTDIR/usr/lib/m68000"
			find "$DESTDIR/usr/lib" -mindepth 1 -maxdepth 1 -not -name "m68000" -not -name "$target_dir_1" -not -name "$target_dir_2" -exec mv "{}" "$DESTDIR/usr/lib/m68000" \;
			find "$DESTDIR/usr/lib/$dir" -mindepth 1 -maxdepth 1 -exec mv "{}" "$DESTDIR/usr/lib" \;
			rmdir "$DESTDIR/usr/lib/$dir"
		fi

		# install pre-built binutils
		${MAKE} PATH="$INSTALL_DIR/$dir/bin:/usr/bin" CPU="$cpu" DESTDIR="$INSTALL_DIR/$dir" binutils || exit 1
		# build & install gcc
		${MAKE} PATH="$INSTALL_DIR/$dir/bin:/usr/bin" CPU="$cpu" TARGET=$target INSTALL_DIR="$INSTALL_DIR/$dir" gcc || exit 1
		# build & install mintbin
		${MAKE} PATH="$INSTALL_DIR/$dir/bin:/usr/bin" CPU="$cpu" TARGET=$target PREFIX="" DESTDIR="$INSTALL_DIR/$dir" mintbin || exit 1
	fi

	if [ $skip_native -eq 0 ] ; then
		${MAKE} PATH="$INSTALL_DIR/$dir/bin:/usr/bin" CPU="$cpu" TARGET=$target INSTALL_DIR="$INSTALL_DIR/$dir" OPT="$opt" binutils-atari gcc-atari mintbin-atari || exit 1
		${MAKE} PATH="$INSTALL_DIR/$dir/bin:/usr/bin" CPU="$cpu" TARGET=$target INSTALL_DIR="$INSTALL_DIR/$dir" strip-atari pack-atari || exit 1
	fi
 done
