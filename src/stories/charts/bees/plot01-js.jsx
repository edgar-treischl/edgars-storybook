
import React, { useMemo } from "react";
import * as d3 from "d3";
import DATA from "../../../data/penguins.json";

const SPECIES = ["Adelie", "Chinstrap", "Gentoo"];

const COLORS = {
  Adelie: "#E69F00",
  Chinstrap: "#56B4E9",
  Gentoo: "#009E73",
};

const W = 1400;
const H = 900;

const M = {
  top: 145,
  right: 55,
  bottom: 115,
  left: 155,
};

const JITTER_WIDTH = 110;
const TICK_STEP = 500;
const DOT_RADIUS = 9;

export default function PenguinBodyMassChart() {
  const { width, height, x, y, points, ticks } = useMemo(() => {
    const width = W - M.left - M.right;
    const height = H - M.top - M.bottom;

    const points = DATA.filter(
      (d) =>
        SPECIES.includes(d.species) &&
        d.body_mass_g != null &&
        Number.isFinite(Number(d.body_mass_g))
    ).map((d, i) => ({
      ...d,
      body_mass_g: Number(d.body_mass_g),
      id: i,
      jitter:
        (((i * 73) % 101) / 100 - 0.5) * JITTER_WIDTH,
    }));

    const x = d3
      .scalePoint()
      .domain(SPECIES)
      .range([0, width])
      .padding(0.5);

    const minMass = d3.min(points, (d) => d.body_mass_g) ?? 2500;
    const maxMass = d3.max(points, (d) => d.body_mass_g) ?? 6500;

    const yMin =
      Math.floor(minMass / TICK_STEP) * TICK_STEP - TICK_STEP;
    const yMax =
      Math.ceil(maxMass / TICK_STEP) * TICK_STEP + TICK_STEP;

    const y = d3
      .scaleLinear()
      .domain([yMin, yMax])
      .range([height, 0]);

    const ticks = y.ticks(8);

    return { width, height, x, y, points, ticks };
  }, []);

  return (
    <section
      style={{
        width: "100%",
        maxWidth: 1600,
        margin: "0 auto",
        background: "#fff",
        fontFamily: "Arial, Helvetica, sans-serif",
      }}
    >
      <svg
        viewBox={`0 0 ${W} ${H}`}
        role="img"
        aria-label="Body mass of Palmer penguins by species"
        style={{
          display: "block",
          width: "100%",
          height: "auto",
        }}
      >
        <title>Body Mass of Palmer Penguins</title>
        <desc>
          Individual body mass observations for Adelie,
          Chinstrap, and Gentoo penguins. The vertical axis
          automatically adjusts to include all valid observations.
        </desc>

        <defs>
          <clipPath id="penguin-plot-clip">
            <rect width={width} height={height} />
          </clipPath>
        </defs>

        <rect width={W} height={H} fill="#fff" />

        {/* Main title */}
        <text
          x={M.left}
          y={65}
          fontSize={36}
          fontWeight="bold"
          fill="#222"
        >
          Body Mass of Palmer Penguins
        </text>

        {/* Subtitle */}
        <text
          x={M.left}
          y={105}
          fontSize={21}
          fill="#666"
        >
          Individual observations by species
        </text>

        <g transform={`translate(${M.left},${M.top})`}>
          {/* Grid */}
          {ticks.map((tick) => (
            <line
              key={`grid-${tick}`}
              x1={0}
              x2={width}
              y1={y(tick)}
              y2={y(tick)}
              stroke="#E2E5E9"
              strokeWidth={1.4}
            />
          ))}

          {/* Y-axis tick labels */}
          {ticks.map((tick) => (
            <text
              key={`y-${tick}`}
              x={-20}
              y={y(tick)}
              textAnchor="end"
              dominantBaseline="middle"
              fontSize={19}
              fill="#333"
            >
              {d3.format(",")(tick)}
            </text>
          ))}

          {/* Species labels */}
          {SPECIES.map((species) => (
            <text
              key={species}
              x={x(species)}
              y={height + 43}
              textAnchor="middle"
              fontSize={22}
              fontWeight="600"
              fill="#222"
            >
              {species}
            </text>
          ))}

          {/* Y-axis title */}
          <text
            transform={`translate(-105,${height / 2}) rotate(-90)`}
            textAnchor="middle"
            fontSize={23}
            fontWeight="500"
            fill="#333"
          >
            Body mass (g)
          </text>

          {/* Data points */}
          <g clipPath="url(#penguin-plot-clip)">
            {points.map((d) => (
              <circle
                key={d.id}
                cx={x(d.species) + d.jitter}
                cy={y(d.body_mass_g)}
                r={DOT_RADIUS}
                fill={COLORS[d.species]}
                fillOpacity={0.82}
                stroke="#fff"
                strokeWidth={1.2}
              >
                <title>
                  {`${d.species}: ${d.body_mass_g.toLocaleString()} g`}
                </title>
              </circle>
            ))}
          </g>

          {/* Axes */}
          <line
            x1={0}
            x2={0}
            y1={0}
            y2={height}
            stroke="#333"
            strokeWidth={1.5}
          />

          <line
            x1={0}
            x2={width}
            y1={height}
            y2={height}
            stroke="#333"
            strokeWidth={1.5}
          />
        </g>
      </svg>
    </section>
  );
}
