library(ggplot2)
library(palmerpenguins)

ggplot(penguins, aes(x = bill_length_mm, y = bill_depth_mm)) +
  geom_point()


library(ggplot2)
library(palmerpenguins)

# 1. Scatter plot with linear regression lines
p <- ggplot(
  penguins,
  aes(
    x = bill_length_mm,
    y = bill_depth_mm,
    color = species
  )
) +
  geom_point(
    size = 1.5,
    alpha = 0.7
  ) +
  geom_smooth(
    method = "lm",
    se = FALSE,
    linewidth = 0.49
  ) +
  scale_color_manual(
    values = c(
      "Adelie" = "#E69F00",
      "Chinstrap" = "#56B4E9",
      "Gentoo" = "#009E73"
    )
  ) +
  labs(
    title = "Palmer Penguins",
    subtitle = "Association between bill length and depth",
    x = "Bill length (mm)",
    y = "Bill depth (mm)",
    color = "Species",
    caption = "Source: Palmer Penguins dataset"
  ) +
  theme_minimal(base_size = 9) +
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
    axis.text.x = element_text(
      size = 7,
      color = "grey50"
    ),
    axis.text.y = element_text(
      size = 7,
      color = "grey50"
    ),
    axis.title.x = element_text(
      size = 8,
      face = "bold",
      color = "grey30",
      margin = margin(t = 6)
    ),
    axis.title.y = element_text(
      size = 8,
      face = "bold",
      color = "grey30",
      margin = margin(r = 8)
    ),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(
      color = "#E8EBEF",
      linewidth = 0.26
    ),
    legend.position = "right",
    legend.title = element_text(
      size = 8,
      face = "bold",
      color = "#25364A"
    ),
    legend.text = element_text(
      size = 7,
      color = "grey40"
    ),
    legend.key.height = grid::unit(10, "pt"),
    plot.margin = margin(8, 8, 8, 8)
  )

# 2. Export chart
ggsave(
  "src/stories/charts/scatter/plot01-r.svg",
  plot = p,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)

