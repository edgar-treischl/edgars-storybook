
library(tidyverse)
library(gapminder)
library(ggrepel)

# 1. Calculate life expectancy gains between 1952 and 2007
gains <- gapminder |>
  filter(year %in% c(1952, 2007), continent != "Oceania") |>
  select(country, continent, year, lifeExp) |>
  pivot_wider(
    names_from = year,
    values_from = lifeExp,
    names_prefix = "year_"
  ) |>
  mutate(gain = year_2007 - year_1952) |>
  group_by(continent) |>
  slice_max(gain, n = 5, with_ties = FALSE) |>
  ungroup()

# 2. Keep selected countries and both endpoints
df <- gapminder |>
  semi_join(
    gains |> select(country, continent),
    by = c("country", "continent")
  ) |>
  filter(year %in% c(1952, 2007)) |>
  mutate(
    x = if_else(year == 1952, 0, 1),
    lifeExp = round(lifeExp, 1),
    country_short = case_when(
      country == "Bosnia and Herzegovina" ~ "Bosnia",
      TRUE ~ country
    )
  )

right <- df |> filter(year == 2007)

# 3. Slope chart
p <- ggplot(
  df,
  aes(
    x = x,
    y = lifeExp,
    group = country,
    color = continent
  )
) +
  geom_line(
    linewidth = 0.9,
    alpha = 0.8
  ) +
  geom_point(
    size = 1.2,
    show.legend = FALSE
  ) +
  
  # Labels at the 2007 endpoints
  geom_text_repel(
    data = right,
    aes(label = paste0(country_short, "  ", lifeExp)),
    nudge_x = 0.06,
    hjust = 0,
    direction = "y",
    size = 2.5,
    fontface = "bold",
    color = "grey25",
    segment.color = "grey75",
    segment.alpha = 0.6,
    box.padding = 0.2,
    point.padding = 0.1,
    max.overlaps = Inf,
    show.legend = FALSE
  ) +
  
  # One panel per continent
  facet_wrap(
    ~continent,
    scales = "free_y",
    ncol = 2
  ) +
  
  scale_color_brewer(
    palette = "Dark2",
    guide = "none"
  ) +
  
  # Center both years with balanced space around the endpoints
  scale_x_continuous(
    breaks = c(0, 1),
    labels = c("1952", "2007"),
    limits = c(-0.12, 1.42),
    expand = expansion(mult = 0)
  ) +
  
  scale_y_continuous(
    expand = expansion(mult = c(0.08, 0.12))
  ) +
  
  labs(
    title = "A longer life",
    subtitle = paste(
      "The five largest gains in life expectancy",
      "within each continent, 1952–2007"
    ),
    x = NULL,
    y = "Life expectancy",
    caption = "Source: Gapminder | Change: 2007 minus 1952"
  ) +
  
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(
      size = 14,
      face = "bold",
      color = "#25364A"
    ),
    plot.subtitle = element_text(
      size = 12,
      color = "grey40",
      margin = margin(b = 8)
    ),
    plot.caption = element_text(
      size = 8,
      color = "grey55",
      margin = margin(t = 14)
    ),
    strip.text = element_text(
      size = 11,
      face = "bold",
      color = "#25364A"
    ),
    strip.background = element_rect(
      fill = "#F1F4F8",
      color = NA
    ),
    axis.text.x = element_text(
      size = 10,
      face = "bold",
      color = "#25364A"
    ),
    axis.text.y = element_text(color = "grey50"),
    axis.title.y = element_text(
      face = "bold",
      color = "grey30"
    ),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.spacing = grid::unit(1.2, "lines"),
    legend.position = "none",
    plot.margin = margin(15, 15, 15, 15)
  ) +
  coord_cartesian(clip = "off")



ggsave(
  "src/stories/charts/slope/plot01-r.svg",
  plot = p,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
