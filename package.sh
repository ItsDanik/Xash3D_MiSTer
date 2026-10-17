#!/bin/sh
# Assemble the MiSTer release in dist/Xash3D_<date>/ from the build outputs,
# in the layout of the hybrid ports (hybrid/README.md, "Naming and layout"):
#   _Other/dnk-<title>.mgl             a menu entry for each game (package/games.txt)
#   _Other/dnk/dnk-Xash3D_<date>.rbf    the core, not in the menu itself
#   games/dnk/Xash3D/                   the game
#   Scripts/danik_hybrid_ports.sh       the launcher, and its screen in
#   Scripts/.danik_hybrid_ports/        (copies of both with the game: the
#                                       newest one installed is the one used)
#   games/dnk/danik_hybrid_cores.sh     the last version of the launcher before,
#                                       which hands a running one over to it
#   downloader_danik_hybrid_ports.ini   the database for update_all, which
#                                       keeps the ports up to date from then on
set -e
cd "$(dirname "$0")"
DATE=$(date +%Y%m%d)
OUT=dist/Xash3D_$DATE
G=$OUT/games/dnk/Xash3D
rm -rf "$OUT"
mkdir -p "$OUT/_Other/dnk" "$G" "$OUT/Scripts/.danik_hybrid_ports"

# the launcher and its screen
sh hybrid/launcher/ui/build.sh > /dev/null
cp hybrid/launcher/danik_hybrid_ports.sh "$OUT/Scripts/danik_hybrid_ports.sh"
cp hybrid/launcher/ui/danik_hybrid_ports_ui "$OUT/Scripts/.danik_hybrid_ports/danik_hybrid_ports_ui"
cp hybrid/launcher/danik_hybrid_ports.sh hybrid/launcher/ui/danik_hybrid_ports_ui "$G/"
cp hybrid/launcher/danik_hybrid_cores.sh "$OUT/games/dnk/danik_hybrid_cores.sh"
cp hybrid/launcher/downloader_danik_hybrid_ports.ini "$OUT/"

# the core, and a menu entry for each game: package/games.txt, a line each,
# <id>|<title>. With several games each entry loads the core with the set
# name Xash3D_<id> (the game's settings and button mappings are its own);
# one game has no set name. The title is the entry's name in the menu,
# without what a file name cannot have.
cp core/output_files/Xash3D.rbf "$OUT/_Other/dnk/dnk-Xash3D_$DATE.rbf"
GAMES=$(grep -v '^#' package/games.txt | grep -c '|')
grep -v '^#' package/games.txt | grep '|' | while IFS='|' read -r id title; do
    set_name=Xash3D_$id
    [ ${#set_name} -lt 32 ] || { echo "the set name $set_name is too long (31 at most)" >&2; exit 1; }
    file=$(printf %s "$title" | tr -d ':*?"<>|/\\' | tr -s ' ')
    if [ "$GAMES" -gt 1 ]; then
        set_line="<setname same_dir=\"1\">$set_name</setname>"
    else
        set_line=
    fi
    printf '<mistergamedescription><rbf>_Other/dnk/dnk-Xash3D</rbf>%s</mistergamedescription>\n' "$set_line" \
        > "$OUT/_Other/dnk-$file.mgl"
done

# the game, and its games for the database's catalogue (the launcher's
# screen offers what that has) and for the launcher without one
cp -r package/games/Xash3D/. "$G/"
grep -v '^#' package/games.txt | grep '|' > "$G/games.txt"
cp build/mister/xash3d "$G/Xash3D"
cp build/mister/mh_message "$G/mh_message"
# the libraries of the games in their folders (valve, bshift, gearbox), and
# the engine's own menu graphics and fonts (never game data)
cp -r build/mister/games/. "$G/"
cp build/mister/engine/3rdparty/extras/extras.pk3 "$G/valve/extras.pk3"
hybrid/docker.sh sh -c "arm-linux-gnueabihf-strip $G/Xash3D $G/mh_message $G/*/*/*.so"
chmod +x "$G/Xash3D" "$G/mh_message" "$G"/*.sh "$G/danik_hybrid_ports_ui" \
    "$OUT/Scripts/danik_hybrid_ports.sh" "$OUT/Scripts/.danik_hybrid_ports/danik_hybrid_ports_ui" \
    "$OUT/games/dnk/danik_hybrid_cores.sh"
# the engine is GPL-3 (LICENSE-gpl3.txt), the games' libraries have Valve's SDK license
cp hlsdk/LICENSE "$G/LICENSE-hlsdk.txt"
cp build/sdl/src/SDL2-*/LICENSE.txt "$G/LICENSE-sdl.txt"
cp LICENSE "$G/LICENSE-gpl3.txt"
rm -f "dist/Xash3D_$DATE.zip"
(cd "$OUT" && python3 -m zipfile -c "../Xash3D_$DATE.zip" _Other games Scripts downloader_danik_hybrid_ports.ini)
find "$OUT" -type f | sort
ls -la "dist/Xash3D_$DATE.zip"
