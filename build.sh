#!/bin/bash

INSTALL_DIR="$HOME/gnu-tools"
CPU_DIRS=("m68000"	"m68020-60"	"m5475")	# target directory
CPU_OPTS=("m68000"	"m68020-60"	"mcpu=5475")	# gcc command line
CPU_CPUS=("m68000"	"m68020-60"	"5475")		# --with-cpu=

indices=$(seq 0 $((${#CPU_DIRS[@]} - 1)))

for i in $indices
do
	dir="${CPU_DIRS[i]}"
	cpu="${CPU_CPUS[i]}"
	
	multilib_opts="$(echo "${CPU_OPTS[@]}" | sed "s/${CPU_OPTS[i]}//;" | xargs | tr ' ' '/') mshort"
	multilib_dirs="$(echo "${CPU_DIRS[@]}" | sed "s/${CPU_DIRS[i]}//;" | xargs) mshort"
	${MAKE} gcc-multilib-patch OPTS="$multilib_opts" DIRS="$multilib_dirs" || exit 1
	
	${MAKE} binutils gcc-preliminary INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
	for j in $indices
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
	
	${MAKE} binutils-atari INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
	if [ "$cpu" == "5475" ]
	then
		assembly="--disable-assembly"
	else
		assembly=""
	fi
	${MAKE} gcc-atari ASSEMBLY="$assembly" INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
	
done

${MAKE} strip-atari INSTALL_DIR="$INSTALL_DIR/${CPU_DIRS[0]}"	# use either 'strip'

for i in $indices
do
	cpu="${CPU_CPUS[i]}"
	${MAKE} pack-atari INSTALL_DIR="$INSTALL_DIR/$dir" CPU="$cpu" || exit 1
done
