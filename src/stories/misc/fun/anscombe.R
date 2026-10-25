
library(ggplot2)
library(dplyr)
library(showtext)
library(sysfonts)

sysfonts::font_add_google("Lato", "lato")
showtext::showtext_auto()

anscombe_m <- bind_rows(
  lapply(1:4, function(i) {
    data.frame(
      set = i,
      x = anscombe[[i]],
      y = anscombe[[i + 4]]
    )
  })
) |>
  mutate(
    set_new = factor(
      set,
      levels = 1:4,
      labels = c("Case I", "Case II", "Case III", "Case IV")
    )
  )

cor_labels <- anscombe_m |>
  group_by(set_new) |>
  summarise(
    correlation = cor(x, y),
    .groups = "drop"
  ) |>
  mutate(
    label = paste0("r = ", sprintf("%.2f", correlation)),
    x = 19.5,
    y = 4.5
  )

anscombe_plot <- ggplot(
  anscombe_m,
  aes(x = x, y = y)
) +
  geom_point(
    size = 1.5,
    color = "#25364A"
  ) +
  geom_smooth(
    method = "lm",
    formula = y ~ x,
    se = FALSE,
    color = "#C51717",
    linewidth = 0.65
  ) +
  geom_text(
    data = cor_labels,
    aes(x = x, y = y, label = label),
    inherit.aes = FALSE,
    family = "lato",
    size = 2.6,
    color = "#555555",
    hjust = 1
  ) +
  facet_wrap(~set_new, ncol = 2) +
  scale_x_continuous(
    breaks = seq(4, 20, 4),
    expand = expansion(mult = c(0.04, 0.06))
  ) +
  scale_y_continuous(
    breaks = seq(2, 14, 4),
    expand = expansion(mult = c(0.06, 0.08))
  ) +
  labs(
    title = "Anscombe's Quartet",
    subtitle = "Similar summary statistics can conceal very different data patterns",
    x = "X",
    y = "Y",
    caption = "Source: Anscombe's Quartet"
  ) +
  theme_minimal(
    base_size = 9,
    base_family = "lato"
  ) +
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
    strip.text = element_text(
      size = 8,
      face = "bold",
      color = "#25364A"
    ),
    axis.title = element_text(
      size = 8,
      face = "bold",
      color = "grey30"
    ),
    axis.text = element_text(
      size = 7,
      color = "grey50"
    ),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(
      color = "#E8EBEF",
      linewidth = 0.26
    ),
    panel.spacing = grid::unit(0.8, "lines"),
    plot.caption = element_text(
      size = 6,
      color = "grey55",
      hjust = 0,
      margin = margin(t = 8)
    ),
    plot.margin = margin(8, 10, 8, 8)
  )

print(anscombe_plot)

ggsave(
  "src/stories/misc/fun/plot02.svg",
  plot = anscombe_plot,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)

