
from pathlib import Path

import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import MaxNLocator


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
CONNECTOR_COLOR = "#BFC5CD"

URL = (
    "https://raw.githubusercontent.com/"
    "jennybc/gapminder/main/inst/extdata/gapminder.tsv"
)

CONTINENTS = ["Africa", "Americas", "Asia", "Europe"]

# --------------------------------------------------
# Load and prepare data
# --------------------------------------------------

gapminder = pd.read_csv(URL, sep="\t")

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
    .rename(columns={
        1952: "life_1952",
        2007: "life_2007",
    })
    .reset_index()
)

wide["gain"] = wide["life_2007"] - wide["life_1952"]

# Select the five countries with the largest gains
# in each continent.
gains = (
    wide
    .sort_values(
        ["continent", "gain", "country"],
        ascending=[True, False, True],
        kind="stable",
    )
    .groupby("continent", sort=False)
    .head(5)
    .copy()
)

df = endpoints.merge(
    gains[["country", "continent"]],
    on=["country", "continent"],
    how="inner",
)

df["lifeExp"] = df["lifeExp"].round(1)
df["x"] = df["year"].map({
    1952: 0.0,
    2007: 1.0,
})

df["country_short"] = df["country"].replace({
    "Bosnia and Herzegovina": "Bosnia",
})

# --------------------------------------------------
# Plot styling
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
# Draw continent panels
# --------------------------------------------------

for ax, continent in zip(axes.flat, CONTINENTS):
    subset = df.loc[df["continent"] == continent].copy()
    color = COLORS[continent]

    ax.set_title(
        continent,
        loc="left",
        fontsize=10,
        fontweight="bold",
        color=TITLE_COLOR,
        pad=7,
    )

    ax.set_axisbelow(True)
    ax.grid(
        axis="y",
        color=GRID_COLOR,
        linewidth=0.55,
    )
    ax.grid(axis="x", visible=False)

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

    # Plot lines and endpoint markers.
    for _, country_data in subset.groupby(
        "country",
        sort=False,
    ):
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

    # --------------------------------------------------
    # Prepare labels for the 2007 endpoints
    # --------------------------------------------------

    endpoints_2007 = (
        subset.loc[subset["year"] == 2007]
        .sort_values(
            ["lifeExp", "country"],
            kind="stable",
        )
        .copy()
    )

    ymin = subset["lifeExp"].min()
    ymax = subset["lifeExp"].max()
    yrange = max(ymax - ymin, 1.0)

    y_bottom = ymin - yrange * 0.12
    y_top = ymax + yrange * 0.16

    ax.set_ylim(y_bottom, y_top)

    # Reserve a separate column for labels.
    ax.set_xlim(-0.08, 1.85)

    label_x = 1.12
    connector_x = 1.025

    actual_y = endpoints_2007["lifeExp"].to_numpy()
    label_count = len(actual_y)

    # Evenly distribute labels vertically within the
    # available range, keeping their order consistent
    # with the corresponding endpoint values.
    label_bottom = ymin - yrange * 0.06
    label_top = ymax + yrange * 0.06

    if label_count > 1:
        label_y = [
            label_bottom
            + i * (label_top - label_bottom) / (label_count - 1)
            for i in range(label_count)
        ]
    else:
        label_y = actual_y.copy()

    # --------------------------------------------------
    # Draw connectors and labels
    # --------------------------------------------------

    for (_, endpoint), y_text in zip(
        endpoints_2007.iterrows(),
        label_y,
    ):
        y_point = endpoint["lifeExp"]

        # Connector starts just beyond the 2007 point.
        ax.plot(
            [connector_x, label_x - 0.025],
            [y_point, y_text],
            color=CONNECTOR_COLOR,
            linewidth=0.5,
            alpha=0.9,
            solid_capstyle="round",
            zorder=4,
            clip_on=False,
        )

        # Label sits entirely in the right-hand column.
        ax.text(
            label_x,
            y_text,
            f"{endpoint['country_short']}  {y_point:.1f}",
            fontsize=6.2,
            fontweight="bold",
            color=TEXT_COLOR,
            ha="left",
            va="center",
            clip_on=False,
            zorder=5,
            bbox={
                "facecolor": BG_COLOR,
                "edgecolor": "none",
                "boxstyle": "square,pad=0.7",
            },
        )

    # --------------------------------------------------
    # X-axis
    # --------------------------------------------------

    ax.set_xticks([0, 1])
    ax.set_xticklabels(
        ["1952", "2007"],
        fontsize=7.5,
        fontweight="bold",
        color=TITLE_COLOR,
    )

    ax.tick_params(axis="x", pad=5)

# --------------------------------------------------
# Title and subtitle
# --------------------------------------------------

fig.text(
    0.105,
    0.965,
    "A longer life",
    ha="left",
    va="top",
    fontsize=12,
    fontweight="bold",
    color=TITLE_COLOR,
)

fig.text(
    0.105,
    0.905,
    "The five largest gains in life expectancy within each continent, 1952–2007",
    ha="left",
    va="top",
    fontsize=8,
    color="#666666",
)

# --------------------------------------------------
# Source note
# --------------------------------------------------

fig.text(
    0.105,
    0.035,
    "Source: Gapminder  |  Change: 2007 minus 1952",
    ha="left",
    va="bottom",
    fontsize=6,
    color="#8C8C8C",
)

# --------------------------------------------------
# Export SVG
# --------------------------------------------------

OUTPUT_PATH.parent.mkdir(
    parents=True,
    exist_ok=True,
)

fig.savefig(
    OUTPUT_PATH,
    format="svg",
    facecolor=BG_COLOR,
    edgecolor="none",
)

plt.close(fig)

print(f"Saved chart to {OUTPUT_PATH}")
