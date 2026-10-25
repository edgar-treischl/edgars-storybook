r
library(tidyverse)
library(palmerpenguins)
library(scales)

# 1. Prepare penguin data
penguins_data <- penguins |>
  drop_na(species) |>
  count(species) |>
  mutate(
    percent = n / sum(n)
  )

# 2. Define penguin colors
penguin_colors <- c(
  "Adelie"    = "#2A9D8F",
  "Chinstrap" = "#E9C46A",
  "Gentoo"    = "#264653"
)

# 3. Create waffle tiles
waffle_data <- penguins_data |>
  mutate(tiles = round(percent * 100)) |>
  uncount(tiles) |>
  mutate(
    id = row_number(),
    x = (id - 1) %% 10 + 1,
    y = (id - 1) %/% 10 + 1
  )

# 4. Prepare percentage labels
labels <- penguins_data |>
  mutate(
    label = paste0(
      species, " (",
      scales::percent(percent, accuracy = 1),
      ")"
    )
  ) |>
  select(species, label) |>
  deframe()

# 5. Create waffle chart
p <- ggplot(
  waffle_data,
  aes(x, y, fill = species)
) +
  geom_tile(
    color = "white",
    linewidth = 0.3
  ) +
  scale_fill_manual(
    values = penguin_colors,
    labels = labels,
    name = NULL
  ) +
  coord_equal() +
  scale_y_reverse(
    expand = expansion(mult = 0)
  ) +
  scale_x_continuous(
    expand = expansion(mult = 0)
  ) +
  labs(
    title = "Palmer Penguins",
    subtitle = "Each square represents approximately 1% of penguins",
    caption = "Source: palmerpenguins"
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
    legend.position = "right",
    legend.text = element_text(
      size = 7,
      color = "grey40"
    ),
    legend.key.height = grid::unit(12, "pt"),
    legend.key.width = grid::unit(12, "pt"),
    legend.spacing.y = grid::unit(3, "pt"),
    plot.margin = margin(8, 8, 8, 8)
  )

# 6. Export chart
ggsave(
  "src/stories/charts/waffle/plot01-r.svg",
  plot = p,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)