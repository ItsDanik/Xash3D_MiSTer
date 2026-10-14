#!/bin/sh
# The standard set of scenes for tools/bench.sh: a map each, the player standing
# where the map starts him, 40 seconds, the frame log only. Prints the frames
# per second and the milliseconds per stage of each (tools/benchsum.py).
# usage: MISTER=root@<address> tools/benchmark.sh <name> [<environment for the game>]
#   e.g. tools/benchmark.sh base
#        tools/benchmark.sh lock MISTER_HYBRID_LOCK30=1
# Logs: build/bench/<name>-<scene>.log. BENCH_SCENES="<scene>:<map> ..." for other maps ("-" for none but light).
#   calm      c1a0   the start of the game: a lobby, two scientists and a guard
#   tram      c0a0   the ride in: large outdoor views, nothing that thinks
#   monsters  c2a4a  many things that move and think: the game's logic is most of the frame
#   glass     c1a1b  a pane of glass right in front, monsters near, rotating brushes; the player starts
#                    stuck in something here: the game's PM_CheckStuck costs about 4ms a frame
#   models    c1a1f  a hall with a desk, glass and bodies
#   water     c2a2a  a channel of water along a corridor
#   light     c1a0 with the flashlight on (keys I for the suit and F, after 15 and 17 seconds): a
#             dynamic light on everything ahead
set -e
cd "$(dirname "$0")/.."
NAME=${1:?usage: tools/benchmark.sh <name> [<environment>]}
shift
export BENCH_NOPROFILE=1 BENCH_ENV="MISTER_HYBRID_LOCK30=0 $*"
LOGS=
for S in ${BENCH_SCENES:-calm:c1a0 tram:c0a0 monsters:c2a4a glass:c1a1b models:c1a1f water:c2a2a}; do
    [ "$S" != - ] || continue
    tools/bench.sh "$NAME-${S%%:*}" 40 valve +map "${S#*:}" > /dev/null 2>&1
    LOGS="$LOGS build/bench/$NAME-${S%%:*}.log"
done
BENCH_GRAB=${BENCH_GRAB:+30}
# the flashlight comes with the suit, which the player does not have yet in this map: cheat for it
# (a file in the game's folder for the time of the run; bench.sh starts the game with -nowriteconfig)
HOST=${MISTER:?set MISTER=root@<address of the MiSTer>}
CFG=/media/fat/games/Xash3D/valve/mister_bench.cfg
ssh "$HOST" "printf 'sv_cheats 1\nbind i \"impulse 101\"\nbind f \"impulse 100\"\n' > $CFG" 2>/dev/null
BENCH_KEYS='"15000 23 100" "17000 33 100"' tools/bench.sh "$NAME-light" 40 valve +exec mister_bench.cfg +map c1a0 > /dev/null 2>&1
ssh "$HOST" "rm -f $CFG" 2>/dev/null
tools/benchsum.py $LOGS "build/bench/$NAME-light.log"
