# Xash3D hybrid core for MiSTer (Half-Life)

@hybrid/CLAUDE.md

## This core

- Name everywhere: `Xash3D` (core, folders, release), `xash3d` (game submodule, binary in `build/`, log, lock).
- The game is the `xash3d/` submodule, branch `mister`. Its MiSTer code is behind the `MISTER_HYBRID` build option.
- Build: `./build.sh` (game), `./core/build_core.sh` (FPGA), `./package.sh` (zip in `dist/`), `MISTER=root@<address> tools/deploy.sh`.
- Lines marked `GAME:` in the scripts and `TODO` in the READMEs are the places the template left for this game.

<!-- Notes that are only true for this game go below. -->

- Not on GitHub yet (Danik, 2026-10-14: local only): `xash3d/` is a plain clone of FWGS/xash3d-fwgs on a local branch `mister`, `hlsdk/` a clone of FWGS/hlsdk-portable, neither is a submodule. The forks, their `mister` branches and the core repository are still to be made; ask first.
- The engine is built with waf, not CMake (`build.sh`). `--static-linking=filesystem_stdio,ref_soft,menu` puts the engine's own libraries into the one binary, which has no position independent code and takes the static SDL2; `--mister-hybrid` (`MISTER_HYBRID`) keeps `dlopen` for the games' libraries (`engine/platform/misc/lib_static.c`, `posix/lib_posix.c`). A library that is linked in needs an `exports.txt` beside its `wscript`.
- The renderer is `ref/soft` (RGB565 through the window surface). No GPU, so `ref/gl` is not built.
- Each game has a folder next to the binary (`valve`, `bshift`, `gearbox`) and its client and server libraries come from a branch of hlsdk-portable (`build.sh`: folder, branch, server library name). The server library is named after `gamedll` in the game's `liblist.gam`, which is `hl.dll` for Blue Shift as well.
- `valve/extras.pk3` is the engine's own menu graphics and fonts (built with the engine), not game data: it is shipped.
- The MiSTer file is `xash3d/engine/platform/mister/mister_port.[ch]`. `MISTER_HYBRID_FPSLOG=1` logs the frames shown every 300 fields.
- Tests on the PC: game data pulled from the MiSTer into `data/` (ignored), `XASH3D_BASEDIR=$PWD/data MISTER_HYBRID_SHM=<file> build/host/xash3d -game bshift -ref soft -width 320 -height 200 +map ba_tram1` with `build/tools/fakecore <file> <script>`.
- Measured on the MiSTer, 2026-10-14, at 320x200: Blue Shift `ba_tram1` 34 to 58 frames per second, Half-Life `c1a0` (standing at the start) 45 to 50; 120MB of memory.
- Video: the menu and the console are 640x480 (interlaced on a 15kHz screen), the game is 320x200; `VID_MiSTerMode()` in `engine/client/vid_common.c` switches when the menu opens and closes (Danik's choice, 2026-10-14). The field of view and the software renderer's `yscale` take every mode as a 4:3 screen, so 320x200 is not stretched.
- Pad: `MiSTer_AddMappings()` in `engine/platform/sdl2/joy_sdl2.c` makes the core's joysticks SDL game controllers (J1 order = a, b, x, y, leftshoulder, rightshoulder, back, start; Menu OK / Back are the paddles and become Enter / Escape outside the game). The default bindings are the `MISTER_HYBRID` block of `engine/client/input/in_keys.c` and survive the `unbindall` of a `config.cfg` that came with the game.
- *Lock to 30 FPS* is status bit 24 and is this core's own, as in OpenScreamer (bit 28) and Dethrace (bit 26): the framework has no such switch. Written and built, not yet tried on a MiSTer.
- The game list (`MiSTer_SelectGame()`, before the engine starts) shows the folders that have a `liblist.gam` and our client library; `valve` has to be there for any of them.
- The engine prints nothing without `-console` or `-dev`; with `MISTER_HYBRID` `Con_Printf` always prints, so the launcher's log has it.
- Still open: every `TODO` of the READMEs; the menu has no entry selected until the d-pad is pressed once; colour codes in the log; music, saved games, keyboard and mouse were not tried on the MiSTer; Opposing Force and Blue Shift were started, not played.
