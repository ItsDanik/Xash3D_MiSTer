#!/bin/sh
# Assemble the MiSTer release in dist/Xash3D_<date>/ from the build outputs
set -e
cd "$(dirname "$0")"
DATE=$(date +%Y%m%d)
OUT=dist/Xash3D_$DATE
rm -rf "$OUT"
mkdir -p "$OUT/_Other" "$OUT/games/Xash3D" "$OUT/Scripts"
cp hybrid/launcher/danik_hybrid_cores.sh "$OUT/Scripts/danik_hybrid_cores.sh"
# a copy with the game too: the daemon installs the newest one it finds
cp hybrid/launcher/danik_hybrid_cores.sh "$OUT/games/Xash3D/danik_hybrid_cores.sh"
cp core/output_files/Xash3D.rbf "$OUT/_Other/Xash3D_$DATE.rbf"
cp -r package/games/Xash3D/. "$OUT/games/Xash3D/"
cp build/mister/xash3d "$OUT/games/Xash3D/Xash3D"
# GAME: files the binary needs next to it (never game data): the libraries of
# the games in their folders, and the engine's own menu graphics and fonts
cp -r build/mister/games/. "$OUT/games/Xash3D/"
cp build/mister/engine/3rdparty/extras/extras.pk3 "$OUT/games/Xash3D/valve/extras.pk3"
hybrid/docker.sh sh -c "arm-linux-gnueabihf-strip $OUT/games/Xash3D/*/*/*.so"
hybrid/docker.sh arm-linux-gnueabihf-strip "$OUT/games/Xash3D/Xash3D"
chmod +x "$OUT/games/Xash3D/Xash3D" "$OUT"/games/Xash3D/*.sh "$OUT/Scripts/danik_hybrid_cores.sh"
# GAME: the engine is GPL-3 (LICENSE-gpl3.txt), the games' libraries have Valve's SDK license
cp hlsdk/LICENSE "$OUT/games/Xash3D/LICENSE-hlsdk.txt"
cp build/sdl/src/SDL2-*/LICENSE.txt "$OUT/games/Xash3D/LICENSE-sdl.txt"
cp LICENSE "$OUT/games/Xash3D/LICENSE-gpl3.txt"
rm -f "dist/Xash3D_$DATE.zip"
(cd "$OUT" && python3 -m zipfile -c "../Xash3D_$DATE.zip" _Other games Scripts)
find "$OUT" -type f | sort
ls -la "dist/Xash3D_$DATE.zip"
