#!/bin/sh
# Build Half-Life for the MiSTer in the toolchain container: static SDL2 with the
# hybrid core drivers first (once), then the engine and the libraries of the games.
# usage: ./build.sh [mister|host]
#   mister  ARM binary for the MiSTer     -> build/mister/xash3d
#   host    same code for this PC, to run against hybrid/tools/fakecore
# The games' libraries end up in build/<target>/games/<game folder>/.
set -e
cd "$(dirname "$0")"
TARGET=${1:-mister}
ROOT=$PWD
PREFIX=$ROOT/build/sdl/$TARGET/prefix
OUT=build/$TARGET

hybrid/docker.sh hybrid/sdl2/build.sh "$TARGET" build/sdl

# GAME: Xash3D FWGS is built with waf. The engine, its filesystem, the software
# renderer and the menu are one binary without position independent code
# (--static-linking, and MISTER_HYBRID keeps the loader for the games' libraries).
if [ "$TARGET" = mister ]; then
    FLAGS="-mcpu=cortex-a9 -mfpu=neon -mfloat-abi=hard -fno-pie"
    # the compiler's runtime is linked in, the binary only needs the MiSTer's glibc
    LINK="-no-pie -static-libstdc++ -static-libgcc"
    X=arm-linux-gnueabihf
    TOOLS="CC=$X-gcc CXX=$X-g++ AR=$X-ar LD=$X-ld OBJCOPY=$X-objcopy STRIP=$X-strip"
    BITS=
    CMAKE_CROSS="-DCMAKE_TOOLCHAIN_FILE=$ROOT/hybrid/toolchain/mister.cmake"
    CMAKE_LINK="-static-libstdc++ -static-libgcc"
else
    FLAGS="-fno-pie"
    LINK="-no-pie"
    TOOLS=
    BITS="-8"
    CMAKE_CROSS="-D64BIT=ON"
    CMAKE_LINK=
fi

hybrid/docker.sh sh -c "
  cd xash3d &&
  env $TOOLS CFLAGS='$FLAGS' CXXFLAGS='$FLAGS' LINKFLAGS='$LINK' \
      PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig \
    ./waf configure -o ../$OUT/engine -T release $BITS --mister-hybrid \
      --enable-soft --disable-gl --enable-stbtt --sdl-use-pkgconfig --disable-werror \
      --static-linking=filesystem_stdio,ref_soft,menu > ../$OUT-configure.log 2>&1 &&
  ./waf build" || { tail -30 "$OUT-configure.log"; exit 1; }
cp "$OUT/engine/engine/xash" "$OUT/xash3d"

# GAME: the client and server libraries of each game, from the branches of
# hlsdk-portable: <game folder>:<branch>:<server library>. The engine names the
# server library after the "gamedll" of the game's liblist.gam, which is hl.dll
# for Blue Shift too.
mkdir -p build/hlsdk-src
for g in valve:master:hl bshift:bshift:hl gearbox:opfor:opfor; do
    DIR=${g%%:*}
    SERVER=${g##*:}
    BRANCH=${g#*:}
    BRANCH=${BRANCH%:*}
    SRC=hlsdk
    if [ "$BRANCH" != master ]; then
        SRC=build/hlsdk-src/$BRANCH
        if [ ! -d "$SRC" ]; then
            git -C hlsdk worktree add -q --detach "../$SRC" "origin/$BRANCH"
            git -C "$SRC" submodule update -q --init --reference "$ROOT/hlsdk/freevgui"
        fi
    fi
    hybrid/docker.sh sh -c "
      cmake -S $SRC -B $OUT/hlsdk/$DIR -DCMAKE_BUILD_TYPE=Release $CMAKE_CROSS \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_SHARED_LINKER_FLAGS='$CMAKE_LINK' \
        -DSERVER_LIBRARY_NAME=$SERVER -DCMAKE_INSTALL_PREFIX=$ROOT/$OUT/games > $OUT-hlsdk-$DIR.log 2>&1 &&
      cmake --build $OUT/hlsdk/$DIR -j\$(nproc) >> $OUT-hlsdk-$DIR.log 2>&1 &&
      cmake --install $OUT/hlsdk/$DIR >> $OUT-hlsdk-$DIR.log 2>&1" || { tail -30 "$OUT-hlsdk-$DIR.log"; exit 1; }
done
ls -la "$OUT/xash3d" "$OUT"/games/*/*/*.so
