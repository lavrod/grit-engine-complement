#!/bin/bash

if [ "$#" != 1 ] ; then
    echo "Usage: $0 <shader-name>" >&2
    exit 1
fi

SHADER="$1"

make -C ~/gritengine/grit_core/linux gsl.linux.x86_64 &&
gsl ${SHADER}.{vert,frag}.gsl cg ${SHADER}.{vert,frag}.out &&
for i in ${SHADER}.{vert,frag}.out ; do
    nl -b a $i
done &&
cgc -profile gpu_vp -strict ${SHADER}.vert.out &&
cgc -profile gpu_fp -strict ${SHADER}.frag.out
