Xash3D for MiSTer - Half-Life as a hybrid core
====================================================

The game (TODO which source port) runs on the MiSTer's ARM CPU; the Xash3D
FPGA core provides native 15kHz video (CRT, VGA and HDMI) at 320x200, audio
and input.

Disclaimer: AI is being used to speed up development of this project.

Requirements
  - danik_hybrid_cores, the launcher that comes with this release
    (Scripts/danik_hybrid_cores.sh): copy it to /media/fat/Scripts/ and run
    it ONCE from the MiSTer's Scripts menu. It starts the game whenever
    the core is loaded, keeps running after a reboot, and serves all our
    hybrid cores. Every hybrid core brings the launcher along and the
    newest version is the one that runs, so it never has to be run again
    after an update. Without it the core only shows the MiSTer logo.
  - Game data. It is not included: TODO which copy of the game.
  - A twin stick gamepad (two analog sticks, like an Xbox or PlayStation
    controller): the left stick moves, the right stick looks around, and
    the d-pad is for weapons.

Install
  1. Copy _Other/Xash3D_*.rbf to /media/fat/_Other/
  2. Copy games/Xash3D/ to /media/fat/games/Xash3D/
  3. Copy the game data to /media/fat/games/Xash3D/
       TODO which files, where
  4. Run danik_hybrid_cores from the Scripts menu, if you have not done so
     before (see Requirements).
  5. Load Xash3D from the Other menu.

OSD options
  Aspect ratio, Scale, Scandoubler Fx, Stereo Mix as in other cores.
  FPS Counter   shows the pictures per second in the top left corner.
  HDMI Only     Yes if no CRT is connected: resolutions of 640x400 and
                more are then progressive instead of interlaced, and the
                analog output is switched off while one is shown, so that a
                15kHz screen can never get such a signal. Nothing changes
                at lower resolutions. Not needed with forced_scandoubler=1
                (VGA monitor); not there with direct_video=1.
  CRT Options   for a 15kHz screen: Horizontal Size, Horizontal Pos and
                Vertical Pos fit the picture to it. The pixels stay as they
                are; HDMI is not affected. Not there with
                forced_scandoubler=1.
  Resolution    the game in 320x200 (default) or 320x240. The menus are
                always 640x480. Applies at once.
  Lock to 30 FPS
                On: a picture every second field, an even 30 per second
                where the game cannot keep up with 60. Off (default): up
                to 60.
  Cheats        God Mode, No Clip (fly through walls) and Invisible to
                Monsters stay on while they are on, through saved games
                and level changes, and are gone when turned off. Give All
                Weapons gives the suit, armour, every weapon of the game and
                ammo for them.
  Menu OK, Menu Back
                the gamepad button that confirms / goes back in the game's
                menus, whatever it does in the game. MiSTer (default) uses
                the OK/Back buttons of your MiSTer menu.

Controls
  Keyboard and mouse:
    TODO
  Gamepad (default mapping):
    Left stick                          move and strafe
    Right stick                         look around
    Left stick click (L3)               walk / run, toggles
    Right stick click (R3)              flashlight on / off
    D-pad left / right                  previous / next weapon
    D-pad up                            last weapon used
    D-pad down                          spray your logo
    A (Xbox B / PlayStation Circle)     jump, swim up
    B (Xbox A / PlayStation Cross)      duck, swim down
    X (Xbox Y / PlayStation Triangle)   use
    Y (Xbox X / PlayStation Square)     reload
    L (LB / L1), L2                     secondary attack
    R (RB / R1), R2                     primary attack
    Select                              next weapon
    Start                               menu
  The stick clicks and the analog triggers are read straight from the
  controller, so they work without being assigned in MiSTer's button setup
  (the stick clicks with controllers that report them as standard gamepad
  buttons, as Xbox and PlayStation controllers do). The game's own Controls
  menu changes the buttons too, and keeps what you set there.
  Change the buttons in the OSD under "Define Xash3D buttons". "Menu OK" and
  "Menu Back" there are only needed for a button without a game function;
  MiSTer doesn't let you assign a button twice, so to confirm with a button
  that also has a game function, pick it in the OSD's Menu OK/Menu Back
  options instead.

Files
  TODO settings and saved games
  /media/fat/logs/Xash3D/xash3d.log   the game's log

Credits
  TODO the game / source port by its authors.
  SDL by Sam Lantinga and contributors.
  MiSTer by Sorgelig and the MiSTer-devel contributors.
  MiSTer Frontier by MiSTer Organize
  (https://github.com/MiSTerOrganize/MiSTer_Frontier): thank you for the
  inspiration. Hybrid cores on the MiSTer, and the way their game is
  launched, come from MiSTer Frontier. Our launcher is a separate
  implementation and does not need MiSTer Frontier installed.

License
  TODO the game: its license (LICENSE-xash3d.txt)
  SDL: zlib (LICENSE-sdl.txt)
  The launcher scripts: GPL-3.0 (LICENSE-gpl3.txt)
  The FPGA core: GPL-2.0
  Source: https://github.com/ItsDanik/Xash3D_MiSTer
          https://github.com/ItsDanik/Hybrid_MiSTer (launcher, framework)
