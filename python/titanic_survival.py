
import pandas as pd
import plotly.graph_objects as go

# Titanic contingency table: Class × Sex × Survived
dat = pd.DataFrame([
    ("1st", "Male",   "No",  118),
    ("1st", "Male",   "Yes",  62),
    ("1st", "Female", "No",    4),
    ("1st", "Female", "Yes", 141),
    ("2nd", "Male",   "No",  154),
    ("2nd", "Male",   "Yes",  25),
    ("2nd", "Female", "No",   13),
    ("2nd", "Female", "Yes",  93),
    ("3rd", "Male",   "No",  422),
    ("3rd", "Male",   "Yes",  88),
    ("3rd", "Female", "No",  106),
    ("3rd", "Female", "Yes",  90),
    ("Crew", "Male",  "No",  670),
    ("Crew", "Male",  "Yes", 192),
    ("Crew", "Female","No",    3),
    ("Crew", "Female","Yes",  20),
], columns=["Class", "Sex", "Survived", "n"])

class_order = ["1st", "2nd", "3rd", "Crew"]
sex_order = ["Female", "Male"]
survival_order = ["Yes", "No"]

dat["Class"] = pd.Categorical(
    dat["Class"], categories=class_order, ordered=True
)
dat["Sex"] = pd.Categorical(
    dat["Sex"], categories=sex_order, ordered=True
)
dat["Survived"] = pd.Categorical(
    dat["Survived"], categories=survival_order, ordered=True
)

survival_cols = {
    "Yes": "#009E73",
    "No": "#E69F00",
}

# Nodes: four classes, two sexes, two outcomes.
labels = class_order + sex_order + ["Yes", "No"]
node_ids = {label: i for i, label in enumerate(labels)}

# Keep each class→sex link split by survival outcome,
# so the flow colors consistently represent survival.
links = []

for _, row in dat.iterrows():
    links.append({
        "source": node_ids[row["Class"]],
        "target": node_ids[row["Sex"]],
        "value": int(row["n"]),
        "color": survival_cols[row["Survived"]],
    })

# Aggregate the sex→survival links across passenger classes.
sex_survival = (
    dat.groupby(["Sex", "Survived"], observed=True)["n"]
    .sum()
    .reset_index()
)

for _, row in sex_survival.iterrows():
    links.append({
        "source": node_ids[row["Sex"]],
        "target": node_ids[row["Survived"]],
        "value": int(row["n"]),
        "color": survival_cols[row["Survived"]],
    })

fig = go.Figure(go.Sankey(
    arrangement="fixed",
    node=dict(
        label=labels,
        x=(
            [0.01] * 4
            + [0.50] * 2
            + [0.99] * 2
        ),
        y=[
            0.05, 0.32, 0.59, 0.86,
            0.25, 0.65,
            0.25, 0.65,
        ],
        pad=18,
        thickness=18,
        color="white",
        line=dict(color="#404040", width=0.6),
        hovertemplate="%{label}<extra></extra>",
    ),
    link=dict(
        source=[link["source"] for link in links],
        target=[link["target"] for link in links],
        value=[link["value"] for link in links],
        color=[
            link["color"] for link in links
        ],
        hovertemplate=(
            "%{source.label} → %{target.label}"
            "<br>Passengers: %{value:,}"
            "<extra></extra>"
        ),
    ),
))

fig.update_layout(
    title=dict(
        text=(
            "Who survived the Titanic?"
            "<br><sup>Passenger class, sex, and survival</sup>"
        ),
        font=dict(size=14, color="#222222"),
        x=0.02,
        xanchor="left",
    ),
    font=dict(
        family="Arial, sans-serif",
        size=12,
        color="#303030",
    ),
    paper_bgcolor="white",
    plot_bgcolor="white",
    height=620,
    margin=dict(l=25, r=25, t=90, b=70),
    legend=dict(
        orientation="h",
        yanchor="top",
        y=-0.05,
        xanchor="center",
        x=0.5,
    ),
    annotations=[
        dict(
            x=0.01, y=1.02,
            xref="paper", yref="paper",
            text="Class",
            showarrow=False,
            font=dict(size=12),
        ),
        dict(
            x=0.50, y=1.02,
            xref="paper", yref="paper",
            text="Sex",
            showarrow=False,
            font=dict(size=12),
        ),
        dict(
            x=0.99, y=1.02,
            xref="paper", yref="paper",
            text="Survival",
            showarrow=False,
            xanchor="right",
            font=dict(size=12),
        ),
        dict(
            x=0, y=-0.12,
            xref="paper", yref="paper",
            text="Source: Titanic dataset",
            showarrow=False,
            xanchor="left",
            font=dict(size=10, color="#888888"),
        ),
    ],
)

from pathlib import Path

output = Path("public/titanic_survival.html")
output.parent.mkdir(parents=True, exist_ok=True)

fig.write_html(output)
print(f"Visualization saved to {output}")
