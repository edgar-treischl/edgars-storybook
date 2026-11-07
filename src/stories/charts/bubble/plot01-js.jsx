
import { useEffect, useRef } from "react";
import * as d3 from "d3";

const DATA_URL =
  "https://raw.githubusercontent.com/plotly/datasets/master/gapminderDataFiveYear.csv";

const CONTINENTS = [
  "Africa",
  "Americas",
  "Asia",
  "Europe",
  "Oceania",
];

const DEFAULT_COLORS = {
  Africa: "#440154",
  Americas: "#3B528B",
  Asia: "#21918C",
  Europe: "#5EC962",
  Oceania: "#FDE725",
};

export default function BubbleChart({
  data,
  colors = DEFAULT_COLORS,
  width = 800,
  height = 500,
  title = "GDP and life expectancy",
  subtitle = "Bubble size represents population",
  caption = "Source: Gapminder",
  className,
  style,
}) {
  const svgRef = useRef(null);

  useEffect(() => {
    let cancelled = false;

    const svgElement = svgRef.current;
    if (!svgElement) return;

    const renderChart = async () => {
      let rawData = data;

      // 1. Load Gapminder data
      if (!rawData) {
        const response = await fetch(DATA_URL);

        if (!response.ok) {
          throw new Error("Unable to load Gapminder data");
        }

        const csv = await response.text();

        rawData = d3.csvParse(csv, (d) => ({
          country: d.country,
          continent: d.continent,
          year: +d.year,
          pop: +d.pop,
          gdpPercap: +d.gdpPercap,
          lifeExp: +d.lifeExp,
        }));
      }

      if (cancelled) return;

      // 2. Prepare data
      const chartData = rawData
        .filter(
          (d) =>
            Number(d.year) === 2007 &&
            Number(d.gdpPercap) > 0 &&
            Number(d.lifeExp) >= 30 &&
            Number(d.lifeExp) <= 90 &&
            Number(d.pop) > 0
        )
        .map((d) => ({
          ...d,
          gdpPercap: Number(d.gdpPercap),
          lifeExp: Number(d.lifeExp),
          pop_m: Number(d.pop) / 1e6,
        }))
        .sort((a, b) => a.pop_m - b.pop_m);

      if (!chartData.length) return;

      // 3. Chart dimensions
      const margin = {
        top: 78,
        right: 25,
        bottom: 105,
        left: 75,
      };

      const plotWidth = width - margin.left - margin.right;
      const plotHeight = height - margin.top - margin.bottom;

      if (plotWidth <= 0 || plotHeight <= 0) return;

      // 4. SVG
      const svg = d3.select(svgElement);

      svg.selectAll("*").remove();

      svg
        .attr("viewBox", `0 0 ${width} ${height}`)
        .attr("role", "img")
        .attr("aria-label", title)
        .attr("width", "100%")
        .attr("preserveAspectRatio", "xMidYMid meet");

      // 5. Scales
      const x = d3
        .scaleLog()
        .domain([400, 70000])
        .range([0, plotWidth]);

      const y = d3
        .scaleLinear()
        .domain([30, 90])
        .range([plotHeight, 0]);

      const radius = d3
        .scaleSqrt()
        .domain(d3.extent(chartData, (d) => d.pop_m))
        .range([1, 12]);

      // 6. Main chart group
      const chart = svg
        .append("g")
        .attr(
          "transform",
          `translate(${margin.left},${margin.top})`
        );

      // 7. Title
      svg
        .append("text")
        .attr("x", margin.left)
        .attr("y", 27)
        .attr("font-size", 19)
        .attr("font-weight", "bold")
        .attr("fill", "#25364A")
        .text(title);

      // 8. Subtitle
      svg
        .append("text")
        .attr("x", margin.left)
        .attr("y", 49)
        .attr("font-size", 12)
        .attr("fill", "#666666")
        .text(subtitle);

      // 9. Grid
      const xTicks = [
        500,
        1000,
        2500,
        5000,
        10000,
        25000,
        50000,
      ];

      const yTicks = d3.range(30, 91, 10);

      chart
        .append("g")
        .attr("class", "grid")
        .call(
          d3
            .axisBottom(x)
            .tickValues(xTicks)
            .tickSize(plotHeight)
            .tickFormat("")
        )
        .call((g) => g.select(".domain").remove())
        .call((g) =>
          g
            .selectAll("line")
            .attr("stroke", "#E8EBEF")
            .attr("stroke-width", 0.65)
        );

      chart
        .append("g")
        .attr("class", "grid")
        .call(
          d3
            .axisLeft(y)
            .tickValues(yTicks)
            .tickSize(-plotWidth)
            .tickFormat("")
        )
        .call((g) => g.select(".domain").remove())
        .call((g) =>
          g
            .selectAll("line")
            .attr("stroke", "#E8EBEF")
            .attr("stroke-width", 0.65)
        );

      // 10. X axis
      chart
        .append("g")
        .attr("transform", `translate(0,${plotHeight})`)
        .call(
          d3
            .axisBottom(x)
            .tickValues(xTicks)
            .tickFormat(d3.format("$,.0f"))
            .tickSize(0)
            .tickPadding(8)
        )
        .call((g) => g.select(".domain").remove())
        .call((g) =>
          g
            .selectAll("text")
            .attr("font-size", 10)
            .attr("fill", "#808080")
        );

      // 11. Y axis
      chart
        .append("g")
        .call(
          d3
            .axisLeft(y)
            .tickValues(yTicks)
            .tickSize(0)
            .tickPadding(8)
        )
        .call((g) => g.select(".domain").remove())
        .call((g) =>
          g
            .selectAll("text")
            .attr("font-size", 10)
            .attr("fill", "#808080")
        );

      // 12. Axis titles
      chart
        .append("text")
        .attr("x", plotWidth / 2)
        .attr("y", plotHeight + 43)
        .attr("text-anchor", "middle")
        .attr("font-size", 11)
        .attr("font-weight", "bold")
        .attr("fill", "#4D4D4D")
        .text("GDP per capita");

      chart
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("x", -plotHeight / 2)
        .attr("y", -53)
        .attr("text-anchor", "middle")
        .attr("font-size", 11)
        .attr("font-weight", "bold")
        .attr("fill", "#4D4D4D")
        .text("Life expectancy");

      // 13. Bubble chart
      chart
        .append("g")
        .selectAll("circle")
        .data(chartData)
        .join("circle")
        .attr("cx", (d) => x(d.gdpPercap))
        .attr("cy", (d) => y(d.lifeExp))
        .attr("r", (d) => radius(d.pop_m))
        .attr("fill", (d) => colors[d.continent] ?? "#999999")
        .attr("fill-opacity", 0.7)
        .attr("stroke", "none")
        .append("title")
        .text(
          (d) =>
            `${d.country}\n` +
            `Continent: ${d.continent}\n` +
            `GDP per capita: ${d3.format("$,.0f")(d.gdpPercap)}\n` +
            `Life expectancy: ${d.lifeExp.toFixed(1)} years\n` +
            `Population: ${d3.format(",.1f")(d.pop_m)} million`
        );

      // 14. Annotation
      const annotation = chart
        .append("g")
        .attr(
          "transform",
          `translate(${x(2000)},${y(44)})`
        );

      annotation
        .append("rect")
        .attr("width", 238)
        .attr("height", 55)
        .attr("rx", 5)
        .attr("fill", "#FFFFFF")
        .attr("fill-opacity", 0.92)
        .attr("stroke", "#D9D9D9")
        .attr("stroke-width", 0.8);

      annotation
        .append("text")
        .attr("x", 10)
        .attr("y", 17)
        .attr("font-size", 10)
        .attr("font-weight", "bold")
        .attr("fill", "#303030")
        .text("Example interpretation:");

      annotation
        .append("text")
        .attr("x", 10)
        .attr("y", 33)
        .attr("font-size", 9)
        .attr("fill", "#666666")
        .text("Higher GDP per capita is generally");

      annotation
        .append("text")
        .attr("x", 10)
        .attr("y", 46)
        .attr("font-size", 9)
        .attr("fill", "#666666")
        .text("associated with longer life expectancy.");

      // 15. Legend (single horizontal row)
      const legendItems = [...CONTINENTS].reverse();

      const legendItemWidth = 85;
      const legendTitleWidth = 75;

      const totalLegendWidth =
        legendTitleWidth + legendItems.length * legendItemWidth;

      const legend = svg
        .append("g")
        .attr(
          "transform",
          `translate(${(width - totalLegendWidth) / 2},${height - 44})`
        );

      // Legend title
      legend
        .append("text")
        .attr("x", 0)
        .attr("y", 4)
        .attr("font-size", 11)
        .attr("font-weight", "bold")
        .attr("fill", "#25364A")
        .text("Continent");

      // Legend items
      legendItems.forEach((continent, i) => {
        const item = legend
          .append("g")
          .attr(
            "transform",
            `translate(${legendTitleWidth + i * legendItemWidth},0)`
          );

        item
          .append("circle")
          .attr("cx", 4)
          .attr("cy", 0)
          .attr("r", 4)
          .attr("fill", colors[continent] ?? "#999999");

        item
          .append("text")
          .attr("x", 13)
          .attr("y", 4)
          .attr("font-size", 9)
          .attr("fill", "#666666")
          .text(continent);
      });

      // 16. Caption
      svg
        .append("text")
        .attr("x", margin.left)
        .attr("y", height - 10)
        .attr("font-size", 8)
        .attr("fill", "#8C8C8C")
        .text(caption);
    };

    renderChart().catch((error) => {
      if (!cancelled) {
        console.error("Bubble chart error:", error);
      }
    });

    return () => {
      cancelled = true;
      d3.select(svgElement).selectAll("*").remove();
    };
  }, [
    data,
    colors,
    width,
    height,
    title,
    subtitle,
    caption,
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

export { CONTINENTS, DEFAULT_COLORS };
