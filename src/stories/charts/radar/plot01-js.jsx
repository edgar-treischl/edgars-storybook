
import { useEffect, useRef } from 'react'
import * as d3 from 'd3'

export default function RadarChart() {
  const svgRef = useRef(null)

  const data = {
    labels: [
      'Strength',
      'Skill',
      'Speed',
      'Endurance',
      'Agility',
      'Flexibility',
    ],
    datasets: [
      {
        label: 'Player A',
        values: [65, 59, 90, 81, 56, 55],
        color: '#2563eb',
      },
      {
        label: 'Player B',
        values: [28, 48, 40, 19, 96, 27],
        color: '#ef4444',
      },
    ],
  }

  useEffect(() => {
    const width = 720
    const height = 650
    const radius = 210
    const labelRadius = radius + 35

    const svg = d3.select(svgRef.current)
    svg.selectAll('*').remove()

    svg
      .attr('viewBox', `0 0 ${width} ${height}`)
      .attr('preserveAspectRatio', 'xMidYMid meet')

    const chart = svg
      .append('g')
      .attr(
        'transform',
        `translate(${width / 2}, ${height / 2})`
      )

    const angleSlice = (Math.PI * 2) / data.labels.length

    const scale = d3.scaleLinear()
      .domain([0, 100])
      .range([0, radius])

    // Grid circles
    const levels = [20, 40, 60, 80, 100]

    levels.forEach((level) => {
      chart
        .append('circle')
        .attr('r', scale(level))
        .attr('fill', 'none')
        .attr('stroke', '#d1d5db')
        .attr('stroke-width', 1)

      chart
        .append('text')
        .attr('x', 5)
        .attr('y', -scale(level) - 4)
        .attr('font-size', 11)
        .attr('fill', '#9ca3af')
        .text(level)
    })

    // Axis lines and attribute labels
    data.labels.forEach((label, i) => {
      const angle = angleSlice * i - Math.PI / 2

      const x = radius * Math.cos(angle)
      const y = radius * Math.sin(angle)

      const labelX = labelRadius * Math.cos(angle)
      const labelY = labelRadius * Math.sin(angle)

      chart
        .append('line')
        .attr('x1', 0)
        .attr('y1', 0)
        .attr('x2', x)
        .attr('y2', y)
        .attr('stroke', '#9ca3af')
        .attr('stroke-width', 1)

      chart
        .append('text')
        .attr('x', labelX)
        .attr('y', labelY)
        .attr('text-anchor', 'middle')
        .attr('dominant-baseline', 'middle')
        .attr('font-size', 13)
        .attr('font-weight', 600)
        .attr('fill', '#374151')
        .text(label)
    })

    // Radar polygons and data values
    data.datasets.forEach((dataset, datasetIndex) => {
      const points = dataset.values.map((value, i) => {
        const angle = angleSlice * i - Math.PI / 2

        return {
          x: scale(value) * Math.cos(angle),
          y: scale(value) * Math.sin(angle),
          value,
          angle,
        }
      })

      const line = d3.line()
        .x((d) => d.x)
        .y((d) => d.y)
        .curve(d3.curveLinearClosed)

      chart
        .append('path')
        .datum(points)
        .attr('d', line)
        .attr('fill', dataset.color)
        .attr('fill-opacity', 0.16)
        .attr('stroke', dataset.color)
        .attr('stroke-width', 2.5)
        .attr('stroke-linejoin', 'round')

      // Data point markers
      chart
        .selectAll(`.point-${datasetIndex}`)
        .data(points)
        .enter()
        .append('circle')
        .attr('cx', (d) => d.x)
        .attr('cy', (d) => d.y)
        .attr('r', 5)
        .attr('fill', dataset.color)
        .attr('stroke', '#fff')
        .attr('stroke-width', 2)

      // Numerical values next to data points
      chart
        .selectAll(`.value-${datasetIndex}`)
        .data(points)
        .enter()
        .append('text')
        .attr('x', (d) => {
          const offset = datasetIndex === 0 ? 13 : -13
          return d.x + offset * Math.cos(d.angle)
        })
        .attr('y', (d) => {
          const offset = datasetIndex === 0 ? 13 : -13
          return d.y + offset * Math.sin(d.angle)
        })
        .attr('text-anchor', 'middle')
        .attr('dominant-baseline', 'middle')
        .attr('font-size', 12)
        .attr('font-weight', 700)
        .attr('fill', dataset.color)
        .text((d) => d.value)
    })

    // Compact legend
    const legend = svg
      .append('g')
      .attr(
        'transform',
        `translate(${width / 2 - 65}, ${height - 25})`
      )

    data.datasets.forEach((dataset, i) => {
      const item = legend
        .append('g')
        .attr('transform', `translate(${i * 140}, 0)`)

      item
        .append('circle')
        .attr('r', 6)
        .attr('fill', dataset.color)

      item
        .append('text')
        .attr('x', 12)
        .attr('y', 4)
        .attr('font-size', 12)
        .attr('fill', '#374151')
        .text(dataset.label)
    })

  }, [])

  return (
    <div style={{ width: '100%', maxWidth: 800, margin: '0 auto' }}>
      <svg
        ref={svgRef}
        style={{
          width: '100%',
          height: 'auto',
          display: 'block',
        }}
        role="img"
        aria-label="Radar chart showing player attributes and values"
      />
    </div>
  )
}
