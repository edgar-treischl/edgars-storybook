
import { useEffect, useRef } from "react";
import * as d3 from "d3";

const DEFAULT_DATA = [
  { Class: "1st", Sex: "Female", Survived: "Yes", n: 141 },
  { Class: "1st", Sex: "Female", Survived: "No", n: 4 },
  { Class: "1st", Sex: "Male", Survived: "Yes", n: 62 },
  { Class: "1st", Sex: "Male", Survived: "No", n: 118 },
  { Class: "2nd", Sex: "Female", Survived: "Yes", n: 93 },
  { Class: "2nd", Sex: "Female", Survived: "No", n: 13 },
  { Class: "2nd", Sex: "Male", Survived: "Yes", n: 25 },
  { Class: "2nd", Sex: "Male", Survived: "No", n: 154 },
  { Class: "3rd", Sex: "Female", Survived: "Yes", n: 90 },
  { Class: "3rd", Sex: "Female", Survived: "No", n: 106 },
  { Class: "3rd", Sex: "Male", Survived: "Yes", n: 88 },
  { Class: "3rd", Sex: "Male", Survived: "No", n: 422 },
  { Class: "Crew", Sex: "Female", Survived: "Yes", n: 20 },
  { Class: "Crew", Sex: "Female", Survived: "No", n: 3 },
  { Class: "Crew", Sex: "Male", Survived: "Yes", n: 192 },
  { Class: "Crew", Sex: "Male", Survived: "No", n: 670 },
];

const DEFAULT_AXES = [
  { key: "Class", title: "Class", values: ["1st", "2nd", "3rd", "Crew"] },
  { key: "Sex", title: "Sex", values: ["Female", "Male"] },
  { key: "Survived", title: "Survival", values: ["Yes", "No"] },
];

const DEFAULT_COLORS = {
  Yes: "#009E73",
  No: "#E69F00",
};

