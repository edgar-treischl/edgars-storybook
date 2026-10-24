import { useEffect, useState } from "react"
import { useLocation, useNavigate, BrowserRouter } from "react-router-dom"
import { stories } from "./stories"
import { highlightCode } from "./highlight"
import { parseInlineMarkdown } from "./utils/parseMarkdown"
import { LandingPage } from "./components/LandingPage"
import ScrollToTop from "./components/ScrollToTop"
import type { StoryImplementation, StoryLanguage } from "./stories/types"

const languageLabels: Record<StoryLanguage, string> = {
  r: "R",
  python: "Py",
  javascript: "JS",
}

function CodeSnippet({ implementation }: { implementation: StoryImplementation }) {
  const [highlightedCode, setHighlightedCode] = useState("")
  const [error, setError] = useState(false)
  const [copyStatus, setCopyStatus] = useState<"idle" | "copying" | "copied" | "error">("idle")

  useEffect(() => {
    if (copyStatus !== "copied") return

    const timeout = window.setTimeout(() => setCopyStatus("idle"), 2000)
    return () => window.clearTimeout(timeout)
  }, [copyStatus])

  async function copyCode() {
    setCopyStatus("copying")
    try {
      await navigator.clipboard.writeText(implementation.code)
      setCopyStatus("copied")
    } catch (cause) {
      console.error("Could not copy story code", cause)
      setCopyStatus("error")
    }
  }

  useEffect(() => {
    let cancelled = false
    highlightCode(implementation.code, implementation.syntax).then(
      (html) => {
        if (!cancelled) setHighlightedCode(html)
      },
      (cause: unknown) => {
        console.error("Could not highlight story code", cause)
        if (!cancelled) setError(true)
      },
    )
    return () => { cancelled = true }
  }, [implementation])

  return (
    <section className="code-section">
      <div className="section-header">
        <h2>Code Snippet ({languageLabels[implementation.language]})</h2>
        <button
          onClick={copyCode}
          disabled={copyStatus === "copying"}
          aria-live="polite"
          aria-atomic="true"
        >
          {copyStatus === "copied" ? "Copied!" : copyStatus === "copying" ? "Copying..." : "Copy"}
        </button>
      </div>
      {copyStatus === "error" && (
        <p role="alert">Could not copy code. Please try again or copy it manually.</p>
      )}
      {error && <p role="alert">Syntax highlighting could not be loaded.</p>}
      {highlightedCode ? (
        <div className="shiki" dangerouslySetInnerHTML={{ __html: highlightedCode }} />
      ) : (
        <pre><code>{implementation.code}</code></pre>
      )}
    </section>
  )
}

function AppContent() {
  const [language, setLanguage] = useState<StoryLanguage>("r")
  const location = useLocation()
  const navigate = useNavigate()

  const path = location.pathname.replace(/^\/|\/$/g, "")
  const isLandingPage = !path

  const story =
    stories.find(
      (item) =>
        path === item.id ||
        path.startsWith(`${item.id}/`),
    ) ?? null

  const variantId = story
    ? path.slice(story.id.length + 1)
    : ""

  const variant =
    story?.variants.find(
      (item) => item.id === variantId,
    ) ?? story?.variants[0] ?? null

  useEffect(() => {
    if (isLandingPage) return

    if (!story || !variant) {
      const firstStory = stories[0]

      if (firstStory) {
        navigate(
          `/${firstStory.id}/${firstStory.variants[0].id}`,
          { replace: true },
        )
      }

      return
    }

    const expectedPath = `/${story.id}/${variant.id}`

    if (location.pathname !== expectedPath) {
      navigate(expectedPath, { replace: true })
    }
  }, [story, variant, location.pathname, navigate, isLandingPage])

  if (isLandingPage) {
    return <LandingPage />
  }

  if (!story || !variant) {
    return null
  }

  const implementation = variant.implementations.find(
    (item) => item.language === language,
  ) ?? variant.implementations[0]
  const Plot = implementation.Plot

  const categories = [
    ...new Set(stories.map((item) => item.category)),
  ]

  function selectStory(id: string) {
    const nextStory = stories.find(
      (item) => item.id === id,
    )

    if (!nextStory || nextStory.variants.length === 0) {
      return
    }

    navigate(
      `/${nextStory.id}/${nextStory.variants[0].id}`,
    )
  }

  function selectVariant(id: string) {
    if (!story) return

    navigate(`/${story.id}/${id}`)
  }

  return (
    <div className="app">
      <aside className="sidebar">
        <button
          className="brand"
          onClick={() => navigate("/")}
        >
          <div className="brand-mark">R</div>

          <div>
            <strong>R Stories</strong>
          </div>
        </button>

        <nav>
          {categories.map((category) => (
            <div
              key={category}
              className="category"
            >
              <div className="category-title">
                {category}
              </div>

              {stories
                .filter(
                  (item) =>
                    item.category === category,
                )
                .map((item) => (
                  <button
                    key={item.id}
                    className={
                      item.id === story.id
                        ? "story active"
                        : "story"
                    }
                    onClick={() =>
                      selectStory(item.id)
                    }
                  >
                    {item.title}
                  </button>
                ))}
            </div>
          ))}
        </nav>
      </aside>

      <main className="content">
        <header>
          <div className="breadcrumb">
            {story.category} / {story.title}
          </div>

          <h1>{story.title}</h1>

          {story.description && (
            <div dangerouslySetInnerHTML={{ __html: parseInlineMarkdown(story.description) }} />
          )}
        </header>

        <div className="variants">
          {story.variants.map((item) => (
            <button
              key={item.id}
              className={
                item.id === variant.id
                  ? "variant active"
                  : "variant"
              }
              onClick={() =>
                selectVariant(item.id)
              }
            >
              {item.title}
            </button>
          ))}
        </div>

        {variant.description && (
          <div className="variant-description" dangerouslySetInnerHTML={{ __html: parseInlineMarkdown(variant.description) }} />
        )}


        {variant.implementations.length > 1 && (
          <div className="mfe-template__languages" role="group" aria-label="Code and plot language">
            {variant.implementations.map((item) => (
              <button
                key={item.language}
                type="button"
                aria-label={{ r: "R", python: "Python", javascript: "JavaScript" }[item.language]}
                aria-pressed={item.language === implementation.language}
                onClick={() => setLanguage(item.language)}
              >
                {languageLabels[item.language]}
              </button>
            ))}
          </div>
        )}

        <section className="preview" aria-label={`${languageLabels[implementation.language]} plot`}>
          {Plot ? (
            <div className="mfe-template__live-plot" key={`${story.id}/${variant.id}/${implementation.language}`}>
              <Plot />
            </div>
          ) : (
            <img
              src={implementation.image}
              alt={`${variant.title} (${languageLabels[implementation.language]})`}
              className={implementation.image.startsWith('data:image/svg+xml') ? 'preview-svg' : 'preview-raster'}
            />
          )}
        </section>

        <CodeSnippet
          key={`${story.id}/${variant.id}/${implementation.language}`}
          implementation={implementation}
        />
      </main>
    </div>
  )
}

function App() {
  return (
    <BrowserRouter>
      <ScrollToTop />
      <AppContent />
    </BrowserRouter>
  )
}

export default App
