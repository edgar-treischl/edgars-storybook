import re
from collections import Counter
from pathlib import Path

import nltk
import matplotlib.pyplot as plt
from nltk.corpus import stopwords
from wordcloud import WordCloud
from matplotlib import font_manager


# --------------------------------------------------
# Configuration
# --------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent
INPUT_FILE = BASE_DIR / "alice.txt"
OUTPUT_FILE = BASE_DIR / "plot01-py.svg"

BACKGROUND = "#FAF9F6"
TEXT_COLOR = "#26312C"
SUBTITLE_COLOR = "#73766F"
FOOTER_COLOR = "#898B84"

PALETTE = [
    "#303B36",  # Deep charcoal-green
    "#65796A",  # Muted sage
    "#71889A",  # Dusty blue
    "#B47765",  # Muted terracotta
    "#A69A7B",  # Warm olive
]

MIN_FREQUENCY = 8
EXCLUDED_WORDS = {"alice"}


# --------------------------------------------------
# Load and process text
# --------------------------------------------------

if not INPUT_FILE.exists():
    raise FileNotFoundError(f"Input file not found: {INPUT_FILE}")

# Download English stop words if needed.
nltk.download("stopwords", quiet=True)

alice = INPUT_FILE.read_text(encoding="utf-8")

words = re.findall(r"\b[a-zA-Z]+\b", alice.lower())

stop_words = set(stopwords.words("english"))

word_counts = Counter(
    word
    for word in words
    if word not in stop_words
)

frequencies = {
    word: count
    for word, count in word_counts.items()
    if count >= MIN_FREQUENCY
    and word not in EXCLUDED_WORDS
}

if not frequencies:
    raise ValueError("No words remain after filtering.")


# --------------------------------------------------
# Typography
# --------------------------------------------------

font_path = None

for font in font_manager.findSystemFonts():
    if "delius" in Path(font).stem.lower():
        font_path = font
        break

if font_path is None:
    print("Delius font not found; using the default word cloud font.")

# Use a serif title for a literary feel.
title_font = "Delius" if font_path else "serif"
body_font = "Delius" if font_path else "sans-serif"


# --------------------------------------------------
# Word colors
# --------------------------------------------------

def word_color(word, *args, **kwargs):
    """Assign a reproducible color to each word."""
    index = sum(ord(char) for char in word) % len(PALETTE)
    return PALETTE[index]


# --------------------------------------------------
# Generate word cloud
# --------------------------------------------------

wc = WordCloud(
    width=1600,
    height=1000,
    background_color=BACKGROUND,
    color_func=word_color,
    max_font_size=260,
    min_font_size=10,
    prefer_horizontal=0.82,
    relative_scaling=0.65,
    random_state=123,
    font_path=font_path,
    collocations=False,
    margin=5,
).generate_from_frequencies(frequencies)


# --------------------------------------------------
# Plot
# --------------------------------------------------

fig, ax = plt.subplots(figsize=(14, 10))

fig.patch.set_facecolor(BACKGROUND)
ax.set_facecolor(BACKGROUND)

ax.imshow(wc, interpolation="bilinear")
ax.axis("off")

# Main title
fig.suptitle(
    "Alice in Wonderland",
    fontsize=30,
    fontweight="normal",
    y=0.955,
    fontfamily=title_font,
    color=TEXT_COLOR,
)

# Subtitle
fig.text(
    0.5,
    0.905,
    f"A literary word portrait  ·  {MIN_FREQUENCY}+ occurrences",
    ha="center",
    fontsize=12,
    fontfamily=body_font,
    color=SUBTITLE_COLOR,
)

# Footer
fig.text(
    0.5,
    0.035,
    "LEWIS CARROLL  ·  ENGLISH STOP WORDS REMOVED",
    ha="center",
    fontsize=8,
    fontfamily=body_font,
    color=FOOTER_COLOR,
)

# Layout
plt.subplots_adjust(
    left=0.045,
    right=0.955,
    top=0.86,
    bottom=0.075,
)

# Save as a scalable vector graphic.
fig.savefig(
    OUTPUT_FILE,
    format="svg",
    bbox_inches="tight",
    pad_inches=0.2,
    facecolor=fig.get_facecolor(),
    transparent=False,
)

print(f"Generated: {OUTPUT_FILE}")
print(f"Unique words displayed: {len(frequencies)}")

plt.show()
