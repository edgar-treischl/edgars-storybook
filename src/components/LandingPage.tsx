import { useNavigate } from "react-router-dom"
import { stories } from "../stories"
import type { StoryImplementation } from "../stories/types"

function StoryThumbnail({ implementation, title }: {
  implementation: StoryImplementation
  title: string
}) {
  const Plot = implementation.Plot
  return Plot ? <Plot /> : <img src={implementation.image} alt={title} />
}

export function LandingPage() {
  const navigate = useNavigate()
  const categories = [...new Set(stories.map((s) => s.category))]

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
            <div key={category} className="category">
              <div className="category-title">{category}</div>
              {stories
                .filter((s) => s.category === category)
                .map((story) => (
                  <button
                    key={story.id}
                    className="story"
                    onClick={() => {
                      navigate(
                        `/${story.id}/${story.variants[0].id}`,
                      )
                    }}
                  >
                    {story.title}
                  </button>
                ))}
            </div>
          ))}
        </nav>
      </aside>

      <main className="content">
        <header>
          <div className="breadcrumb">Welcome</div>
          <h1>R Stories</h1>
          <p>Explore data visualization examples built with R, Python, and JavaScript. Select a story from the sidebar to get started.</p>
        </header>

        <section className="gallery-grid">
          {categories.map((category) => (
            <div key={category} className="category-group">
              <h2>{category}</h2>
              <div className="story-cards">
                {stories
                  .filter((s) => s.category === category)
                  .map((story) => (
                    <button
                      key={story.id}
                      className="story-card"
                      onClick={() => {
                        navigate(
                          `/${story.id}/${story.variants[0].id}`,
                        )
                      }}
                    >
                      <div className="card-image">
                        {story.variants[0] && (
                          <StoryThumbnail
                            implementation={story.variants[0].implementations[0]}
                            title={story.title}
                          />
                        )}
                      </div>
                      <div className="card-text">
                        <h3>{story.title}</h3>
                        {story.description && (
                          <p>{story.description}</p>
                        )}
                      </div>
                    </button>
                  ))}
              </div>
            </div>
          ))}
        </section>
      </main>
    </div>
  )
}
