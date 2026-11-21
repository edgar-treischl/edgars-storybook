
import { useMemo } from 'react'
import { hierarchy, treemap } from 'd3-hierarchy'


const treemapData = {
  name: 'root',
  children: [
    {
      name: 'Democrats',
      children: [
        { name: 'Others', raw: 24, percentage: 14.04, percentage_facet: 63.16 },
        { name: 'Chuck & Nancy', raw: 6, percentage: 3.51, percentage_facet: 15.79 },
        { name: 'Hillary', raw: 8, percentage: 4.68, percentage_facet: 21.05 },
      ],
    },
    {
      name: 'GOP',
      children: [
        { name: 'Corker', raw: 4, percentage: 2.34, percentage_facet: 33.33 },
        { name: 'Others', raw: 8, percentage: 4.68, percentage_facet: 66.67 },
      ],
    },
    {
      name: 'The media',
      children: [
        { name: 'Others', raw: 14, percentage: 8.19, percentage_facet: 15.73 },
        { name: 'NYT', raw: 17, percentage: 9.94, percentage_facet: 19.10 },
        { name: 'CNN', raw: 13, percentage: 7.60, percentage_facet: 14.61 },
        { name: 'NBC', raw: 12, percentage: 7.02, percentage_facet: 13.48 },
        { name: '"Fake News!"', raw: 33, percentage: 19.30, percentage_facet: 37.08 },
      ],
    },
    {
      name: 'Others',
      children: [
        { name: "Int'l figures", raw: 3, percentage: 1.75, percentage_facet: 9.38 },
        { name: 'Companies', raw: 4, percentage: 2.34, percentage_facet: 12.50 },
        { name: 'Sports', raw: 8, percentage: 4.68, percentage_facet: 25.00 },
        { name: 'Celebrities', raw: 6, percentage: 3.51, percentage_facet: 18.75 },
        { name: 'Comey', raw: 7, percentage: 4.09, percentage_facet: 21.88 },
        { name: 'Others', raw: 4, percentage: 2.34, percentage_facet: 12.50 },
      ],
    },
  ],
}


const TOPIC_COLORS = {
  Democrats: '#377EB8',
  GOP: '#D94841',
  'The media': '#E6AB35',
  Others: '#8C7AA9',
}

const TOPIC_ORDER = [
  'Democrats',
  'GOP',
  'The media',
  'Others',
]

// --------------------------------------------------
// TEXT WRAPPING
// --------------------------------------------------

function wrapText(text, maxChars) {
  const words = text.split(/\s+/)
  const lines = []
  let current = ''

  words.forEach((word) => {
    const test = current ? `${current} ${word}` : word

    if (test.length > maxChars && current) {
      lines.push(current)
      current = word
    } else {
      current = test
    }
  })

  if (current) lines.push(current)

  return lines
}

// --------------------------------------------------
// COMPONENT
// --------------------------------------------------

