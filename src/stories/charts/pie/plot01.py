
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

PROJECT_ROOT = Path(__file__).resolve().parents[4]

OUTPUT_PATH = (
    PROJECT_ROOT
    / "src"
    / "stories"
    / "charts"
    / "pie"
    / "plot01-py.svg"
)

treemap_data = pd.DataFrame(
    [
        ("Democrats", "Others", 24, 14.04, 63.16),
        ("Democrats", "Chuck & Nancy", 6, 3.51, 15.79),
        ("Democrats", "Hillary", 8, 4.68, 21.05),
        ("GOP", "Corker", 4, 2.34, 33.33),
        ("GOP", "Others", 8, 4.68, 66.67),
        ("The media", "Others", 14, 8.19, 15.73),
        ("The media", "NYT", 17, 9.94, 19.10),
        ("The media", "CNN", 13, 7.60, 14.61),
        ("The media", "NBC", 12, 7.02, 13.48),
        ("The media", '"Fake News!"', 33, 19.30, 37.08),
        ("Others", "Int'l figures", 3, 1.75, 9.38),
        ("Others", "Companies", 4, 2.34, 12.50),
        ("Others", "Sports", 8, 4.68, 25.00),
        ("Others", "Celebrities", 6, 3.51, 18.75),
        ("Others", "Comey", 7, 4.09, 21.88),
        ("Others", "Others", 4, 2.34, 12.50),
    ],
    columns=[
        "Topic",
        "Subtopic",
        "Raw",
        "percentage",
        "percentage_facet",
    ],
)


topic_colors = {
    "Democrats": "#377EB8",
    "GOP": "#D94841",
    "The media": "#E6AB35",
    "Others": "#8C7AA9",
}

topic_order = list(topic_colors.keys())


pie_data = (
    treemap_data
    .groupby("Topic", as_index=False)["Raw"]
    .sum()
    .rename(columns={"Raw": "n"})
)

pie_data["Topic"] = pd.Categorical(
    pie_data["Topic"],
    categories=topic_order,
    ordered=True,
)

pie_data = (
    pie_data
    .sort_values("Topic")
    .reset_index(drop=True)
)

total_observations = pie_data["n"].sum()

pie_data["freq"] = (
    pie_data["n"] / total_observations
)

pie_data["label"] = (
    pie_data["Topic"].astype(str)
    + "\n"
    + (pie_data["freq"] * 100).map(
        lambda value: f"{value:.1f}%"
    )
)



fig, ax = plt.subplots(
    figsize=(5.3333, 3.3333),
    facecolor="white",
)

fig.subplots_adjust(
    left=0.08,
    right=0.92,
    top=0.78,
    bottom=0.16,
)




wedges, _ = ax.pie(
    pie_data["freq"],
    colors=[
        topic_colors[str(topic)]
        for topic in pie_data["Topic"]
    ],
    startangle=90,
    counterclock=False,
    radius=1.0,
    wedgeprops={
        "edgecolor": "#FFFFFF",
        "linewidth": 0.6,
    },
)



for wedge, label in zip(
    wedges,
    pie_data["label"],
):

    angle = (
        wedge.theta1 + wedge.theta2
    ) / 2

    angle_rad = np.deg2rad(angle)

    radius = 0.55

    x = radius * np.cos(angle_rad)
    y = radius * np.sin(angle_rad)

    ax.text(
        x,
        y,
        label,
        ha="center",
        va="center",
        color="#FFFFFF",
        fontsize=8,
        fontweight="bold",
        linespacing=1.1,
    )


fig.text(
    0.5,
    0.91,
    "Donald’s Twitter Topics",
    ha="center",
    va="center",
    fontsize=12,
    fontweight="bold",
    color="#25364A",
)



fig.text(
    0.5,
    0.84,
    "Share of all observations",
    ha="center",
    va="center",
    fontsize=8,
    color="#666666",
)


fig.text(
    0.08,
    0.07,
    f"Total observations: {total_observations:,}",
    ha="left",
    va="center",
    fontsize=6,
    color="#8C8C8C",
)


ax.set_aspect("equal")
ax.set_axis_off()

fig.patch.set_facecolor("white")
ax.set_facecolor("white")



OUTPUT_PATH.parent.mkdir(
    parents=True,
    exist_ok=True,
)

fig.savefig(
    OUTPUT_PATH,
    format="svg",
    facecolor="white",
    edgecolor="none",
    bbox_inches=None,
    transparent=False,
)

print("\nChart successfully exported!")
print(f"Output: {OUTPUT_PATH.resolve()}")
print(f"Total observations: {total_observations:,}")

plt.show()
