
library(dplyr)
library(ggplot2)
library(scales)
library(ggtext)
library(sysfonts)
library(showtext)
library(tibble)
library(tidyr)

radar_data <- tribble(
  ~Attribute,      ~Player_A, ~Player_B,
  "Strength",            65L,       28L,
  "Skill",               59L,       48L,
  "Speed",               90L,       40L,
  "Endurance",           81L,       19L,
  "Agility",              56L,       96L,
  "Flexibility",          55L,       27L
)

sysfonts::font_add_google("Lato", "Lato")
showtext::showtext_auto()

player_colors <- c(
  "Player A" = "#2563EB",
  "Player B" = "#EF4444"
)

n_axes <- nrow(radar_data)
max_value <- 100

plot_data <- radar_data |>
  pivot_longer(
    cols = c(Player_A, Player_B),
    names_to = "Player",
    values_to = "Value"
  ) |>
  mutate(
    Player = recode(
      Player,
      "Player_A" = "Player A",
      "Player_B" = "Player B"
    ),
    axis = match(Attribute, radar_data$Attribute),
    angle = pi / 2 - 2 * pi * (axis - 1) / n_axes,
    x = Value / max_value * cos(angle),
    y = Value / max_value * sin(angle)
  )

polygon_data <- plot_data |>
  group_by(Player) |>
  arrange(axis, .by_group = TRUE) |>
  reframe(
    x = c(x, first(x)),
    y = c(y, first(y))
  )

axis_data <- radar_data |>
  mutate(
    axis = row_number(),
    angle = pi / 2 - 2 * pi * (axis - 1) / n_axes,
    x = cos(angle),
    y = sin(angle),
    label_x = 1.20 * cos(angle),
    label_y = 1.20 * sin(angle)
  )

grid_data <- tibble(
  level = rep(seq(0.2, 1, by = 0.2), each = 361),
  angle = rep(
    seq(0, 2 * pi, length.out = 361),
    times = 5
  )
) |>
  mutate(
    x = level * cos(angle),
    y = level * sin(angle)
  )

grid_labels <- tibble(
  level = seq(0.2, 1, by = 0.2)
) |>
  mutate(
    x = 0.025,
    y = level + 0.015,
    label = as.character(level * max_value)
  )

plot_data <- plot_data |>
  mutate(
    label_x = x + 0.045 * cos(angle) +
      ifelse(Player == "Player A", 0.015, -0.015),
    label_y = y + 0.045 * sin(angle),
    hjust = ifelse(
      cos(angle) > 0.3, 0,
      ifelse(cos(angle) < -0.3, 1, 0.5)
    ),
    vjust = ifelse(
      sin(angle) > 0.3, 0,
      ifelse(sin(angle) < -0.3, 1, 0.5)
    )
  )

p <- ggplot() +
  geom_path(
    data = grid_data,
    aes(x = x, y = y, group = level),
    color = "#D9DEE7",
    linewidth = 0.3
  ) +
  geom_segment(
    data = axis_data,
    aes(x = 0, y = 0, xend = x, yend = y),
    color = "#B8C0CC",
    linewidth = 0.3
  ) +
  geom_polygon(
    data = polygon_data,
    aes(
      x = x, y = y,
      group = Player,
      fill = Player,
      color = Player
    ),
    alpha = 0.14,
    linewidth = 0.6
  ) +
  geom_path(
    data = polygon_data,
    aes(x = x, y = y, group = Player, color = Player),
    linewidth = 0.7,
    linejoin = "round"
  ) +
  geom_point(
    data = plot_data,
    aes(x = x, y = y, color = Player),
    size = 1.5,
    shape = 21,
    fill = "white",
    stroke = 0.7
  ) +
  geom_text(
    data = plot_data,
    aes(
      x = label_x,
      y = label_y,
      label = Value,
      color = Player,
      hjust = hjust,
      vjust = vjust
    ),
    family = "Lato",
    fontface = "bold",
    size = 2
  ) +
  geom_text(
    data = axis_data,
    aes(x = label_x, y = label_y, label = Attribute),
    family = "Lato",
    fontface = "bold",
    size = 2.4,
    color = "#25364A"
  ) +
  geom_text(
    data = grid_labels,
    aes(x = x, y = y, label = label),
    family = "Lato",
    size = 1.5,
    color = "grey55"
  ) +
  scale_color_manual(values = player_colors) +
  scale_fill_manual(values = player_colors) +
  coord_equal(
    xlim = c(-1.38, 1.38),
    ylim = c(-1.38, 1.38),
    expand = FALSE,
    clip = "off"
  ) +
  labs(
    title = "Player Skill Comparison",
    subtitle = "Performance across six attributes",
    caption = "Scale: 0–100"
  ) +
  theme_void(
    base_size = 9,
    base_family = "Lato"
  ) +
  theme(
    legend.position = "bottom",
    legend.title = element_blank(),
    legend.text = element_text(
      size = 6,
      color = "#374151"
    ),
    legend.key.size = unit(0.25, "cm"),
    plot.title = element_text(
      size = 12,
      face = "bold",
      color = "#25364A",
      hjust = 0.5,
      margin = margin(b = 4)
    ),
    plot.subtitle = element_text(
      size = 8,
      color = "grey40",
      hjust = 0.5,
      margin = margin(b = 8)
    ),
    plot.caption = element_text(
      size = 6,
      color = "grey55",
      hjust = 0,
      margin = margin(t = 5)
    ),
    plot.background = element_rect(
      fill = "white",
      color = NA
    ),
    panel.background = element_rect(
      fill = "white",
      color = NA
    ),
    plot.margin = margin(8, 8, 8, 8)
  )

p

ggsave(
  "src/stories/charts/radar/plot01-r.svg",
  plot = p,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
