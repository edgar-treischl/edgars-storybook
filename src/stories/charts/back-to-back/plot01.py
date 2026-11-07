
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.ticker import FuncFormatter
from pathlib import Path

# 1. Prepare data
df = pd.DataFrame({
    "Dimension": list("ABCDEFG") * 2,
    "Sex": ["Men"] * 7 + ["Women"] * 7,
    "Values": [
        16, 16, 15, 17, 9, 3, 1,
        -11, -1, -5, -1, -10, -11, -19
    ]
})

# Preserve categorical ordering
df["Dimension"] = pd.Categorical(
    df["Dimension"],
    categories=list("ABCDEFG"),
    ordered=True
)

df["Sex"] = pd.Categorical(
    df["Sex"],
    categories=["Men", "Women"],
    ordered=True
)

# 2. Diverging bar chart
fig, ax = plt.subplots(figsize=(10, 6.5))

# ColorBrewer Paired palette
palette = sns.color_palette("Paired", 2)

colors = {
    "Men": palette[0],
    "Women": palette[1]
}

# Draw horizontal bars
bar_height = 0.72

for i, dimension in enumerate(df["Dimension"].cat.categories):
    subset = df[df["Dimension"] == dimension]

    for _, row in subset.iterrows():
        ax.barh(
            i,
            row["Values"],
            height=bar_height,
            color=colors[row["Sex"]],
            label=row["Sex"] if i == 0 else None
        )

# 3. Zero reference line
ax.axvline(
    x=0,
    color="#666666",
    linewidth=0.35
)

# 4. Axis limits and ticks
ax.set_xlim(-20, 20)
ax.set_xticks(range(-20, 21, 5))

# Display absolute values on the x-axis
ax.xaxis.set_major_formatter(
    FuncFormatter(lambda x, pos: f"{abs(int(x))}")
)

# 5. Axis labels
ax.set_xlabel(
    "Value",
    fontsize=8,
    fontweight="bold",
    color="#4D4D4D"
)

ax.set_ylabel("")

# 6. Tick styling
ax.tick_params(
    axis="x",
    labelsize=7,
    colors="#808080"
)

ax.tick_params(
    axis="y",
    labelsize=8,
    colors="#25364A"
)

# 7. Grid styling
ax.grid(
    axis="x",
    color="#E8EBEF",
    linewidth=0.26
)

ax.grid(axis="y", visible=False)
ax.set_axisbelow(True)

# Remove unnecessary spines
sns.despine(
    ax=ax,
    left=True,
    bottom=True
)

# 8. Legend at bottom (reversed order)
handles, labels = ax.get_legend_handles_labels()

ax.legend(
    handles[::-1],
    labels[::-1],
    loc="upper center",
    bbox_to_anchor=(0.5, -0.12),
    ncol=2,
    frameon=False,
    fontsize=7,
    labelcolor="#666666",
    handlelength=1.2,
    handleheight=0.8,
    columnspacing=1.0
)

# 9. Plot margins
plt.subplots_adjust(
    left=0.12,
    right=0.98,
    top=0.96,
    bottom=0.20
)

# 10. Export SVG
out_dir = Path(__file__).parent

fig.set_size_inches(10, 6.5)

fig.savefig(
    out_dir / "plot01-py.svg",
    format="svg",
    dpi=100,
    bbox_inches="tight"
)

print(f"Generated {out_dir / 'plot01-py.svg'}")

# 11. Display chart
plt.show()

from pathlib import Path

# Output directory (same directory as this script)
out_dir = Path(__file__).parent

# Export static SVG preview
fig.savefig(
    out_dir / "plot01-py.svg",
    format="svg",
    width=1000,
    height=650,
    bbox_inches="tight"
)

print(f"Generated {out_dir / 'plot01-py.svg'}")

plt.show()

