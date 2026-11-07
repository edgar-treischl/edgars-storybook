
import pandas as pd
import plotly.graph_objects as go
from palmerpenguins import load_penguins
from pathlib import Path

# Load Palmer Penguins dataset
dat = load_penguins()

# Calculate average body mass by species
plot_data_summary = (
    dat.groupby("species", observed=True)
    .agg(body_mass=("body_mass_g", "mean"))
    .reset_index()
)

species_order = [
    "Adelie",
    "Chinstrap",
    "Gentoo",
]

plot_data_summary["species"] = pd.Categorical(
    plot_data_summary["species"],
    categories=species_order,
    ordered=True,
)

plot_data_summary = plot_data_summary.sort_values("species")

# Create bar chart
fig = go.Figure(
    go.Bar(
        x=plot_data_summary["species"],
        y=plot_data_summary["body_mass"],
        marker=dict(
            color="#4C78A8",
            line=dict(color="#404040", width=0.6),
        ),
        hovertemplate=(
            "%{x}"
            "<br>Average body mass: %{y:,.1f} g"
            "<extra></extra>"
        ),
    )
)

# Layout

fig.update_layout(
    title=dict(
        text="Average body mass by penguin species",
        font=dict(size=26, color="#222222"),
        x=0.02,
        xanchor="left",
    ),
    font=dict(
        family="Arial, sans-serif",
        size=21,
        color="#303030",
    ),
    paper_bgcolor="white",
    plot_bgcolor="white",
    height=750,
    margin=dict(l=115, r=45, t=120, b=120),
    showlegend=False,

    xaxis=dict(
        title=dict(
            text="Penguin species",
            font=dict(size=23),
        ),
        tickfont=dict(size=20),
        showgrid=False,
        zeroline=False,
    ),

    yaxis=dict(
        title=dict(
            text="Average body mass (g)",
            font=dict(size=23),
        ),
        tickfont=dict(size=20),
        showgrid=True,
        gridcolor="#EAEAEA",
        zeroline=False,
    ),

    annotations=[
        dict(
            x=0,
            y=-0.19,
            xref="paper",
            yref="paper",
            text="Average body mass by penguin species",
            showarrow=False,
            xanchor="left",
            font=dict(size=17, color="#888888"),
        ),
    ],
)


# Export SVG
out_dir = Path(__file__).parent

fig.write_image(
    out_dir / "plot01-py.svg",
    format="svg",
    width=1000,
    height=650,
)

print(f"Generated {out_dir / 'plot01-py.svg'}")
