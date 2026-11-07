
import pandas as pd

from statsmodels.datasets import get_rdataset

from plotnine import (
    ggplot,
    aes,
    geom_rect,
    scale_fill_manual,
    scale_x_continuous,
    scale_y_continuous,
    labs,
    guides,
    theme_minimal,
    theme,
    element_text,
    element_blank,
    element_line,
    element_rect
)

# 1. Prepare Titanic data
titanic_df = get_rdataset("Titanic", "datasets").data

plot_df = (
    titanic_df
    .groupby(["Sex", "Survived"], as_index=False)["Freq"]
    .sum()
)

# 2. Calculate mosaic coordinates
sex_order = ["Male", "Female"]
survival_order = ["No", "Yes"]

total = plot_df["Freq"].sum()

sex_totals = (
    plot_df.groupby("Sex")["Freq"]
    .sum()
    .reindex(sex_order)
)

rectangles = []
x_position = 0.0

for sex in sex_order:
    sex_total = sex_totals[sex]
    width = sex_total / total
    y_position = 0.0

    for survived in survival_order:
        freq = plot_df.loc[
            (plot_df["Sex"] == sex) &
            (plot_df["Survived"] == survived),
            "Freq"
        ].iloc[0]

        height = freq / sex_total

        rectangles.append({
            "Sex": sex,
            "Survived": survived,
            "Freq": freq,
            "xmin": x_position,
            "xmax": x_position + width,
            "ymin": y_position,
            "ymax": y_position + height
        })

        y_position += height

    x_position += width

mosaic_df = pd.DataFrame(rectangles)

# 3. Add spacing between rectangles
gap = 0.008

mosaic_df["xmin"] += gap / 2
mosaic_df["xmax"] -= gap / 2
mosaic_df["ymin"] += gap / 2
mosaic_df["ymax"] -= gap / 2

# 4. Colors and palette
colors = {
    "No": "#08519c",
    "Yes": "#6baed6"
}

palette = {
    "title": "#25364A",
    "text": "#595959",
    "muted": "#8C8C8C",
    "grid": "#E8EBEF",
    "white": "#FFFFFF"
}

# 5. Axis positions
x_breaks = [
    (
        mosaic_df.loc[
            mosaic_df["Sex"] == sex, "xmin"
        ].iloc[0]
        +
        mosaic_df.loc[
            mosaic_df["Sex"] == sex, "xmax"
        ].iloc[0]
    ) / 2
    for sex in sex_order
]

# 6. Create chart
chart = (
    ggplot(mosaic_df)
    + geom_rect(
        aes(
            xmin="xmin",
            xmax="xmax",
            ymin="ymin",
            ymax="ymax",
            fill="Survived"
        ),
        color=None,
        size=0
    )
    + scale_fill_manual(
        values=colors
    )
    + guides(
        fill="none"
    )
    + scale_x_continuous(
        breaks=x_breaks,
        labels=sex_order,
        limits=(0, 1),
        expand=(0, 0)
    )
    + scale_y_continuous(
        breaks=[0, 0.25, 0.5, 0.75, 1],
        labels=["0%", "25%", "50%", "75%", "100%"],
        limits=(0, 1),
        expand=(0, 0)
    )
    + labs(
        title="Who survived the Titanic?",
        subtitle="Passenger sex and survival",
        x="Sex",
        y="Proportion",
        caption="Source: Titanic dataset"
    )
    + theme_minimal(
        base_family="DejaVu Sans",
        base_size=8
    )
    + theme(
        figure_size=(5.3333, 3.3333),
        dpi=300,

        # Title
        plot_title=element_text(
            size=12,
            weight="bold",
            color=palette["title"],
            ha="left"
        ),
        plot_subtitle=element_text(
            size=8,
            color=palette["text"]
        ),

        # Axis titles
        axis_title=element_text(
            size=8,
            weight="bold",
            color="#4D4D4D"
        ),

        # Axis labels
        axis_text=element_text(
            size=7,
            color=palette["text"]
        ),
        axis_text_x=element_text(
            weight="bold"
        ),

        # Gridlines
        panel_grid_major_x=element_blank(),
        panel_grid_major_y=element_line(
            color=palette["grid"],
            size=0.35
        ),
        panel_grid_minor=element_blank(),

        # Remove borders and backgrounds
        panel_border=element_blank(),
        panel_background=element_blank(),
        plot_background=element_rect(
            fill=palette["white"],
            color=None
        ),
        axis_line=element_blank(),
        axis_ticks=element_blank(),

        # Caption
        plot_caption=element_text(
            size=6,
            color=palette["muted"],
            ha="left"
        ),

        # Layout
        plot_margin=0.03
    )
)

# 7. Export SVG
output_path = "src/stories/charts/mosaic/plot01-py.svg"

chart.save(
    filename=output_path,
    format="svg",
    dpi=300,
    verbose=False
)

# 8. Display chart
print(chart)
