import assert from "node:assert/strict"
import { readFileSync, readdirSync } from "node:fs"
import { test } from "node:test"
import ts from "typescript"

const source = readFileSync(new URL("../src/stories/parseMarkdownStory.ts", import.meta.url), "utf8")
const { outputText } = ts.transpileModule(source, {
  compilerOptions: { module: ts.ModuleKind.ESNext, target: ts.ScriptTarget.ES2023 },
})
const { parseMarkdownStory } = await import(
  `data:text/javascript;base64,${Buffer.from(outputText).toString("base64")}`
)

const story = (body) => `---
id: charts/example
title: Example
category: Charts
description: Shared story.
---

## Basic

Shared variant.

${body}
`
const imagePath = (name) => `image:${name}`
const codePath = (name) => `source:${name}`

test("existing R variants retain their description, code and image", () => {
  const result = parseMarkdownStory(story("```r\n!r(plot.R)\n```\n![](./plot.svg)"), imagePath, codePath)
  assert.equal(result.id, "charts/example")
  assert.equal(result.description, "Shared story.")
  assert.deepEqual(result.variants, [{
    id: "basic",
    title: "Basic",
    description: "Shared variant.",
    implementations: [{ language: "r", syntax: "r", code: "source:plot.R", image: "image:plot.svg" }],
  }])
})

test("language code blocks pair with their own previews, not new variants", () => {
  const result = parseMarkdownStory(story([
    "```r\n!r(plot.R)\n```\n![](./r.svg)",
    "```py\n!py(plot.py)\n```\n![](./py.svg)",
    "```js\nconsole.log('plot')\n```\n![](./js.svg)",
  ].join("\n\n")), imagePath, codePath)
  assert.equal(result.variants.length, 1)
  assert.equal(result.variants[0].description, "Shared variant.")
  assert.deepEqual(result.variants[0].implementations, [
    { language: "r", syntax: "r", code: "source:plot.R", image: "image:r.svg" },
    { language: "python", syntax: "python", code: "source:plot.py", image: "image:py.svg" },
    { language: "javascript", syntax: "javascript", code: "console.log('plot')", image: "image:js.svg" },
  ])
})

test("JSX plots resolve a React component with JSX highlighting", () => {
  const Plot = () => null
  const result = parseMarkdownStory(
    story("```jsx\n!js(chart.jsx)\n```\n!plot(./chart.jsx)"),
    imagePath,
    codePath,
    (name) => {
      assert.equal(name, "chart.jsx")
      return Plot
    },
  )
  assert.deepEqual(result.variants[0].implementations, [{
    language: "javascript", syntax: "jsx", code: "source:chart.jsx", Plot,
  }])
})

test("a missing preview cannot borrow the next language's image", (context) => {
  context.mock.method(console, "warn", () => {})
  const result = parseMarkdownStory(story(
    "```r\nx <- 1\n```\n\n```python\nx = 1\n```\n![](./py.svg)",
  ), imagePath)
  assert.equal(result, null)
  assert.ok(console.warn.mock.calls.some(({ arguments: args }) => args[0].includes("Missing preview")))
})

test("duplicate languages and missing JSX components report invalid content", (context) => {
  context.mock.method(console, "warn", () => {})
  assert.equal(parseMarkdownStory(story(
    "```python\nx = 1\n```\n![](./a.svg)\n```py\nx = 2\n```\n![](./b.svg)",
  ), imagePath), null)
  assert.equal(parseMarkdownStory(story(
    "```jsx\n!js(missing.jsx)\n```\n!plot(missing.jsx)",
  ), imagePath, codePath, () => undefined), null)
  assert.ok(console.warn.mock.calls.some(({ arguments: args }) => args[0].includes("duplicate")))
  assert.ok(console.warn.mock.calls.some(({ arguments: args }) => args[0].includes("not found")))
})

test("H2 headings inside code do not split variants", () => {
  const result = parseMarkdownStory(story(
    "```python\n## a code comment\nprint('hello')\n```\n![](./py.svg)\n\n## Next\n\n```r\nx <- 1\n```\n![](./r.svg)",
  ), imagePath)
  assert.deepEqual(result.variants.map((variant) => variant.id), ["basic", "next"])
  assert.equal(result.variants[0].implementations[0].code, "## a code comment\nprint('hello')")
})

test("every repository story resolves its code and preview assets", () => {
  const root = new URL("../src/stories/", import.meta.url)
  for (const name of readdirSync(root, { recursive: true }).filter((name) => name.endsWith("story.md"))) {
    const file = new URL(name, root)
    const resolveFile = (name) => readFileSync(new URL(name, file), "utf8")
    const result = parseMarkdownStory(readFileSync(file, "utf8"), resolveFile, resolveFile, (name) => {
      resolveFile(name)
      return () => null
    })
    assert.ok(result, `${name} should parse`)
    assert.ok(result.variants.every((variant) => variant.implementations.length > 0))
    if (result.id === "charts/alluvial") {
      assert.deepEqual(result.variants[0].implementations.map((item) => item.language), ["r", "python", "javascript"])
    }
  }
})
