
from pathlib import Path

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import seaborn as sns
from matplotlib.lines import Line2D
from matplotlib.colors import Normalize
from matplotlib.cm import ScalarMappable
import plotly.express as px


# 1. Prepare data
df = px.data.gapminder()

df = (
    df[df["year"] == 2007]
    .copy()
    .assign(pop_m=lambda x: x["pop"] / 1e6)
    .sort_values("pop_m")
)

continents = [
    "Africa",
    "Americas",
    "Asia",
    "Europe",
    "Oceania"
]

df["continent"] = pd.Categorical(
    df["continent"],
    categories=continents,
    ordered=True
)

# 2. Color palette (Viridis)
cmap = plt.get_cmap("viridis")

colors = {
    continent: cmap(i / (len(continents) - 1))
    for i, continent in enumerate(continents)
}

# 3. Bubble chart
fig, ax = plt.subplots(figsize=(5.3333, 3.3333))

# Map population to bubble size
pop_min = df["pop_m"].min()
pop_max = df["pop_m"].max()

bubble_sizes = 1 + (
    (df["pop_m"] - pop_min)
    / (pop_max - pop_min)
) * 11

# Matplotlib scatter uses area in points squared
scatter_scale = 9

for continent in continents:
    subset = df[df["continent"] == continent]

    if subset.empty:
        continue

    ax.scatter(
        subset["gdpPercap"],
        subset["lifeExp"],
        s=bubble_sizes.loc[subset.index] ** 2 * scatter_scale,
        color=colors[continent],
        alpha=0.7,
        edgecolors="none",
        linewidths=0,
        zorder=3
    )

# 4. Logarithmic x-axis
ax.set_xscale("log")

x_ticks = [
    500, 1000, 2500, 5000,
    10000, 25000, 50000
]

ax.set_xticks(x_ticks)
ax.set_xticklabels([
    f"${value:,.0f}" for value in x_ticks
])

ax.set_xlim(400, 70000)

# 5. Y-axis
ax.set_ylim(30, 90)
ax.set_yticks(range(30, 91, 10))

# 6. Axis labels
ax.set_xlabel(
    "GDP per capita",
    fontsize=8,
    fontweight="bold",
    color="#4D4D4D",
    labelpad=5
)

ax.set_ylabel(
    "Life expectancy",
    fontsize=8,
    fontweight="bold",
    color="#4D4D4D",
    labelpad=8
)

# 7. Annotation
annotation = (
    r"$\bf{Example\ interpretation:}$"
    "\n"
    "Higher GDP per capita is generally\n"
    "associated with longer life expectancy."
)

ax.text(
    2000,
    44,
    annotation,
    ha="left",
    va="top",
    fontsize=7.2,
    linespacing=1.3,
    color="#666666",
    bbox={
        "boxstyle": "round,pad=0.6,rounding_size=0.15",
        "facecolor": "white",
        "edgecolor": "#D9D9D9",
        "linewidth": 0.7,
        "alpha": 0.92
    },
    zorder=5
)

# 8. Grid styling
ax.grid(
    axis="both",
    which="major",
    color="#E8EBEF",
    linewidth=0.26
)

ax.grid(
    axis="both",
    which="minor",
    visible=False
)

ax.set_axisbelow(True)

# Remove unnecessary spines
sns.despine(ax=ax)

# 9. Tick styling
ax.tick_params(
    axis="x",
    labelsize=7,
    colors="#808080",
    length=0,
    pad=4
)

ax.tick_params(
    axis="y",
    labelsize=7,
    colors="#808080",
    length=0,
    pad=4
)

# 10. Legend (reverse order)
legend_handles = [
    Line2D(
        [0],
        [0],
        marker="o",
        linestyle="none",
        markerfacecolor=colors[continent],
        markeredgecolor="none",
        markersize=3,
        alpha=1,
        label=continent
    )
    for continent in reversed(continents)
]

legend = ax.legend(
    handles=legend_handles,
    title="Continent",
    loc="upper center",
    bbox_to_anchor=(0.5, -0.20),
    ncol=5,
    frameon=False,
    fontsize=7,
    title_fontsize=8,
    handletextpad=0.5,
    columnspacing=1.2,
    labelcolor="#666666"
)

legend.get_title().set_fontweight("bold")
legend.get_title().set_color("#25364A")

# 11. Title and subtitle
fig.suptitle(
    "GDP and life expectancy",
    x=0.08,
    y=0.98,
    ha="left",
    fontsize=12,
    fontweight="bold",
    color="#25364A"
)

fig.text(
    0.08,
    0.90,
    "Bubble size represents population",
    ha="left",
    fontsize=8,
    color="#666666"
)

# 12. Source caption
fig.text(
    0.08,
    0.025,
    "Source: Gapminder",
    ha="left",
    fontsize=6,
    color="#8C8C8C"
)

# 13. Plot margins
fig.subplots_adjust(
    left=0.13,
    right=0.98,
    top=0.82,
    bottom=0.27
)

# 14. Export SVG
out_dir = Path(__file__).parent

output_file = out_dir / "plot01-py.svg"

fig.savefig(
    output_file,
    format="svg",
    dpi=100,
    facecolor="white"
)

print(f"Generated {output_file}")

# 15. Display chart
plt.show()
