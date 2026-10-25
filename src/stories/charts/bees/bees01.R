library(palmerpenguins)
library(ggplot2)
library(ggbeeswarm)

# 1. Beeswarm plot
p <- ggplot(
  penguins,
  aes(
    x = species,
    y = body_mass_g,
    color = species
  )
) +
  geom_beeswarm(
    size = 1.1,
    alpha = 0.85,
    priority = "density"
  ) +
  scale_color_manual(
    values = c(
      "Adelie" = "#E69F00",
      "Chinstrap" = "#56B4E9",
      "Gentoo" = "#009E73"
    ),
    guide = "none"
  ) +
  scale_y_continuous(
    expand = expansion(mult = c(0.04, 0.08))
  ) +
  labs(
    title = "Body Mass of Palmer Penguins",
    subtitle = "Individual observations by penguin species",
    x = NULL,
    y = "Body mass (g)",
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
      size = 7.5,
      face = "bold",
      color = "#25364A"
    ),
    axis.text.y = element_text(
      size = 7,
      color = "grey50"
    ),
    axis.title.y = element_text(
      size = 8,
      face = "bold",
      color = "grey30"
    ),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_line(
      linewidth = 0.26,
      color = "#E8EBEF"
    ),
    plot.margin = margin(8, 8, 8, 8)
  )

p