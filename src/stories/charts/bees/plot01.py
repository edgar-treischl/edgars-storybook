import matplotlib.pyplot as plt
import seaborn as sns
from palmerpenguins import load_penguins
from pathlib import Path

penguins = load_penguins().dropna(
    subset=["species", "body_mass_g"]
)

species_order = ["Adelie", "Chinstrap", "Gentoo"]

palette = {
    "Adelie": "#E69F00",
    "Chinstrap": "#56B4E9",
    "Gentoo": "#009E73",
}

sns.set_theme(
    style="white",
    context="talk",
    rc={
        "font.family": "sans-serif",
        "font.size": 16,
        "axes.titlesize": 25,
        "axes.labelsize": 19,
        "xtick.labelsize": 17,
        "ytick.labelsize": 16,
        "svg.fonttype": "none",
    },
)

fig, ax = plt.subplots(figsize=(13, 9), dpi=100)

sns.stripplot(
    data=penguins,
    x="species",
    y="body_mass_g",
    hue="species",
    order=species_order,
    palette=palette,
    jitter=0.24,
    size=8,
    alpha=0.8,
    edgecolor="white",
    linewidth=0.9,
    legend=False,
    ax=ax,
    zorder=3,
)

fig.suptitle(
    "Body Mass of Palmer Penguins",
    x=0.12,
    y=0.96,
    ha="left",
    fontsize=28,
    fontweight="bold",
    color="#222222",
)

ax.text(
    0,
    1.035,
    "Individual observations by species",
    transform=ax.transAxes,
    ha="left",
    va="bottom",
    fontsize=17,
    color="#666666",
)

ax.set_xlabel("")
ax.set_ylabel("Body mass (g)", labelpad=14, fontsize=19)

ax.set_ylim(2500, 6500)
ax.set_yticks(range(2500, 6501, 500))

ax.set_axisbelow(True)
ax.grid(
    axis="y",
    which="major",
    color="#E2E5E9",
    linewidth=1.2,
)
ax.grid(axis="x", visible=False)
ax.grid(axis="y", which="minor", visible=False)

ax.tick_params(
    axis="both",
    which="major",
    length=0,
    pad=12,
)

for label in ax.get_xticklabels():
    label.set_fontweight("medium")

sns.despine(ax=ax, top=True, right=True)

fig.subplots_adjust(
    left=0.14,
    right=0.97,
    bottom=0.15,
    top=0.82,
)

out_dir = Path(__file__).resolve().parent
out_dir.mkdir(parents=True, exist_ok=True)

output_file = out_dir / "plot01-py.svg"

fig.savefig(
    output_file,
    format="svg",
    bbox_inches="tight",
    pad_inches=0.25,
    facecolor="white",
    transparent=False,
)

print(f"Generated: {output_file}")

plt.show()