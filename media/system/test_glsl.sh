#!/bin/bash

if [ "$#" != 1 ] ; then
    echo "Usage: $0 <shader-name>" >&2
    exit 1
fi

SHADER="$1"

make -C ~/gritengine/grit_core/linux gsl.linux.x86_64 || exit 1
gsl ${SHADER}.{vert,frag}.gsl glsl ${SHADER}.{vert,frag}.out || exit 1
for i in ${SHADER}.{vert,frag}.out ; do
    nl -b a $i
done
echo "Checking vertex shader: "
glsl_check vert ${SHADER}.vert.out
echo "Checking fragment shader: "
glsl_check frag ${SHADER}.frag.out
