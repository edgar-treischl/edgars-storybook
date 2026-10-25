library(ggplot2)
library(treemapify)

# 1. Prepare data
df <- data.frame(
  Dimensions = c(
    "Science Technology",
    "Life Science Biomedicine",
    "Social Sciences",
    "Physical Sciences",
    "Art & Humanities",
    "Technology"
  ),
  number = c(5475, 5364, 4217, 610, 657, 491)
)

# 2. Create treemap
p <- ggplot(
  df,
  aes(
    area = number,
    fill = number,
    label = Dimensions
  )
) +
  geom_treemap(
    color = "white",
    linewidth = 0.3
  ) +
  geom_treemap_text(
    color = "white",
    fontface = "bold",
    place = "centre",
    grow = TRUE,
    reflow = TRUE,
    min.size = 6
  ) +
  scale_fill_viridis_c(
    option = "H",
    guide = "none"
  ) +
  theme_void(base_size = 9) +
  theme(
    plot.title = element_text(
      size = 12,
      face = "bold",
      color = "#25364A",
      margin = margin(b = 4)
    ),
    plot.subtitle = element_text(
      size = 8,
      color = "grey40",
      margin = margin(b = 8)
    ),
    plot.caption = element_text(
      size = 6,
      color = "grey55",
      hjust = 0,
      margin = margin(t = 8)
    ),
    plot.margin = margin(8, 8, 8, 8)
  )

# 3. Export chart
ggsave(
  "src/stories/charts/treemap/plot01-r.svg",
  plot = p,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
