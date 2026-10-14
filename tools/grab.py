#!/usr/bin/env python3
"""Save the frame the hybrid core is showing as a PPM (run on the MiSTer while
the game shows its 3D view: RGB565 frames only, not the shared screens).
usage: grab.py <file.ppm>"""
import mmap, os, struct, sys

MODES = [(320, 200), (640, 200), (640, 400), (320, 240), (640, 480), (800, 600), (1024, 768), (640, 240)]
fd = os.open("/dev/mem", os.O_RDONLY | os.O_SYNC)
m = mmap.mmap(fd, 0x400000, mmap.MAP_SHARED, mmap.PROT_READ, offset=0x30000000)
ctrl = struct.unpack_from("<2I", m, 0)
index, fmt, mode = ctrl[1] & 0xFF, (ctrl[1] >> 8) & 0xF, (ctrl[1] >> 12) & 0xF
w, h = MODES[mode]
if ctrl[0] != 0x4259484D or fmt != 1 or mode == 6:
    sys.exit("no RGB565 frame of a game on the screen (ctrl %08x %08x)" % ctrl)
raw = m[0x100000 + index * 0x100000 : 0x100000 + index * 0x100000 + w * h * 2]
out = bytearray(w * h * 3)
for i, p in enumerate(struct.unpack("<%dH" % (w * h), raw)):
    out[3 * i] = (p >> 11) * 255 // 31
    out[3 * i + 1] = ((p >> 5) & 63) * 255 // 63
    out[3 * i + 2] = (p & 31) * 255 // 31
open(sys.argv[1], "wb").write(b"P6 %d %d 255\n" % (w, h) + out)
