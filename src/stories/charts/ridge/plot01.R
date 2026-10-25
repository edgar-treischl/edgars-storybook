library(ggridges)
library(ggplot2)
library(dplyr)
library(gapminder)

# 1. Prepare data
years <- c(1952, 1972, 1992, 2007)

df <- gapminder |>
  filter(
    year %in% years,
    continent != "Oceania"
  ) |>
  mutate(
    year = factor(year, levels = years)
  )

# 2. Order continents by median life expectancy in 2007
continent_order <- df |>
  filter(year == 2007) |>
  group_by(continent) |>
  summarise(
    median_lifeExp = median(lifeExp),
    .groups = "drop"
  ) |>
  arrange(median_lifeExp) |>
  pull(continent)

df <- df |>
  mutate(
    continent = factor(
      continent,
      levels = continent_order
    )
  )

# 3. Ridgeline plot
p <- ggplot(
  df,
  aes(
    x = lifeExp,
    y = continent,
    group = interaction(continent, year),
    fill = year
  )
) +
  geom_density_ridges(
    scale = 1.1,
    rel_min_height = 0.01,
    alpha = 0.75,
    color = "white",
    linewidth = 0.25
  ) +
  scale_fill_viridis_d(
    option = "D",
    direction = 1,
    name = "Year"
  ) +
  scale_x_continuous(
    name = "Life expectancy (years)",
    breaks = seq(40, 80, 10),
    expand = expansion(mult = c(0.02, 0.02))
  ) +
  scale_y_discrete(
    name = NULL,
    expand = expansion(add = c(0.02, 0.02))
  ) +
  labs(
    title = "Distribution of life expectancy by continent",
    subtitle = "Country-level distributions across selected years",
    caption = "Source: Gapminder | Years: 1952, 1972, 1992, 2007"
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
      size = 7.5,
      face = "bold",
      color = "#25364A"
    ),
    axis.title.x = element_text(
      size = 8,
      face = "bold",
      color = "grey30",
      margin = margin(t = 8)
    ),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(
      linewidth = 0.26,
      color = "#E8EBEF"
    ),
    legend.position = "bottom",
    legend.title = element_text(
      size = 8,
      face = "bold",
      color = "#25364A"
    ),
    legend.text = element_text(
      size = 7,
      color = "grey40"
    ),
    legend.key.height = grid::unit(8, "pt"),
    legend.key.width = grid::unit(12, "pt"),
    legend.spacing.x = grid::unit(4, "pt"),
    plot.margin = margin(8, 12, 8, 8)
  )

# 4. Export chart
ggsave(
  "src/stories/charts/ridge/plot01-r.svg",
  plot = p,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