export default function TitanicAlluvialChart({
  data = DEFAULT_DATA,
  axes = DEFAULT_AXES,
  colors = DEFAULT_COLORS,
  width = 800,
  height = 500,
  title = "Who survived the Titanic?",
  subtitle = "Passenger class, sex, and survival",
  caption = "Source: Titanic dataset",
  className,
  style,
  onFlowClick,
}) {
  const svgRef = useRef(null);
  const tooltipRef = useRef(null);

  useEffect(() => {
    const svgElement = svgRef.current;
    if (!svgElement || !data.length || axes.length < 2) return;

    const svg = d3.select(svgElement);
    svg.selectAll("*").remove();

    const margin = {
      top: 105,
      right: 50,
      bottom: 75,
      left: 65,
    };

    const plotH = height - margin.top - margin.bottom;
    const plotW = width - margin.left - margin.right;
    const barWidth = 25;
    const total = d3.sum(data, (d) => d.n);

    if (
      total <= 0 ||
      plotH <= 12 ||
      plotW <= 0 ||
      data.some((d) => !Number.isFinite(d.n) || d.n < 0)
    ) {
      return;
    }

    const axisX = axes.map(
      (_, i) =>
        margin.left +
        plotW * (0.05 + (0.9 * i) / (axes.length - 1))
    );

    const yScale = (plotH - 12) / total;
    const bandHeight = (n) => n * yScale;

    svg
      .attr("viewBox", `0 0 ${width} ${height}`)
      .attr("role", "img")
      .attr("aria-label", title)
      .attr("width", "100%")
      .attr("preserveAspectRatio", "xMidYMid meet");

    // Chart heading
    svg
      .append("text")
      .attr("x", margin.left)
      .attr("y", 27)
      .attr("font-size", 19)
      .attr("font-weight", "bold")
      .attr("fill", "#222")
      .text(title);

    svg
      .append("text")
      .attr("x", margin.left)
      .attr("y", 49)
      .attr("font-size", 13)
      .attr("fill", "#666")
      .text(subtitle);

    // Aggregate category counts into strata.
    const strata = axes.map((axis, axisIndex) => {
      let y = margin.top;

      return axis.values.map((value) => {
        const count = d3.sum(
          data.filter((d) => d[axis.key] === value),
          (d) => d.n
        );

        const node = {
          axis: axisIndex,
          key: axis.key,
          value,
          count,
          x: axisX[axisIndex],
          y,
          h: bandHeight(count),
        };

        y += node.h;
        return node;
      });
    });

    const nodeMaps = strata.map(
      (nodes) => new Map(nodes.map((node) => [node.value, node]))
    );

    const order = axes.map(
      (axis) => (d) => axis.values.indexOf(d[axis.key])
    );

    const flows = data.map((d, index) => ({
      ...d,
      index,
      intervals: [],
    }));

    // Allocate a vertical interval for every flow at every axis.
    axes.forEach((axis, axisIndex) => {
      const comparator = (a, b) => {
        for (let j = 0; j < axes.length; j++) {
          const k = (axisIndex + j) % axes.length;
          const diff = order[k](a) - order[k](b);
          if (diff !== 0) return diff;
        }
        return a.index - b.index;
      };

      axis.values.forEach((value) => {
        const node = nodeMaps[axisIndex].get(value);
        if (!node) return;

        let y = node.y;

        flows
          .filter((flow) => flow[axis.key] === value)
          .sort(comparator)
          .forEach((flow) => {
            const h = bandHeight(flow.n);
            flow.intervals[axisIndex] = {
              y0: y,
              y1: y + h,
            };
            y += h;
          });
      });
    });

    // Horizontal grid and count labels.
    const ticks = d3.ticks(0, total, 5);
    const grid = svg.append("g");

    grid
      .selectAll("line")
      .data(ticks)
      .join("line")
      .attr("x1", margin.left)
      .attr("x2", width - margin.right)
      .attr("y1", (d) => margin.top + d * yScale)
      .attr("y2", (d) => margin.top + d * yScale)
      .attr("stroke", "#E5E5E5")
      .attr("stroke-width", 0.4);

    grid
      .selectAll("text")
      .data(ticks)
      .join("text")
      .attr("x", margin.left - 10)
      .attr("y", (d) => margin.top + d * yScale + 4)
      .attr("text-anchor", "end")
      .attr("font-size", 10)
      .attr("fill", "#555")
      .text(d3.format(","));

    // Create a ribbon between two neighboring axes.
    function flowPath(flow, i) {
      const a = flow.intervals[i];
      const b = flow.intervals[i + 1];

      if (!a || !b) return "";

      const x1 = axisX[i] + barWidth / 2;
      const x2 = axisX[i + 1] - barWidth / 2;
      const c = (x2 - x1) * 0.45;

      return [
        `M${x1},${a.y0}`,
        `C${x1 + c},${a.y0} ${x2 - c},${b.y0} ${x2},${b.y0}`,
        `L${x2},${b.y1}`,
        `C${x2 - c},${b.y1} ${x1 + c},${a.y1} ${x1},${a.y1}`,
        "Z",
      ].join(" ");
    }

    // Flow ribbons
    const flowLayer = svg.append("g");

    flows.forEach((flow) => {
      for (let i = 0; i < axes.length - 1; i++) {
        const path = flowLayer
          .append("path")
          .attr("class", "flow")
          .attr("d", flowPath(flow, i))
          .attr("fill", colors[flow.Survived] ?? "#999")
          .attr("opacity", 0.65)
          .style("mix-blend-mode", "multiply")
          .style("cursor", onFlowClick ? "pointer" : "default");

        path
          .append("title")
          .text(
            `${axes
              .map((axis) => flow[axis.key])
              .join(" → ")}: ${flow.n} passengers`
          );

        if (onFlowClick) {
          path
            .on("click", () => onFlowClick(flow))
            .on("keydown", (event) => {
              if (event.key === "Enter" || event.key === " ") {
                event.preventDefault();
                onFlowClick(flow);
              }
            })
            .attr("tabindex", 0)
            .attr("role", "button")
            .attr(
              "aria-label",
              `${flow.Class}, ${flow.Sex}, ${flow.Survived}: ${flow.n}`
            );
        }
      }
    });

    // Category rectangles and labels.
    strata.forEach((nodes) => {
      const group = svg.append("g");

      group
        .selectAll("rect")
        .data(nodes)
        .join("rect")
        .attr("class", "stratum")
        .attr("x", (d) => d.x - barWidth / 2)
        .attr("y", (d) => d.y)
        .attr("width", barWidth)
        .attr("height", (d) => d.h)
        .attr("fill", "white")
        .attr("stroke", "#404040")
        .attr("stroke-width", 0.6);

      group
        .selectAll("text")
        .data(nodes)
        .join("text")
        .attr("class", "stratum-label")
        .attr("x", (d) => d.x)
        .attr("y", (d) => d.y + d.h / 2)
        .attr("font-size", 11)
        .attr("font-weight", "bold")
        .attr("text-anchor", "middle")
        .attr("dominant-baseline", "middle")
        .attr("fill", "#303030")
        .style("pointer-events", "none")
        .text((d) => d.value);
    });

    // Axis headings
    svg
      .append("g")
      .selectAll("text")
      .data(axes)
      .join("text")
      .attr("class", "axis-label")
      .attr("x", (_, i) => axisX[i])
      .attr("y", margin.top - 18)
      .attr("font-size", 12)
      .attr("font-weight", 600)
      .attr("text-anchor", "middle")
      .attr("fill", "#303030")
      .text((d) => d.title);

    // Legend
    const legendItems = [
      { key: "Yes", label: "Survived" },
      { key: "No", label: "Not survived" },
    ];

    const legend = svg
      .append("g")
      .attr("transform", `translate(${width / 2 - 80},${height - 39})`);

    legendItems.forEach((item, i) => {
      const g = legend
        .append("g")
        .attr("transform", `translate(${i * 120},0)`);

      g.append("rect")
        .attr("width", 12)
        .attr("height", 12)
        .attr("rx", 2)
        .attr("fill", colors[item.key] ?? "#999");

      g.append("text")
        .attr("x", 18)
        .attr("y", 10)
        .attr("font-size", 11)
        .attr("fill", "#444")
        .text(item.label);
    });

    // Caption
    svg
      .append("text")
      .attr("x", margin.left)
      .attr("y", height - 10)
      .attr("font-size", 10)
      .attr("fill", "#888")
      .text(caption);

    return () => {
      svg.selectAll("*").remove();
    };
  }, [
    data,
    axes,
    colors,
    width,
    height,
    title,
    subtitle,
    caption,
    onFlowClick,
  ]);

  return (
    <div className={className} style={style}>
      <svg
        ref={svgRef}
        style={{
          display: "block",
          width: "100%",
          height: "auto",
          overflow: "visible",
        }}
      />
    </div>
  );
}

export { DEFAULT_DATA, DEFAULT_AXES, DEFAULT_COLORS };
