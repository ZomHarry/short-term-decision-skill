# -*- coding: utf-8 -*-
"""生成 GitHub 社交预览图（1280x640）。用法：python scripts/make-social-preview.py"""
import os
from PIL import Image, ImageDraw, ImageFont

W, H = 1280, 640
BG_TOP = (11, 18, 32)
BG_BOT = (18, 32, 58)
ACCENT = (56, 189, 248)
TEXT = (241, 245, 249)
MUTED = (148, 163, 184)
CHIP_BG = (30, 41, 59)
CHIP_TX = (203, 213, 225)

FONT_DIR = r"C:\Windows\Fonts"
def font(name, size):
    path = os.path.join(FONT_DIR, name)
    return ImageFont.truetype(path, size, index=0) if path.lower().endswith(".ttc") else ImageFont.truetype(path, size)

img = Image.new("RGB", (W, H), BG_TOP)
d = ImageDraw.Draw(img)

# 竖向渐变
for y in range(H):
    t = y / H
    d.line([(0, y), (W, y)], fill=tuple(int(BG_TOP[i] + (BG_BOT[i] - BG_TOP[i]) * t) for i in range(3)))

# 左侧强调条
d.rectangle([72, 96, 80, 520], fill=ACCENT)

x = 120
f_title = font("msyhbd.ttc", 62)
f_sub   = font("msyh.ttc", 28)
f_desc  = font("msyh.ttc", 21)
f_chip  = font("msyh.ttc", 20)
f_url   = font("consola.ttf", 18)

d.text((x, 108), "管理会计短期经营决策", font=f_title, fill=TEXT)
d.text((x, 196), "Skill · 方法路由与相关成本计算", font=f_sub, fill=ACCENT)
d.text((x, 250), "题型识别 → 相关成本识别 → 方法路由 → 分步计算 → 可复核结论", font=f_desc, fill=MUTED)

chips = ["自制外购", "特殊订货", "亏损产品", "进一步加工", "工艺选择", "最优批量"]
cx, cy = x, 316
for c in chips:
    tw = d.textlength(c, font=f_chip)
    bw, bh = tw + 36, 46
    if cx + bw > W - 100:
        cx, cy = x, cy + bh + 14
    d.rounded_rectangle([cx, cy, cx + bw, cy + bh], radius=23, fill=CHIP_BG, outline=(51, 65, 85), width=1)
    d.text((cx + 18, cy + 11), c, font=f_chip, fill=CHIP_TX)
    cx += bw + 14

d.line([(x, 470), (W - 100, 470)], fill=(51, 65, 85), width=2)
d.text((x, 496), "五步路由 · 七段输出 · 12 条易错点 · 6 道回归测试", font=f_desc, fill=MUTED)
d.text((x, 536), "github.com/ZomHarry/short-term-decision-skill", font=f_url, fill=(100, 116, 139))

# 右边装饰：淡淡的决策树
SPINE, TOP, BOT = 1030, 140, 460
d.line([(SPINE, TOP), (SPINE, BOT)], fill=(30, 78, 91), width=2)
for py, bx in [(TOP, None), (300, 1150), (BOT, None)]:
    if bx:
        d.line([(SPINE, py), (bx, py)], fill=(30, 78, 91), width=2)
        d.ellipse([bx - 6, py - 6, bx + 6, py + 6], outline=(45, 212, 191), width=2)
    d.ellipse([SPINE - 6, py - 6, SPINE + 6, py + 6], outline=(45, 212, 191), width=2)

out_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "docs", "assets")
os.makedirs(out_dir, exist_ok=True)
out = os.path.join(out_dir, "social-preview.png")
img.save(out, "PNG", optimize=True)
print("saved", out, os.path.getsize(out), "bytes")
