# Xash3D for MiSTer

Half-Life on [MiSTer FPGA](https://github.com/MiSTer-devel/Main_MiSTer/wiki) as a hybrid core.

TODO: one paragraph: which source port the game is and where it comes from. It runs on the MiSTer's ARM CPU. The Xash3D FPGA core provides native 15kHz video (CRT, VGA and HDMI) at 320x200, 44.1kHz audio and keyboard, mouse and gamepad input. The two halves talk through shared DDR3 memory.

> **Beta.** Expect rough edges and please report problems in the issues.

Disclaimer: AI is being used to speed up development of this project.

## Requirements

- **danik_hybrid_cores**, the launcher that comes in the release zip (`Scripts/danik_hybrid_cores.sh`): run it **once** from the MiSTer's `Scripts` menu. It starts the game whenever the core is loaded, keeps running after a reboot, and serves all our hybrid cores. Every hybrid core brings the launcher along and the newest version is the one that runs, so it never has to be run again after an update. Without it the core only shows the MiSTer logo.
- **Game data**, which is not included: TODO which copy of the game.
- **A twin stick gamepad** (two analog sticks, like an Xbox or PlayStation controller): the left stick moves, the right stick looks around, and the d-pad is for weapons.

## Installation

1. Download the newest `Xash3D_YYYYMMDD.zip` from [releases](releases/) and extract it to the root of your SD card (`/media/fat`). That gives you:
   - `_Other/Xash3D_YYYYMMDD.rbf`, the FPGA core
   - `games/Xash3D/`, the game binary and its launcher
   - `Scripts/danik_hybrid_cores.sh`, the launcher (from [Hybrid_MiSTer](https://github.com/ItsDanik/Hybrid_MiSTer), which can also keep it up to date through `update_all`)
2. Copy the game data to `/media/fat/games/Xash3D/`: TODO which files, where.
3. Run **danik_hybrid_cores** from the `Scripts` menu, if you have not done so before (see Requirements).
4. Load **Xash3D** from the `Other` menu.

The game's log is in `/media/fat/logs/Xash3D/xash3d.log`. TODO: where settings and saved games are.

## OSD options

| Option | |
|---|---|
| Aspect ratio, Scale, Scandoubler Fx, Stereo Mix | as in other cores |
| FPS Counter | shows the pictures per second in the top left corner |
| HDMI Only | **Yes** if no CRT is connected: resolutions of 640x400 and more are then progressive instead of interlaced, and the analog output is switched off while one is shown, so that a 15kHz screen can never get such a signal. Nothing changes at lower resolutions. Not needed with `forced_scandoubler=1` (VGA monitor); not there with `direct_video=1` |
| CRT Options | for a 15kHz screen: *Horizontal Size*, *Horizontal Pos* and *Vertical Pos* fit the picture to it. The pixels stay as they are; HDMI is not affected. Not there with `forced_scandoubler=1` |
| Resolution | the game in **320x200** (default) or 320x240. The menus are always 640x480. Applies at once |
| Lock to 30 FPS | **On**: a picture every second field, an even 30 per second where the game cannot keep up with 60. **Off** (default): up to 60 |
| Cheats | *God Mode*, *No Clip* (fly through walls) and *Invisible to Monsters* stay on while they are on, through saved games and level changes, and are gone when turned off. *Give All Weapons* gives the suit, armour, every weapon of the game and ammo for them |
| Menu OK, Menu Back | the gamepad button that confirms / goes back in the game's menus, whatever it does in the game. **MiSTer** (default) uses the OK/Back buttons of your MiSTer menu |

## Controls

- **Keyboard and mouse:**

| Key | Action |
|---|---|
| TODO | |

- **Gamepad** (default mapping):

| Button | Action |
|---|---|
| Left stick | move and strafe |
| Right stick | look around |
| Left stick click (L3) | walk / run, toggles |
| Right stick click (R3) | flashlight on / off |
| D-pad left / right | previous / next weapon |
| D-pad up | last weapon used |
| D-pad down | spray your logo |
| A (Xbox B / PlayStation Circle) | jump, swim up |
| B (Xbox A / PlayStation Cross) | duck, swim down |
| X (Xbox Y / PlayStation Triangle) | use |
| Y (Xbox X / PlayStation Square) | reload |
| L (LB / L1), L2 | secondary attack |
| R (RB / R1), R2 | primary attack |
| Select | next weapon |
| Start | menu |

The stick clicks and the analog triggers are read straight from the controller, so they work without being assigned in MiSTer's button setup (the stick clicks with controllers that report them as standard gamepad buttons, as Xbox and PlayStation controllers do). The game's own *Controls* menu changes the buttons too, and keeps what you set there.

Change the buttons in the OSD under *Define Xash3D buttons*. *Menu OK* and *Menu Back* there are only needed for a button without a game function; MiSTer doesn't let you assign a button twice, so to confirm with a button that also has a game function, pick it in the OSD's Menu OK/Menu Back options instead.

## Building

Everything builds in Docker on a Linux PC.

```sh
git clone --recursive https://github.com/ItsDanik/Xash3D_MiSTer.git
cd Xash3D_MiSTer
./build.sh              # ARM game binary  -> build/mister/xash3d
./core/build_core.sh    # FPGA core (Quartus Lite 17.0.2) -> core/output_files/Xash3D.rbf
./package.sh            # release zip      -> dist/Xash3D_YYYYMMDD.zip
```

The toolchain image (Debian bullseye, glibc 2.31 to match the MiSTer) is built from `hybrid/toolchain/` on first use. The first build also downloads and builds SDL2, SDL2_mixer and SDL2_net.

### Repository layout

| Path | |
|---|---|
| `hybrid/` | submodule: [ItsDanik/Hybrid_MiSTer](https://github.com/ItsDanik/Hybrid_MiSTer), what all our hybrid cores share: the FPGA host module, the ARM side library, SDL2 drivers, the launcher (`danik_hybrid_cores.sh`), toolchain and conventions. See its README. |
| `core/` | FPGA core, based on [Template_MiSTer](https://github.com/MiSTer-devel/Template_MiSTer): `Xash3D.sv` (OSD and button names) around `hybrid/rtl/hybrid_host.sv` |
| `xash3d/` | submodule: the game, branch `mister`, with the MiSTer changes |
| `package/` | files shipped in the release next to the binary (`danik_hybrid_launch.sh`, README) |
| `releases/` | release packages |

### Development notes

- `./build.sh host` builds the same game for the PC. It runs against `hybrid/tools/fakecore`, a stand-in for the FPGA core that takes scripted input and saves screenshots and audio:
  ```sh
  gcc -O2 -o build/host/fakecore hybrid/tools/fakecore.c
  build/host/fakecore /tmp/shm script.txt audio.raw &
  cd <data folder> && MISTER_HYBRID_SHM=/tmp/shm <repository>/build/host/xash3d
  ```
- `touch /tmp/xash3d_nolaunch` on the MiSTer keeps the core loaded without starting the game, so you can start a development binary by hand (set `MISTER_HYBRID_CORE=Xash3D`). `/tmp/danik_hybrid_cores.log` shows what the launcher daemon did.

## Support

If you enjoy this project, you can support my work on [Patreon](https://www.patreon.com/itsdanik).

## Credits

- **TODO the game / source port** by its authors.
- **[SDL](https://libsdl.org)** by Sam Lantinga and contributors.
- **[MiSTer](https://github.com/MiSTer-devel)** by Sorgelig and the MiSTer-devel contributors: the framework and Template_MiSTer.
- **[MiSTer Frontier](https://github.com/MiSTerOrganize/MiSTer_Frontier)** by MiSTer Organize: thank you for the inspiration. Hybrid cores on the MiSTer, and the way their game is launched (a daemon that watches the loaded core and runs a script from its games folder), come from MiSTer Frontier. Our launcher is a separate implementation and does not need MiSTer Frontier installed.

This project and its maintainers are in no way associated with or endorsed by TODO the rights holders. It does not include any game data.

## License

The top-level scripts, tools and documentation are licensed under the [GPL-3.0](LICENSE). The components keep their own licenses: the shared framework in `hybrid/` is GPL-3.0 except where its files say otherwise, TODO the game's license, SDL and the SDL drivers in `hybrid/sdl2` are zlib, the FPGA core and the MiSTer framework are GPL-2.0 (`core/LICENSE`, with the core's own sources GPL-2.0-or-later).
