library(ggplot2)

# 1. Prepare data
df <- data.frame(
  Dimension = rep(LETTERS[1:7], 2),
  Sex = factor(
    rep(c("Men", "Women"), each = 7),
    levels = c("Men", "Women")
  ),
  Values = c(
    16, 16, 15, 17, 9, 3, 1,
    -11, -1, -5, -1, -10, -11, -19
  )
)

# 2. Diverging bar chart
p <- ggplot(
  df,
  aes(
    x = Dimension,
    y = Values,
    fill = Sex
  )
) +
  geom_col(
    width = 0.72
  ) +
  geom_hline(
    yintercept = 0,
    color = "grey40",
    linewidth = 0.35
  ) +
  coord_flip() +
  scale_y_continuous(
    limits = c(-20, 20),
    breaks = seq(-20, 20, 5),
    labels = abs,
    expand = expansion(mult = 0)
  ) +
  scale_fill_brewer(
    palette = "Paired",
    guide = guide_legend(reverse = TRUE)
  ) +
  labs(
    x = NULL,
    y = "Value",
    fill = NULL
  ) +
  theme_minimal(base_size = 9) +
  theme(
    axis.text.x = element_text(
      size = 7,
      color = "grey50"
    ),
    axis.text.y = element_text(
      size = 8,
      color = "#25364A"
    ),
    axis.title.x = element_text(
      size = 8,
      face = "bold",
      color = "grey30"
    ),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(
      linewidth = 0.26,
      color = "#E8EBEF"
    ),
    legend.position = "bottom",
    legend.text = element_text(
      size = 7,
      color = "grey40"
    ),
    legend.key.height = grid::unit(8, "pt"),
    legend.key.width = grid::unit(12, "pt"),
    legend.spacing.x = grid::unit(4, "pt"),
    plot.margin = margin(8, 8, 8, 8)
  )

# 3. Export chart
ggsave(
  "src/stories/charts/back-to-back/plot01-r.svg",
  plot = p,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
