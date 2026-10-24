import type { ComponentType } from "react"

export type StoryLanguage = "r" | "python" | "javascript"

export type StoryImplementation = {
  language: StoryLanguage
  syntax: StoryLanguage | "jsx"
  code: string
} & (
  | { image: string; Plot?: never }
  | { image?: never; Plot: ComponentType }
)

export type StoryVariant = {
  id: string
  title: string
  description?: string
  implementations: StoryImplementation[]
}

export type Story = {
  id: string
  title: string
  category: string
  description?: string
  variants: StoryVariant[]
}
