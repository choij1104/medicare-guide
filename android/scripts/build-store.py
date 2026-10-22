#!/usr/bin/env python3
"""Builds android/www, the Google Play build of Medicare Guide (메디케어 길라잡이), from the
repository's index.html.

The web app in the repository root is not modified. The store build differs in these ways:

  1. Offline: the "Translate & ask" tab (AI letter translation and AI Q&A, which call a
     Supabase edge function) is removed together with its script, its endpoint URL and key.
     The store build makes no network request. The one sentence that pointed to that tab
     (Annual Notice of Change) now points to free HICAP counseling instead.
  2. Fonts: Gowun Batang and Noto Sans KR are bundled from @fontsource (SIL OFL 1.1) instead
     of loaded from Google Fonts.
  3. Independence notice: a visible notice (Korean and English) that the app is independent
     and not affiliated with or endorsed by Medicare, CMS, the Social Security Administration
     or any government agency, with links to the official sources for the figures
     (medicare.gov, cms.gov, ssa.gov). Shown at the top of Basics and in the footer.
  4. Estimates: every 2027 Part A/B amount that is still a projection is labelled as an
     estimate where it is used (the cost calculator text and its assumptions), not only in
     the key-amounts table. No number is changed.
  5. Outbound links (medicare.gov, cms.gov, ssa.gov) stay ordinary links; inside the app
     Capacitor opens them in the system browser.
  6. Layout: grid children get min-width:0 so the calculator's wide table scrolls inside its
     box instead of widening the "Find my fit" tab on phones (the same bug exists in main).
  7. Capacitor runtime: @capacitor/core's capacitor.js is bundled and loaded first.

Every text replacement must match exactly once, or the build fails.
Run `npm ci` in android/ first so the @fontsource packages are present.
"""
import os, re, shutil, sys

AND = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.dirname(AND)
OUT = os.path.join(AND, "www")
FS = os.path.join(AND, "node_modules", "@fontsource")

def die(msg):
    sys.exit(f"build-store: {msg}")

def sub1(old, new, s, what):
    n = s.count(old)
    if n != 1:
        die(f"{what}: expected 1 match, found {n}")
    return s.replace(old, new)

def cut1(start, end, s, what, repl=""):
    """Remove the text from `start` up to and including `end` (each must occur once)."""
    for m in (start, end):
        if s.count(m) != 1:
            die(f"{what}: marker {m[:40]!r} expected once, found {s.count(m)}")
    i = s.index(start)
    j = s.index(end, i) + len(end)
    return s[:i] + repl + s[j:]

t = open(os.path.join(ROOT, "index.html"), encoding="utf-8").read()

# 0. Build marker -----------------------------------------------------------------------
t = sub1('<meta charset="utf-8">', '<meta charset="utf-8">\n<meta name="medicare-guide-build" content="store">', t, "charset meta")

# 1. Offline: remove the AI translate / Q&A feature ---------------------------------------
t = sub1('  <button class="tab" role="tab" data-tab="translate" aria-selected="false"><span class="ko">서류 번역·질문</span><span class="en">Translate & ask</span></button>\n',
         "", t, "Translate tab button")
t = cut1("<!-- TRANSLATE -->\n", "</section>\n\n<!-- SCAM -->", t, "Translate section", repl="<!-- SCAM -->")
t = cut1("  /* AI: grounded translation and Q&A */\n", "    run(document.getElementById('qa-go'),document.getElementById('qa-stop'),out,{mode:'qa',text:q.slice(0,4000)});\n  });\n",
         t, "AI script")
t = sub1('<span class="ko">"연간 변경 안내(ANOC)" 편지. 내 플랜이 내년에 무엇이 바뀌는지 적혀 있습니다. 번역 탭에 올려 보세요.</span><span class="en">"Annual Notice of Change" letter: what changes in your plan next year. Upload it in the Translate tab.</span>',
         '<span class="ko">"연간 변경 안내(ANOC)" 편지. 내 플랜이 내년에 무엇이 바뀌는지 적혀 있습니다. 이해하기 어려우면 HICAP(무료)에 물어보세요.</span><span class="en">"Annual Notice of Change" letter: what changes in your plan next year. If anything is unclear, ask HICAP (free).</span>',
         t, "ANOC sentence")

