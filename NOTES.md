# Xash3D for MiSTer: notes

How the port works and how it is built. For playing it, see the [README](README.md).

More pictures, taken on the MiSTer, are in [`docs/screenshots/`](docs/screenshots/).

## Building

Everything builds in Docker on a Linux PC.

```sh
git clone --recursive https://github.com/ItsDanik/Xash3D_MiSTer.git
cd Xash3D_MiSTer
./build.sh              # ARM engine and the games' libraries -> build/mister/
./core/build_core.sh    # FPGA core (Quartus Lite 17.0.2) -> core/output_files/Xash3D.rbf
./package.sh            # release zip      -> dist/Xash3D_YYYYMMDD.zip
```

The toolchain image (Debian bullseye, glibc 2.31 to match the MiSTer) is built from `hybrid/toolchain/` on first use. The first build also downloads and builds SDL2, SDL2_mixer and SDL2_net.

### Repository layout

| Path | |
|---|---|
| `hybrid/` | submodule: [ItsDanik/Hybrid_MiSTer](https://github.com/ItsDanik/Hybrid_MiSTer), what all our hybrid ports share: the FPGA host module, the ARM side library, SDL2 drivers, the launcher (`danik_hybrid_ports.sh`), toolchain and conventions. See its README. |
| `core/` | FPGA core, based on [Template_MiSTer](https://github.com/MiSTer-devel/Template_MiSTer): `Xash3D.sv` (OSD and button names) around `hybrid/rtl/hybrid_host.sv` |
| `xash3d/` | submodule: the engine, [our fork of Xash3D FWGS](https://github.com/ItsDanik/xash3d-fwgs), branch `mister`, with the MiSTer changes |
| `hlsdk/` | submodule: the games' code, [our fork of hlsdk-portable](https://github.com/ItsDanik/hlsdk-portable), as it is (`build.sh` takes the branches of Opposing Force and Blue Shift from it) |
| `package/` | files shipped in the release next to the binary (`danik_hybrid_launch.sh`, README), and `games.txt`: the games and their menu entries |
| `tools/` | `test_on_mister.sh`, `deploy.sh`, and the benchmark and profile guided optimisation of the engine (`benchmark.sh`, `pgo.sh`; see `CLAUDE.md`) |
| `releases/` | release packages |

### Development notes

- `./build.sh host` builds the same game for the PC. It runs against `hybrid/tools/fakecore`, a stand-in for the FPGA core that takes scripted input and saves screenshots and audio:
  ```sh
  gcc -O2 -o build/host/fakecore hybrid/tools/fakecore.c
  build/host/fakecore /tmp/shm script.txt audio.raw &
  cd <data folder> && MISTER_HYBRID_SHM=/tmp/shm MISTER_HYBRID_CORE=Xash3D XASH3D_BASEDIR=$PWD XASH3D_GAME=valve \
      <repository>/build/host/xash3d -ref soft -windowed +map c1a0
  ```
- `MISTER=root@<address> tools/test_on_mister.sh <id>` (`HL`, `OF`, `BS`) tries the build on a MiSTer next to what is installed there, without installing it: from `/tmp`, with the installed game's folder mirrored there (what the game writes stays in `/tmp`) and its own OSD settings. `list` and `nodata` for the core started by itself and without data, `log` for the game's log, `stop` to remove all of it again.
- `touch /tmp/xash3d_nolaunch` on the MiSTer keeps the core loaded without starting the game, so you can start a development binary by hand (set `MISTER_HYBRID_CORE=Xash3D`, and `MISTER_HYBRID_SET` for a game's set name, e.g. `Xash3D_OF`). `/tmp/danik_hybrid_ports.log` shows what the launcher daemon did.
