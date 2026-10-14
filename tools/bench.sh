#!/bin/sh
# Run the game on a MiSTer for a while with the frame log and the profiler on
# (MISTER_HYBRID_FPSLOG, MISTER_HYBRID_PROFILE: mister_port.h in the engine)
# and fetch both. The Xash3D core is loaded if it is not; a game that is
# running is stopped. The binary is build/mister/xash3d, copied as Xash3D.bench.
# usage: MISTER=root@<address> tools/bench.sh <name> <seconds> <game folder> <engine arguments>
#   e.g. tools/bench.sh c1a0 60 valve +map c1a0        -> build/bench/c1a0.log, c1a0.prof
# Environment for the game: BENCH_ENV="MISTER_HYBRID_HEIGHT=240 ..."; BENCH_NOPROFILE=1: the frame log only
set -e
cd "$(dirname "$0")/.."
HOST=${MISTER:?set MISTER=root@<address of the MiSTer>}
NAME=$1; SECS=$2; GAME=$3; shift 3
mkdir -p build/bench
G=/media/fat/games/Xash3D
BIN=${BENCH_BIN:-build/mister/xash3d} # BENCH_BIN=build/bench/<name>.elf: the binary of an earlier run
hybrid/docker.sh arm-linux-gnueabihf-strip -o build/bench/Xash3D.bench "$BIN"
# the profile is read with the symbols of the binary that made it
[ "$BIN" = "build/bench/$NAME.elf" ] || cp "$BIN" "build/bench/$NAME.elf"
scp -q build/bench/Xash3D.bench "$HOST:$G/Xash3D.bench"
cat > build/bench/run.sh <<END
#!/bin/bash
exec > /tmp/bench.out 2>&1
touch /tmp/xash3d_nolaunch
for p in \$(ps | grep "[.]/Xash3D" | awk '{print \$1}'); do kill \$p; done
sleep 3
grep -q Xash3D /tmp/CORENAME || { echo "load_core \$(ls /media/fat/_Other/Xash3D_*.rbf | tail -1)" > /dev/MiSTer_cmd; sleep 8; }
cd $G
export MISTER_HYBRID_CORE=Xash3D HOME=$G XASH3D_BASEDIR=$G XASH3D_GAME=$GAME
export MISTER_HYBRID_FPSLOG=1 $BENCH_ENV
[ -n "$BENCH_NOPROFILE" ] || export MISTER_HYBRID_PROFILE=/tmp/bench.prof
nice -n -20 taskset 0x03 ./Xash3D.bench -ref soft -windowed -nowriteconfig $* > /tmp/bench.log 2>&1 < /dev/null &
P=\$!
sleep $SECS
kill \$P
wait \$P
rm -f /tmp/xash3d_nolaunch
echo done
END
scp -q build/bench/run.sh "$HOST:/tmp/bench.sh"
ssh "$HOST" 'chmod +x /tmp/bench.sh; rm -f /tmp/bench.out /tmp/bench.prof; setsid nohup /tmp/bench.sh > /dev/null 2>&1 < /dev/null &' 2>/dev/null
sleep $((SECS + 16))
until ssh "$HOST" 'grep -q done /tmp/bench.out' 2>/dev/null; do sleep 2; done
scp -q "$HOST:/tmp/bench.log" "build/bench/$NAME.log"
[ -n "$BENCH_NOPROFILE" ] || scp -q "$HOST:/tmp/bench.prof" "build/bench/$NAME.prof"
grep -a "mister:.*frames" "build/bench/$NAME.log" | sed 's/^mister: //'
