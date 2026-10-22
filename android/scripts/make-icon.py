#!/usr/bin/env python3
"""Draws android/icons/icon-1024.png, the launcher icon of Medicare Guide (메디케어 길라잡이).

A signpost (길라잡이 = "the one who shows the way") on the app's own deep green (--accent
#1d5a4c): a cream post with two direction boards, the upper one in the app's amber (--warn,
dark theme #e7b85a). Large, high-contrast shapes so it stays readable at small sizes. All
artwork sits inside the 66 dp adaptive-icon safe circle so the Android adaptive-icon mask never clips it.

Drawn at 4x and downsampled for smooth edges. Run: python3 scripts/make-icon.py
"""
import os
from PIL import Image, ImageDraw

AND = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(AND, "icons", "icon-1024.png")
S = 4
W = 1024 * S
GREEN = (29, 90, 76)
CREAM = (245, 246, 242)
AMBER = (231, 184, 90)
SHADE = (20, 66, 56)

img = Image.new("RGB", (W, W), GREEN)
d = ImageDraw.Draw(img)
K = 1.10             # artwork scale about the centre (keeps it inside the adaptive safe zone)
def p(v):            # 1024-space -> canvas, scaled about the centre (512, 500)
    return round(v * S)
def px(v):
    return round((512 + (v - 512) * K) * S)
def py(v):
    return round((500 + (v - 500) * K) * S)

# Ground: a soft darker ellipse the post stands on.
d.ellipse((px(352), py(724), px(672), py(772)), fill=SHADE)
# Post.
d.rounded_rectangle((px(482), py(250), px(542), py(752)), radius=p(18), fill=CREAM)
# Post cap.
d.ellipse((px(474), py(228), px(550), py(296)), fill=CREAM)

def board(y0, y1, x_left, x_right, pointing, colour):
    """A direction board with a pointed end, rounded on the blunt end."""
    r = p(22)
    mid = (y0 + y1) / 2
    tip = 64
    if pointing == "right":
        d.rounded_rectangle((px(x_left), py(y0), px(x_right - tip), py(y1)), radius=r, fill=colour,
                            corners=(True, False, False, True))
        d.polygon([(px(x_right - tip) - 2, py(y0)), (px(x_right), py(mid)), (px(x_right - tip) - 2, py(y1))], fill=colour)
    else:
        d.rounded_rectangle((px(x_left + tip), py(y0), px(x_right), py(y1)), radius=r, fill=colour,
                            corners=(False, True, True, False))
        d.polygon([(px(x_left + tip) + 2, py(y0)), (px(x_left), py(mid)), (px(x_left + tip) + 2, py(y1))], fill=colour)

board(318, 438, 404, 722, "right", AMBER)
board(476, 586, 302, 620, "left", CREAM)
# Small rivets where the boards meet the post, in the field colour, for a crafted look.
for cy in (378, 531):
    d.ellipse((px(503), py(cy - 9), px(521), py(cy + 9)), fill=SHADE)

img = img.resize((1024, 1024), Image.LANCZOS)
os.makedirs(os.path.dirname(OUT), exist_ok=True)
img.save(OUT, optimize=True)
print(f"make-icon: wrote {OUT}")