# 2. Fonts ------------------------------------------------------------------------------
for pkg in ("gowun-batang", "noto-sans-kr"):
    if not os.path.isdir(os.path.join(FS, pkg, "files")):
        die("@fontsource packages missing: run npm ci in android/ first")
t = sub1('<link rel="preconnect" href="https://fonts.googleapis.com">\n', "", t, "font preconnect")
gf = re.findall(r'<link rel="stylesheet" href="https://fonts\.googleapis\.com/css2[^"]*">', t)
if len(gf) != 1:
    die(f"Google Fonts stylesheet link: expected 1, found {len(gf)}")
t = t.replace(gf[0], '<link rel="stylesheet" href="fonts/fonts.css">')

# 3. Independence notice and official sources ------------------------------------------
# Layout fix: grid items default to min-width:auto, so the 520px calculator table widened the
# whole "Find my fit" tab to ~580px on a 360px phone instead of scrolling inside .tablewrap.
NOTICE_CSS = "section>*,form.tool>*{min-width:0}\n.indep{border:1.5px solid var(--line);border-radius:12px;padding:12px 16px;font-size:.95rem;color:var(--muted);background:var(--card)}\n.indep b{color:var(--ink)}\n"
t = sub1("@media (prefers-reduced-motion:no-preference){.water{", NOTICE_CSS + "@media (prefers-reduced-motion:no-preference){.water{", t, "notice CSS")

SRC_LINKS = ('<a href="https://www.medicare.gov" target="_blank" rel="noopener">medicare.gov</a> · '
             '<a href="https://www.cms.gov" target="_blank" rel="noopener">cms.gov</a> · '
             '<a href="https://www.ssa.gov" target="_blank" rel="noopener">ssa.gov</a>')
NOTICE = ('  <p class="indep"><b><span class="ko">독립 교육용 앱입니다.</span><span class="en">An independent educational app.</span></b> '
          '<span class="ko">메디케어(Medicare), CMS(메디케어·메디케이드 서비스 센터), 사회보장국(SSA) 또는 어떤 정부 기관과도 관련이 없으며, 이들의 승인이나 보증을 받지 않았습니다. 금액은 공식 자료를 정리한 것입니다. 공식 정보: </span>'
          '<span class="en">It is not affiliated with or endorsed by Medicare, the Centers for Medicare &amp; Medicaid Services (CMS), the Social Security Administration (SSA) or any government agency. Figures are summarized from official sources. Official information: </span>'
          + SRC_LINKS + '</p>\n')
t = sub1('<section id="basics" role="tabpanel">\n', '<section id="basics" role="tabpanel">\n' + NOTICE, t, "Basics notice")

t = sub1('<p><span class="ko">이 앱은 교육용 안내이며 보험 판매나 개인 법률·재정 자문이 아닙니다. 어떤 보험사와도 관계가 없습니다. ',
         '<p><span class="ko">이 앱은 교육용 안내이며 보험 판매나 개인 법률·재정 자문이 아닙니다. 어떤 보험사와도 관계가 없습니다. 메디케어, CMS, 사회보장국(SSA) 또는 어떤 정부 기관과도 관련이 없으며 승인이나 보증을 받지 않았습니다. ',
         t, "footer notice (ko)")
t = sub1('<span class="en">Educational guide only; not insurance sales or personal legal or financial advice. Not affiliated with any insurer. ',
         '<span class="en">Educational guide only; not insurance sales or personal legal or financial advice. Not affiliated with any insurer. Not affiliated with or endorsed by Medicare, CMS, the Social Security Administration or any government agency. ',
         t, "footer notice (en)")
t = sub1("  <p>HAKOYA LLC</p>\n",
         '  <p><span class="ko">공식 정보: </span><span class="en">Official information: </span>' + SRC_LINKS + '</p>\n  <p>HAKOYA LLC</p>\n',
         t, "footer sources")

# 4. Label 2027 estimates where they are used -------------------------------------------
t = sub1('Part B 보험료(월 약 $209.50)는 어느 쪽이든 똑같이 내므로 계산에서 뺐습니다.',
         'Part B 보험료(2027년 예상치 월 약 $209.50)는 어느 쪽이든 똑같이 내므로 계산에서 뺐습니다.', t, "calculator premium (ko)")
t = sub1('The Part B premium (about $209.50/month) is the same on every path, so it is left out.',
         'The Part B premium (2027 estimate: about $209.50/month) is the same on every path, so it is left out.', t, "calculator premium (en)")
