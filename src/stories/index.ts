import type { ComponentType } from "react"
import type { Story } from "./types"
import { parseMarkdownStory } from "./parseMarkdownStory"

// Load markdown files using new Vite glob syntax
const markdownModules = import.meta.glob("./**/story.md", {
  eager: true,
  query: "?raw",
  import: "default",
}) as Record<string, string>

// Load all story images eagerly as inlined base64 data URIs. Using `?inline`
// embeds each image directly into the JS bundle, so the reference stays valid
// both locally and when this app is consumed remotely via Module Federation
// (an emitted asset URL would otherwise resolve against the host app's base
// path instead of this remote's).
const imageModules = import.meta.glob(
  "./**/*.{png,jpg,jpeg,gif,svg}",
  { eager: true, query: "?inline", import: "default" },
) as Record<string, string>

// Code is displayed as text; only explicitly referenced JSX plots are rendered.
const codeModules = import.meta.glob(
  "./**/*.{R,py,js,jsx}",
  { eager: true, query: "?raw", import: "default" },
) as Record<string, string>

const plotModules = import.meta.glob<ComponentType>(
  "./**/*.jsx",
  { eager: true, import: "default" },
)

export const stories = Object.entries(markdownModules)
  .map(([path, content]) => {
    // Extract base directory from path (e.g., "./plots/scatter/story.md" -> "plots/scatter")
    const basePath = path.replace(/\/story\.md$/, "")

    // Resolve an image name relative to this story's directory
    const imagePath = (imageName: string) => {
      const key = `${basePath}/${imageName}`
      const url = imageModules[key]

      if (!url) {
        console.warn(`Story image not found: ${key}`)
        return ""
      }

      return url
    }

    // Resolve a code file name relative to this story's directory
    const codePath = (fileName: string) => {
      const key = `${basePath}/${fileName}`
      const code = codeModules[key]

      if (!code) {
        console.warn(`Story code file not found: ${key}`)
        return ""
      }

      return code
    }

    const plotPath = (fileName: string) => {
      const key = `${basePath}/${fileName}`
      const Plot = plotModules[key]

      if (!Plot) {
        console.warn(`Story plot component not found: ${key}`)
      }

      return Plot
    }

    return parseMarkdownStory(content, imagePath, codePath, plotPath)
  })
  .filter((story) => story !== null) as Story[]
