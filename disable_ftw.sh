#!/bin/sh

mkdir gcc
cat <<EOF >gcc/config.cache
ac_cv_header_ftw_h=no
EOF
