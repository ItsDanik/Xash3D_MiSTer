#!/bin/sh
# Profile guided optimisation: build the engine with counters, run the
# benchmark's scenes with it on a MiSTer (tools/benchmark.sh), fetch the counts
# into build/pgo and build the engine again with them (build.sh, PGO=use).
# Run it again when the engine has changed much: a function whose code is no
# longer what was counted is optimised as without a profile.
# usage: MISTER=root@<address> tools/pgo.sh
set -e
cd "$(dirname "$0")/.."
HOST=${MISTER:?set MISTER=root@<address of the MiSTer>}
PGO=generate ./build.sh mister
cp build/mister/xash3d build/bench/pgo-generate.bin
ssh "$HOST" 'rm -rf /tmp/xash3d-pgo' 2>/dev/null
# the counts are written when the game quits; the scenes add up
BENCH_BIN=build/bench/pgo-generate.bin tools/benchmark.sh pgo
rm -rf build/pgo
mkdir -p build/pgo
ssh "$HOST" 'cd /tmp/xash3d-pgo && tar cf - .' 2>/dev/null | tar xf - -C build/pgo
ssh "$HOST" 'rm -rf /tmp/xash3d-pgo' 2>/dev/null
[ -n "$(find build/pgo -name '*.gcda' | head -1)" ] || { echo "no counts came back" >&2; exit 1; }
PGO=use ./build.sh mister
