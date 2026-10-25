
library(ggplot2)
library(cowplot)
library(showtext)
library(sysfonts)

sysfonts::font_add_google("Lato", "lato")
showtext::showtext_auto()

df_long <- expand.grid(x = 1:5, y = 1:4)

labels_long <- c(
  "2", "2", "1", "1", "ID",
  "2", "1", "2", "1", "T",
  "x2", "x1", "x2", "x1", "X",
  "y", "y", "y", "y", "Y"
)

colour_long <- c(
  "#74a9cf", "#74a9cf", "#045a8d", "#045a8d", "#302E2E",
  "#74a9cf", "#74a9cf", "#045a8d", "#045a8d", "#302E2E",
  "#74a9cf", "#74a9cf", "#045a8d", "#045a8d", "#302E2E",
  "#d0d1e6", "#d0d1e6", "#d0d1e6", "#d0d1e6", "#302E2E"
)

df_long$label <- labels_long
df_long$fill <- colour_long

p_long <- ggplot(df_long, aes(x = x, y = y)) +
  geom_tile(
    aes(fill = fill),
    color = "white",
    linewidth = 0.8
  ) +
  geom_text(
    aes(label = label),
    color = "white",
    size = 3.2,
    family = "lato",
    fontface = "bold"
  ) +
  scale_fill_identity() +
  scale_x_continuous(expand = expansion(add = 0)) +
  scale_y_continuous(expand = expansion(add = 0)) +
  coord_flip() +
  labs(title = "A. Long") +
  theme_minimal(base_size = 9, base_family = "lato") +
  theme(
    panel.grid = element_blank(),
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    plot.title = element_text(
      size = 9,
      face = "bold",
      color = "#25364A",
      hjust = 0.5,
      margin = margin(b = 6)
    ),
    plot.margin = margin(4, 6, 4, 6)
  )

df_wide <- expand.grid(x = 1:3, y = 1:4)

labels_wide <- c(
  "2", "1", "ID",
  "x", "x", "X1",
  "x", "x", "X2",
  "y", "y", "Y"
)

colour_wide <- c(
  "#74a9cf", "#045a8d", "#302E2E",
  "#74a9cf", "#045a8d", "#302E2E",
  "#74a9cf", "#045a8d", "#302E2E",
  "#d0d1e6", "#d0d1e6", "#302E2E"
)

df_wide$label <- labels_wide
df_wide$fill <- colour_wide

p_wide <- ggplot(df_wide, aes(x = x, y = y)) +
  geom_tile(
    aes(fill = fill),
    color = "white",
    linewidth = 0.8
  ) +
  geom_text(
    aes(label = label),
    color = "white",
    size = 3.2,
    family = "lato",
    fontface = "bold"
  ) +
  scale_fill_identity() +
  scale_x_continuous(expand = expansion(add = 0)) +
  scale_y_continuous(expand = expansion(add = 0)) +
  coord_flip() +
  labs(title = "B. Wide") +
  theme_minimal(base_size = 9, base_family = "lato") +
  theme(
    panel.grid = element_blank(),
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    plot.title = element_text(
      size = 9,
      face = "bold",
      color = "#25364A",
      hjust = 0.5,
      margin = margin(b = 6)
    ),
    plot.margin = margin(4, 6, 4, 6)
  )

panels <- cowplot::plot_grid(
  p_long,
  p_wide,
  ncol = 2,
  align = "hv",
  rel_widths = c(1, 1)
)

header <- cowplot::ggdraw() +
  cowplot::draw_label(
    "Long vs. wide data",
    x = 0.5,
    y = 0.72,
    hjust = 0.5,
    vjust = 0.5,
    fontfamily = "lato",
    fontface = "bold",
    size = 12,
    color = "#25364A"
  ) +
  cowplot::draw_label(
    "The same information represented in two different structures",
    x = 0.5,
    y = 0.22,
    hjust = 0.5,
    vjust = 0.5,
    fontfamily = "lato",
    size = 8,
    color = "grey40"
  )

final_plot <- cowplot::plot_grid(
  header,
  panels,
  ncol = 1,
  rel_heights = c(0.2, 1)
)

print(final_plot)

ggplot2::ggsave(
  "src/stories/misc/illustrations/plot03.svg",
  plot = final_plot,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
