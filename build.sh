#!/bin/sh

set -e

target=m68k-atari-mintelf

if [ -z "${INSTALL_DIR}" ] ; then
	INSTALL_DIR="$HOME/gnu-tools"
fi

CPU_DIRS="m68000 m68020-60 m5475"	# target directory
CPU_OPTS="m68000 m68020-60 mcpu=5475"	# gcc command line
CPU_CPUS="m68000 m68020-60 5475"	# --with-cpu=
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
clean=0

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
	--clean)
	clean=1
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

for i in $indices
do
	dir=$(echo $CPU_DIRS | cut -d ' ' -f $i)
	cpu=$(echo $CPU_CPUS | cut -d ' ' -f $i)
	opt=$(echo $CPU_OPTS | cut -d ' ' -f $i)

	simple_cpu=$(echo $cpu | cut -d '-' -f 1)
	
	# first index must be native to the compiler
	while [ "$(echo $indices_all | cut -d ' ' -f 1)" != "$i" ]
	do
		first=$(echo $indices_all | cut -d ' ' -f 1)
		middle=$(echo $indices_all | cut -d ' ' -f 2-$((CPU_COUNT-1)))
		last=$(echo $indices_all | cut -d ' ' -f $CPU_COUNT)
		indices_all="$middle $last $first"
	done

	if [ $clean -eq 0 ]; then
		if [ $native_only -eq 0 ] ; then
			${MAKE} TARGET=$target binutils gcc-preliminary mintbin INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1

			# build default mintlib/fdlibm (all their flavours *must* use explicit cpu specification on the command line, e.g. -m68000)
			DESTDIR="$INSTALL_DIR/$dir/$target/sys-root"
			${MAKE} TARGET=$target mintlib DESTDIR="$DESTDIR" INSTALL_DIR="$INSTALL_DIR/$dir" || exit 1
			${MAKE} TARGET=$target fdlibm  DESTDIR="$DESTDIR" INSTALL_DIR="$INSTALL_DIR/$dir" || exit 1

			# remove mintlib m68000 leftovers
			rm -r "$DESTDIR/sbin"
			rm -r "$DESTDIR/usr/sbin"

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

			${MAKE} TARGET=$target gcc INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
		fi

		if [ $skip_native -eq 0 ] ; then
			${MAKE} TARGET=$target binutils-atari INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" OPT="$opt" || exit 1
			${MAKE} TARGET=$target gcc-atari      INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" OPT="$opt" || exit 1
			${MAKE} TARGET=$target strip-atari    INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
			${MAKE} TARGET=$target pack-atari     INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
		fi
	else
		if [ $native_only -eq 0 ] ; then
			${MAKE} TARGET=$target clean-cross CPU="$cpu" || exit 1
		fi

		if [ $skip_native -eq 0 ] ; then
			${MAKE} TARGET=$target clean-atari CPU="$cpu" || exit 1
		fi
	fi
done