t = sub1('<span class="ko">계산 가정: 진료 1회당 메디케어 인정 금액 약 $150. ',
         '<span class="ko">계산 가정: Part B 디덕티블은 2027년 예상치 $292(2026 메디케어 이사회 보고서 전망, CMS가 11월에 확정 발표). 진료 1회당 메디케어 인정 금액 약 $150. ', t, "calculator assumptions (ko)")
t = sub1('<span class="en">Assumptions: about $150 Medicare-approved per visit. ',
         '<span class="en">Assumptions: Part B deductible uses the 2027 estimate of $292 (2026 Medicare Trustees Report projection; CMS announces the final amount in November). About $150 Medicare-approved per visit. ', t, "calculator assumptions (en)")

# Checks --------------------------------------------------------------------------------
for bad in ("supabase", "AI_URL", "AI_KEY", "fetch(", "XMLHttpRequest", "anthropic", "data-tab=\"translate\"",
            "id=\"translate\"", "trForm", "qaForm", "aiOff", "번역 탭", "Translate tab",
            "fonts.googleapis", "fonts.gstatic", "eyJhbGci"):
    if bad.lower() in t.lower():
        die(f"'{bad}' still present")
if re.search(r'\ssrc="https?://', t):
    die("external src reference in index.html")
ext = re.findall(r'<(\w+)[^>]*\shref="(https?://[^"]+)"', t)
for tag, url in ext:
    if tag != "a" or not re.match(r"https://www\.(medicare|cms|ssa)\.gov(/|$)", url):
        die(f"unexpected external reference <{tag} href={url}>")
for must in ("not affiliated with or endorsed by Medicare", "정부 기관과도 관련이 없으며", "2027 estimate", "2027년 예상치"):
    if must not in t:
        die(f"'{must}' missing")

shutil.rmtree(OUT, ignore_errors=True)
os.makedirs(os.path.join(OUT, "fonts"))
open(os.path.join(OUT, "index.html"), "w", encoding="utf-8").write(t)

# Fonts: @fontsource's own per-weight CSS keeps each subset's unicode-range; woff2 only.
# Gowun Batang is used only for headings (bold); Noto Sans KR at 400, 500 and 700.
want = {"gowun-batang": [700], "noto-sans-kr": [400, 500, 700]}
css = []
for pkg, weights in want.items():
    for w in weights:
        src = open(os.path.join(FS, pkg, f"{w}.css"), encoding="utf-8").read()
        src = re.sub(r",\s*url\([^)]*\.woff\) format\('woff'\)", "", src)
        for f in re.findall(r"url\(\./files/([^)]+\.woff2)\)", src):
            shutil.copy(os.path.join(FS, pkg, "files", f), os.path.join(OUT, "fonts", f))
        css.append(src.replace("url(./files/", "url("))
open(os.path.join(OUT, "fonts", "fonts.css"), "w", encoding="utf-8").write("\n".join(css))
shutil.copy(os.path.join(FS, "gowun-batang", "LICENSE"), os.path.join(OUT, "fonts", "OFL-GowunBatang.txt"))
shutil.copy(os.path.join(FS, "noto-sans-kr", "LICENSE"), os.path.join(OUT, "fonts", "OFL-NotoSansKR.txt"))
n_fonts = len([f for f in os.listdir(os.path.join(OUT, "fonts")) if f.endswith(".woff2")])
print(f"build-store: Medicare Guide written to {OUT} ({len(t)} bytes, {n_fonts} font files)")

# Capacitor JS runtime -------------------------------------------------------------------
# Ship @capacitor/core's browser build (same version as the native bridge) and load it before
# the app script. Outbound links then open in the system browser inside the app.
_src = os.path.join(AND, "node_modules", "@capacitor", "core", "dist", "capacitor.js")
if not os.path.isfile(_src):
    die("@capacitor/core dist/capacitor.js missing: run npm ci in android/ first")
shutil.copy(_src, os.path.join(OUT, "capacitor.js"))
_index = os.path.join(OUT, "index.html")
_html = open(_index, encoding="utf-8").read()
_i = _html.find("<script")
if _i < 0:
    die("no <script> tag to load capacitor.js before")
_html = _html[:_i] + '<script src="capacitor.js"></script>\n' + _html[_i:]
open(_index, "w", encoding="utf-8").write(_html)
print("build-store: capacitor.js bundled and loaded before the app script")
