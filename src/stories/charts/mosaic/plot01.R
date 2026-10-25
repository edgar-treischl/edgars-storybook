library(ggplot2)
library(ggmosaic2)

# 1. Prepare Titanic data
titanic_df <- as.data.frame(Titanic)

plot_df <- aggregate(
  Freq ~ Sex + Survived,
  data = titanic_df,
  FUN = sum
)

# 2. Mosaic plot
p <- ggplot(plot_df) +
  geom_mosaic(
    aes(
      x = product(Sex),
      fill = Survived,
      weight = Freq
    )
  ) +
  scale_fill_manual(
    values = c(
      "No" = "#08519c",
      "Yes" = "#6baed6"
    ),
    labels = c(
      "No" = "Not survived",
      "Yes" = "Survived"
    )
  ) +
  labs(
    x = "Sex",
    y = "Proportion",
    title = "Who survived the Titanic?",
    subtitle = "Passenger sex and survival",
    fill = "Survival",
    caption = "Source: Titanic dataset"
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

# 3. Export chart
ggsave(
  "src/stories/charts/mosaic/plot01-r.svg",
  plot = p,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