export default function TreeMapExamplePage() {
  const width = 1000
  const height = 560

  const margin = {
    top: 8,
    right: 8,
    bottom: 8,
    left: 8,
  }

  const root = useMemo(() => {
    const orderedData = {
      ...treemapData,
      children: TOPIC_ORDER.map((topic) =>
        treemapData.children.find(
          (item) => item.name === topic
        )
      ).filter(Boolean),
    }

    const hierarchyRoot = hierarchy(orderedData)
      .sum((d) => d.percentage || 0)
      .sort((a, b) => (b.value || 0) - (a.value || 0))

    return treemap()
      .size([
        width - margin.left - margin.right,
        height - margin.top - margin.bottom,
      ])
      .paddingInner(3)
      .paddingOuter(2)
      .round(true)(hierarchyRoot)
  }, [])

  const topics = root.children || []
  const leaves = root.leaves()

  return (
    <div className="min-h-screen bg-white p-6">

      <div className="max-w-[1800px] mx-auto">

        {/* TITLE */}

        <header className="mb-5">
          <h1 className="text-[16px] font-bold text-[#222222]">
            Donald's Tweets
          </h1>

          <p className="text-[10px] text-[#555555] mt-1">
            Who's to blame?
          </p>
        </header>

        {/* TREEMAP */}

        <div className="w-full bg-white">

          <svg
            viewBox={`0 0 ${width} ${height}`}
            width="100%"
            height="auto"
            preserveAspectRatio="xMidYMid meet"
            role="img"
            aria-label="Treemap of tweet topics and subtopics"
          >

            <g transform={`translate(${margin.left},${margin.top})`}>

              {/* --------------------------------
                  SUBTOPIC RECTANGLES AND LABELS
              -------------------------------- */}

              {leaves.map((node) => {
                const topic = node.parent?.data.name
                const color = TOPIC_COLORS[topic] || '#cccccc'

                const x = node.x0
                const y = node.y0
                const w = node.x1 - node.x0
                const h = node.y1 - node.y0

                const text = node.data.name

                // Available label area
                const paddingX = 12
                const paddingY = 10

                const availableWidth = w - paddingX * 2
                const availableHeight = h - paddingY * 2

                // Dynamic font size
                const fontSize = Math.min(
                  20,
                  Math.max(
                    10,
                    Math.min(
                      availableWidth / Math.max(text.length * 0.52, 1),
                      availableHeight / 1.4
                    )
                  )
                )

                const lineHeight = fontSize * 1.2

                // Estimate characters per line
                const maxChars = Math.max(
                  3,
                  Math.floor(availableWidth / (fontSize * 0.55))
                )

                const lines = wrapText(text, maxChars)

                // Limit text to available height
                const maxLines = Math.max(
                  1,
                  Math.floor(availableHeight / lineHeight)
                )

                const visibleLines = lines.slice(0, maxLines)

                // Add ellipsis if necessary
                if (lines.length > maxLines && visibleLines.length) {
                  let last = visibleLines.length - 1
                  visibleLines[last] += '...'
                }

                // Check if rectangle can accommodate text
                const showLabel =
                  w >= 42 &&
                  h >= 30 &&
                  availableWidth >= 20

                return (
                  <g key={`${topic}-${text}`}>

                    {/* Rectangle */}

                    <rect
                      x={x}
                      y={y}
                      width={w}
                      height={h}
                      fill={color}
                      stroke="#FFFFFF"
                      strokeWidth={1.2}
                    />

                    {/* Subtopic label */}

                    {showLabel && (
                      <text
                        x={x + w / 2}
                        y={y + h / 2}
                        fill="#111111"
                        fontFamily="Lato, sans-serif"
                        fontSize={fontSize}
                        fontWeight="400"
                        textAnchor="middle"
                        dominantBaseline="middle"
                        pointerEvents="none"
                      >
                        {visibleLines.map((line, index) => (
                          <tspan
                            key={index}
                            x={x + w / 2}
                            dy={
                              index === 0
                                ? `${-(visibleLines.length - 1) * 0.6}em`
                                : '1.2em'
                            }
                          >
                            {line}
                          </tspan>
                        ))}
                      </text>
                    )}

                  </g>
                )
              })}

              {/* --------------------------------
                  TOPIC GROUP BORDERS
              -------------------------------- */}

              {topics.map((topic) => (
                <rect
                  key={`border-${topic.data.name}`}
                  x={topic.x0}
                  y={topic.y0}
                  width={topic.x1 - topic.x0}
                  height={topic.y1 - topic.y0}
                  fill="none"
                  stroke="#FFFFFF"
                  strokeWidth={2.5}
                  pointerEvents="none"
                />
              ))}

              {/* --------------------------------
                  TOPIC LABELS
              -------------------------------- */}

              {topics.map((topic) => {
                const x = topic.x0
                const y = topic.y0
                const w = topic.x1 - topic.x0
                const h = topic.y1 - topic.y0

                const fontSize = Math.min(
                  20,
                  Math.max(13, Math.min(w / 8, h / 5))
                )

                return (
                  <text
                    key={`label-${topic.data.name}`}
                    x={x + 12}
                    y={y + h - 12}
                    fill="#FFFFFF"
                    fontFamily="Lato, sans-serif"
                    fontSize={fontSize}
                    fontWeight="700"
                    opacity={0.95}
                    pointerEvents="none"
                  >
                    {topic.data.name}
                  </text>
                )
              })}

            </g>

          </svg>

        </div>

      </div>

      {/* FONT */}

      <style jsx global>{`
        @import url('https://fonts.googleapis.com/css2?family=Lato:wght@400;700&display=swap');

        body {
          font-family: 'Lato', sans-serif;
          background: #ffffff;
        }

        svg text {
          font-family: 'Lato', sans-serif;
        }
      `}</style>

    </div>
  )
}
