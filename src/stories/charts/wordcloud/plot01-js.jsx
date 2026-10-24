
import React, { useEffect, useRef, useState } from "react";
import * as d3 from "d3";
import cloud from "d3-cloud";
import { removeStopwords, eng } from "stopword";
import "./AliceWordCloud.css";

// Deterministic random number generator
function seededRandom(seed) {
  return function () {
    let t = (seed += 0x6d2b79f5);
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// Tokenize, remove stop words, count words, and filter
function tokenizeAndCount(text) {
  const tokens =
    text.toLowerCase().match(/\b[a-z]+(?:'[a-z]+)?\b/g) || [];

  const filtered = removeStopwords(tokens, eng);
  const counts = new Map();

  filtered.forEach((word) => {
    counts.set(word, (counts.get(word) || 0) + 1);
  });

  return Array.from(counts, ([word, n]) => ({ word, n }))
    .filter(({ word, n }) => n > 7 && word !== "alice")
    .sort((a, b) => b.n - a.n);
}

export default function AliceWordCloud() {
  const containerRef = useRef(null);
  const svgRef = useRef(null);

  const [words, setWords] = useState([]);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(true);

  const [dimensions, setDimensions] = useState({
    width: 900,
    height: 650,
  });

  // Load alice.txt from the public directory
  useEffect(() => {
    let cancelled = false;

    async function loadWords() {
      try {
        const response = await fetch("./alice.txt");

        if (!response.ok) {
          throw new Error(
            `Failed to load /alice.txt (HTTP ${response.status}). ` +
              "Place alice.txt inside your public directory."
          );
        }

        const text = await response.text();

        if (!text.trim()) {
          throw new Error("alice.txt is empty.");
        }

        const result = tokenizeAndCount(text);

        if (!result.length) {
          throw new Error(
            "No words matched the filter. Check the text and word counts."
          );
        }

        if (!cancelled) {
          setWords(result);
          setError("");
        }
      } catch (err) {
        if (!cancelled) {
          setError(err.message || "Unable to load the text.");
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    loadWords();

    return () => {
      cancelled = true;
    };
  }, []);

  // Measure the container and respond to resizing
  useEffect(() => {
    const element = containerRef.current;
    if (!element) return;

    const observer = new ResizeObserver(([entry]) => {
      const width = Math.max(280, entry.contentRect.width);

      setDimensions({
        width,
        height: Math.max(430, Math.min(760, width * 0.78)),
      });
    });

    observer.observe(element);

    return () => observer.disconnect();
  }, []);

  // Generate and render the SVG word cloud
  useEffect(() => {
    if (!words.length || !svgRef.current) return;

    let cancelled = false;

    const { width, height } = dimensions;

    const headerHeight = width < 480 ? 100 : 112;
    const footerHeight = 35;
    const cloudWidth = Math.max(200, width - 36);
    const cloudHeight = Math.max(
      240,
      height - headerHeight - footerHeight
    );

    const rotationRandom = seededRandom(123);
    const layoutRandom = seededRandom(456);

    const preparedWords = words.map((d) => ({
      ...d,
      angle: rotationRandom() < 0.65 ? 0 : 90,
    }));

    const minCount = d3.min(preparedWords, (d) => d.n);
    const maxCount = d3.max(preparedWords, (d) => d.n);

    const minFont = width < 480 ? 12 : 16;
    const maxFont = Math.min(64, width * 0.085);

    const fontScale = d3
      .scaleSqrt()
      .domain([minCount, maxCount || minCount + 1])
      .range([minFont, maxFont])
      .clamp(true);

    const palette = [
      "#3B3B3B",
      "#A45C40",
      "#64765B",
      "#B18A4A",
      "#725D72",
      "#555D68",
    ];

    const colorScale = d3
      .scaleQuantile()
      .domain(preparedWords.map((d) => d.n))
      .range(palette);

    const svg = d3.select(svgRef.current);
    const group = svg.select(".word-cloud");

    // Clear old labels before recalculating layout
    group.selectAll("*").interrupt();
    group.selectAll("*").remove();

    const layout = cloud()
      .size([cloudWidth, cloudHeight])
      .words(
        preparedWords.map((d) => ({
          ...d,
          text: d.word,
        }))
      )
      .padding(width < 480 ? 3 : 5)
      .rotate((d) => d.angle)
      .font("Delius")
      .fontSize((d) => fontScale(d.n))
      .spiral("archimedean")
      .random(layoutRandom)
      .on("end", (placedWords) => {
        if (cancelled) return;

        group.attr(
          "transform",
          `translate(${width / 2},${headerHeight + cloudHeight / 2})`
        );

        // Handle cases where no words fit
        if (!placedWords.length) return;

        const labels = group
          .selectAll("text")
          .data(placedWords, (d) => d.word)
          .join("text")
          .text((d) => d.word)
          .attr("class", "alice-word")
          .attr("text-anchor", "middle")
          .attr("dominant-baseline", "central")
          .attr("font-family", "Delius, sans-serif")
          .attr("font-size", (d) => `${d.size}px`)
          .attr("font-weight", (d) =>
            d.n >= maxCount * 0.65 ? 700 : 400
          )
          .attr("fill", (d) => colorScale(d.n))
          .attr(
            "transform",
            (d) => `translate(${d.x},${d.y}) rotate(${d.rotate})`
          )
          .style("opacity", 0)
          .style("cursor", "pointer");

        labels
          .append("title")
          .text((d) => `${d.word}: ${d.n} occurrences`);

        labels
          .on("mouseenter", function (event, d) {
            d3.select(this)
              .interrupt()
              .transition()
              .duration(120)
              .attr("fill", "#C05B3D")
              .attr("font-weight", 700);
          })
          .on("mouseleave", function (event, d) {
            d3.select(this)
              .interrupt()
              .transition()
              .duration(160)
              .attr("fill", colorScale(d.n))
              .attr(
                "font-weight",
                d.n >= maxCount * 0.65 ? 700 : 400
              );
          });

        labels
          .transition()
          .duration(500)
          .delay((d, i) => Math.min(i * 5, 350))
          .style("opacity", 1);
      });

    layout.start();

    return () => {
      cancelled = true;
      layout.stop();
      group.selectAll("*").interrupt().remove();
    };
  }, [words, dimensions]);

  const { width, height } = dimensions;

  return (
    <section className="alice-card" ref={containerRef}>
      <div className="alice-topline">
        <span className="alice-eyebrow">
          A LITERARY WORD PORTRAIT
        </span>
        <span className="alice-edition">
          LEWIS CARROLL · 1865
        </span>
      </div>

      {loading ? (
        <div className="alice-message" role="status">
          Preparing the word cloud…
        </div>
      ) : error ? (
        <div className="alice-message alice-error" role="alert">
          <strong>Unable to display the word cloud</strong>
          <span>{error}</span>
          <span>
            Verify the file at{" "}
            <code>public/alice.txt</code>.
          </span>
        </div>
      ) : (
        <>
          <svg
            ref={svgRef}
            className="alice-svg"
            viewBox={`0 0 ${width} ${height}`}
            role="img"
            aria-label="Word cloud of Alice in Wonderland"
          >
            <rect
              width={width}
              height={height}
              rx="12"
              fill="#FAF9F6"
            />

            <text
              x={width / 2}
              y={38}
              className="alice-title"
              fontSize={width < 480 ? 22 : 30}
            >
              Alice in Wonderland
            </text>

            <text
              x={width / 2}
              y={64}
              className="alice-subtitle"
            >
              Words occurring more than seven times
            </text>

            <line
              x1={width / 2 - 30}
              x2={width / 2 + 30}
              y1={81}
              y2={81}
              stroke="#C9A77B"
              strokeWidth="2"
              strokeLinecap="round"
            />

            <g className="word-cloud" />

            <text
              x={width - 20}
              y={height - 12}
              className="alice-caption"
              textAnchor="end"
            >
              Source: Alice in Wonderland · Lewis Carroll
            </text>
          </svg>

          <div className="alice-stats">
            <span>{words.length} distinct words</span>
            <span>Hover over a word to see its count</span>
          </div>
        </>
      )}

      <div className="alice-bottomline">
        <span>THE CLASSICS COLLECTION</span>
        <span>WORD FREQUENCY STUDY</span>
      </div>
    </section>
  );
}
