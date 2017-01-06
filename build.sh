#!/bin/sh

if [ -z "${INSTALL_DIR}" ] ; then
	INSTALL_DIR="$HOME/gnu-tools"
fi

CPU_DIRS="m68000 m68020-60 m5475"	# target directory
CPU_OPTS="m68000 m68020-60 mcpu=5475"	# gcc command line
CPU_CPUS="m68000 m68020-60 5475"		# --with-cpu=
CPU_COUNT=$(echo ${CPU_DIRS} | tr ' ' '\n' | wc -l)

indices=""
indices_all=""
i=1
while [ "$i" -le "${CPU_COUNT}" ] ; do
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
	while [ "$i" -le "${CPU_COUNT}" ] ; do
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
	echo "No CPU to build."
	exit 1
fi

for i in $indices
do
	dir=$(echo $CPU_DIRS | cut -d ' ' -f $i)
	cpu=$(echo $CPU_CPUS | cut -d ' ' -f $i)

	if [ $clean -eq 0 ]; then
		if [ $native_only -eq 0 ] ; then
			multilib_opts="$(echo "${CPU_OPTS[@]}" | sed "s/${CPU_OPTS[i]}//;" | xargs | tr ' ' '/') mshort"
			multilib_dirs="$(echo "${CPU_DIRS[@]}" | sed "s/${CPU_DIRS[i]}//;" | xargs) mshort"
			${MAKE} gcc-multilib-patch OPTS="$multilib_opts" DIRS="$multilib_dirs" || exit 1

			${MAKE} binutils gcc-preliminary mintbin INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1

			# build mintlib and pml for all targets
			for j in $indices_all
			do
				target=$(echo $CPU_DIRS | cut -d ' ' -f $j)
				prefix="$INSTALL_DIR/$dir/m68k-atari-mint"
				if [ "$target" == "$dir" ]
				then
					target=""
				fi
				opts=$(echo $CPU_OPTS | cut -d ' ' -f $j)
				${MAKE} mintlib prefix="$prefix" libdir="$prefix/lib/$target" cflags="-$opts" INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
				${MAKE} pml OPTS="-$opts" DIR="$target" INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
			done
			${MAKE} gcc INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
		fi

		if [ $skip_native -eq 0 ] ; then
			${MAKE} binutils-atari INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
			if [ "$cpu" == "5475" ]
			then
				assembly="--disable-assembly"
			else
				assembly=""
			fi
			${MAKE} gcc-atari ASSEMBLY="$assembly" INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
		fi
	else
		if [ $native_only -eq 0 ] ; then
			${MAKE} clean-cross CPU="$cpu" || exit 1
		fi

		if [ $skip_native -eq 0 ] ; then
			${MAKE} clean-atari CPU="$cpu" || exit 1
		fi
	fi
done

if [ $skip_native -eq 0 ] && [ $clean -eq 0 ] ; then
	# use either 'strip'
	i=$(echo $indices | cut -d " " -f 1)
	dir=$(echo $CPU_DIRS | cut -d " " -f $i)
	${MAKE} strip-atari INSTALL_DIR="$INSTALL_DIR/$dir"

	for i in $indices
	do
		cpu=$(echo $CPU_CPUS | cut -d ' ' -f $i)
		${MAKE} pack-atari INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
	done

fi
