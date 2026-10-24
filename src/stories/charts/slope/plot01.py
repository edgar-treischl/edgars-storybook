
from pathlib import Path

import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import MaxNLocator
from adjustText import adjust_text


# --------------------------------------------------
# Configuration
# --------------------------------------------------

OUTPUT_PATH = Path("src/stories/charts/slope/plot01-py.svg")

FIG_WIDTH = 5.3333
FIG_HEIGHT = 3.3333

COLORS = {
    "Africa": "#1B9E77",
    "Americas": "#D95F02",
    "Asia": "#7570B3",
    "Europe": "#E7298A",
}

BG_COLOR = "#FFFFFF"
TITLE_COLOR = "#25364A"
TEXT_COLOR = "#404040"
MUTED_COLOR = "#808080"
GRID_COLOR = "#E8EBEF"


# --------------------------------------------------
# 1. Load data
# --------------------------------------------------

URL = (
    "https://raw.githubusercontent.com/"
    "jennybc/gapminder/main/inst/extdata/gapminder.tsv"
)

gapminder = pd.read_csv(URL, sep="\t")


# --------------------------------------------------
# 2. Find the five largest gains per continent
# --------------------------------------------------

endpoints = gapminder.loc[
    gapminder["year"].isin([1952, 2007])
    & gapminder["continent"].ne("Oceania"),
    ["country", "continent", "year", "lifeExp"],
]

wide = (
    endpoints
    .pivot(
        index=["country", "continent"],
        columns="year",
        values="lifeExp",
    )
    .rename(columns={1952: "life_1952", 2007: "life_2007"})
    .reset_index()
)

wide["gain"] = wide["life_2007"] - wide["life_1952"]

gains = (
    wide
    .sort_values(
        ["continent", "gain", "country"],
        ascending=[True, False, True],
        kind="stable",
    )
    .groupby("continent", sort=False)
    .head(3)
    .copy()
)


# --------------------------------------------------
# 3. Prepare the selected countries
# --------------------------------------------------

df = endpoints.merge(
    gains[["country", "continent"]],
    on=["country", "continent"],
    how="inner",
)

df = df.copy()
df["lifeExp"] = df["lifeExp"].round(1)
df["x"] = df["year"].map({1952: 0.0, 2007: 1.0})

df["country_short"] = df["country"].replace(
    {"Bosnia and Herzegovina": "Bosnia"}
)

continents = ["Africa", "Americas", "Asia", "Europe"]


# --------------------------------------------------
# 4. Set up a clean 2 x 2 slope chart
# --------------------------------------------------

plt.rcParams.update({
    "font.family": "DejaVu Sans",
    "svg.fonttype": "none",
    "axes.facecolor": BG_COLOR,
    "figure.facecolor": BG_COLOR,
    "savefig.facecolor": BG_COLOR,
})

fig, axes = plt.subplots(
    nrows=2,
    ncols=2,
    figsize=(FIG_WIDTH, FIG_HEIGHT),
    squeeze=False,
)

fig.subplots_adjust(
    left=0.105,
    right=0.985,
    top=0.69,
    bottom=0.15,
    wspace=0.53,
    hspace=0.72,
)


# --------------------------------------------------
# 5. Draw each continent independently
# --------------------------------------------------

for ax, continent in zip(axes.flat, continents):
    subset = df.loc[df["continent"] == continent]

    color = COLORS[continent]

    # Panel heading
    ax.set_title(
        continent,
        loc="left",
        fontsize=10,
        fontweight="bold",
        color=TITLE_COLOR,
        pad=7,
    )

    # Subtle horizontal grid only
    ax.set_axisbelow(True)
    ax.grid(
        axis="y",
        color=GRID_COLOR,
        linewidth=0.55,
    )
    ax.grid(axis="x", visible=False)

    # Keep the chart clean
    for spine in ax.spines.values():
        spine.set_visible(False)

    ax.tick_params(
        axis="both",
        which="both",
        length=0,
        labelsize=7,
        colors=MUTED_COLOR,
        pad=3,
    )

    ax.yaxis.set_major_locator(MaxNLocator(nbins=4))

    # Draw one slope per country
    labels = []

    for _, country_data in subset.groupby("country", sort=False):
        country_data = country_data.sort_values("year")

        x = country_data["x"].to_numpy()
        y = country_data["lifeExp"].to_numpy()

        ax.plot(
            x,
            y,
            color=color,
            linewidth=1.05,
            alpha=0.78,
            solid_capstyle="round",
            zorder=2,
        )

        ax.scatter(
            x,
            y,
            color=color,
            s=10,
            linewidths=0,
            zorder=3,
        )

        endpoint = country_data.loc[
            country_data["year"] == 2007
        ].iloc[0]

        label = (
            f"{endpoint['country_short']}  "
            f"{endpoint['lifeExp']:.1f}"
        )

        text = ax.text(
            1.065,
            endpoint["lifeExp"],
            label,
            fontsize=6.2,
            fontweight="bold",
            color=TEXT_COLOR,
            ha="left",
            va="center",
            clip_on=False,
            zorder=5,
        )

        labels.append(text)

    # Repel endpoint labels vertically within this panel.
    # Keep the labels on the right side of the chart.
    adjust_text(
        labels,
        ax=ax,
        x=[1.0] * len(labels),
        y=subset.loc[
            subset["year"] == 2007, "lifeExp"
        ].to_numpy(),
        only_move={
            "text": "y",
            "static": "y",
            "explode": "y",
            "pull": "y",
        },
        force_text=(0.15, 0.35),
        force_static=(0.1, 0.2),
        force_pull=(0.01, 0.05),
        expand=(1.05, 1.2),
        iter_lim=150,
        arrowprops={
            "arrowstyle": "-",
            "color": "#BFC5CD",
            "lw": 0.45,
            "alpha": 0.7,
            "shrinkA": 1,
            "shrinkB": 2,
        },
    )

    # Explicitly reserve space for both year endpoints and labels
    ax.set_xlim(-0.12, 1.42)

    ymin = subset["lifeExp"].min()
    ymax = subset["lifeExp"].max()
    yrange = ymax - ymin

    ax.set_ylim(
        ymin - yrange * 0.12,
        ymax + yrange * 0.16,
    )

    ax.set_xticks([0, 1])
    ax.set_xticklabels(
        ["1952", "2007"],
        fontsize=7.5,
        fontweight="bold",
        color=TITLE_COLOR,
    )

    ax.tick_params(
        axis="x",
        pad=5,
    )


# --------------------------------------------------
# 6. Add title, subtitle, and caption
# --------------------------------------------------

fig.text(
    0.105, 0.965,
    "A longer life",
    ha="left",
    va="top",
    fontsize=12,
    fontweight="bold",
    color=TITLE_COLOR,
)

fig.text(
    0.105, 0.905,
    "The five largest gains in life expectancy",
    ha="left",
    va="top",
    fontsize=8,
    color="#666666",
)

fig.text(
    0.105, 0.865,
    "within each continent, 1952–2007",
    ha="left",
    va="top",
    fontsize=8,
    color="#666666",
)

fig.text(
    0.105, 0.035,
    "Source: Gapminder  |  Change: 2007 minus 1952",
    ha="left",
    va="bottom",
    fontsize=6,
    color="#8C8C8C",
)

# --------------------------------------------------
# 7. Export SVG
# --------------------------------------------------

OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

fig.savefig(
    OUTPUT_PATH,
    format="svg",
    facecolor="white",
    edgecolor="none",
)

plt.close(fig)

print(f"Saved chart to {OUTPUT_PATH}")
