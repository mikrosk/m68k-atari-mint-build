#!/bin/bash

INSTALL_DIR="$HOME/gnu-tools"
CPU_DIRS=("m68000"	"m68020-60"	"m5475")	# target directory
CPU_OPTS=("m68000"	"m68020-60"	"mcpu=5475")	# gcc command line
CPU_CPUS=("m68000"	"m68020-60"	"5475")		# --with-cpu=

indices=""
indices_all=$(seq 0 $((${#CPU_DIRS[@]} - 1)))
skip_native=0

# parse command line
for arg in $*
do
	case $arg in
	-h|--help)
	echo "Usage : $0 [options] <target cpu list>"
	echo "Options :"
	echo "   --help :        display this help"
	echo "   --skip-native : do not build native compiler(s)"
	echo "   --all:          build for all CPU targets (${CPU_CPUS[*]})"
	exit 0
	;;
	--skip-native)
	skip_native=1
	;;
	--all)
	indices=$indices_all
	;;
	*)
	ok=0
	for i in $(seq 0 $((${#CPU_DIRS[@]} - 1))) ; do
		if [ "$arg" == "${CPU_CPUS[i]}" ] ; then
			indices="$indices $i"
			ok=1
		fi
	done
	if [ $ok -eq 0 ] ; then
		echo "Error : $arg is not a valid CPU."
		echo "Valid CPU are : ${CPU_CPUS[*]}"
		exit 1
	fi
	;;
	esac
done

if [ -z $indices ] ; then
	echo "No CPU to build. use $0 --help"
	exit 1
fi


for i in $indices
do
	dir="${CPU_DIRS[i]}"
	cpu="${CPU_CPUS[i]}"
	
	multilib_opts="$(echo "${CPU_OPTS[@]}" | sed "s/${CPU_OPTS[i]}//;" | xargs | tr ' ' '/') mshort"
	multilib_dirs="$(echo "${CPU_DIRS[@]}" | sed "s/${CPU_DIRS[i]}//;" | xargs) mshort"
	${MAKE} gcc-multilib-patch OPTS="$multilib_opts" DIRS="$multilib_dirs" || exit 1
	
	${MAKE} binutils gcc-preliminary INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1

	# build mintlib and pml for all targets
	for j in $indices_all
	do
		target="${CPU_DIRS[j]}"
		prefix="$INSTALL_DIR/$dir/m68k-atari-mint"
		if [ "$target" == "$dir" ]
		then
			target=""
		fi
		${MAKE} mintlib prefix="$prefix" libdir="$prefix/lib/$target" cflags="-${CPU_OPTS[j]}" INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
		${MAKE} pml OPTS="-${CPU_OPTS[j]}" DIR="$target" INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
	done
	${MAKE} gcc mintbin INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
	
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
	
done

if [ $skip_native -eq 0 ] ; then
	${MAKE} strip-atari INSTALL_DIR="$INSTALL_DIR/${CPU_DIRS[0]}"	# use either 'strip'

	for i in $indices
	do
		cpu="${CPU_CPUS[i]}"
		${MAKE} pack-atari INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
	done

fi
