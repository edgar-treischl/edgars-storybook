
library(ggplot2)
library(dplyr)
library(cowplot)
library(showtext)
library(sysfonts)

sysfonts::font_add_google("Patua One", "Patua")
showtext::showtext_auto()

set.seed(1)

n <- 100

men <- tibble(
  x = 5 + rnorm(n),
  y = 5 + rnorm(n)
) |>
  mutate(y = y - x / 4, Sex = "Men")

women <- men |>
  mutate(x = x + 2, y = y + 2, Sex = "Women")

simps_df <- bind_rows(men, women) |>
  mutate(Sex = factor(Sex, levels = c("Men", "Women")))

cols <- c(
  "Men" = "#C51717",
  "Women" = "#202020"
)

theme_simpson <- theme_minimal(
  base_size = 9,
  base_family = "Patua"
) +
  theme(
    plot.title = element_text(
      size = 10,
      face = "bold",
      color = "#25364A",
      margin = margin(b = 4)
    ),
    plot.subtitle = element_text(
      size = 7,
      color = "grey40",
      margin = margin(b = 8)
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
    plot.margin = margin(8, 8, 8, 8)
  )

p1 <- ggplot(simps_df, aes(x, y)) +
  geom_point(
    size = 1.5,
    alpha = 0.7,
    color = "#555555"
  ) +
  geom_smooth(
    method = "lm",
    formula = y ~ x,
    se = FALSE,
    linewidth = 0.8,
    color = "#C51717"
  ) +
  labs(
    title = "Pooled data",
    subtitle = "All observations combined",
    x = "X",
    y = "Y"
  ) +
  theme_simpson

p2 <- ggplot(simps_df, aes(x, y, color = Sex)) +
  geom_point(
    size = 1.5,
    alpha = 0.7
  ) +
  geom_smooth(
    method = "lm",
    formula = y ~ x,
    se = FALSE,
    linewidth = 0.8
  ) +
  scale_color_manual(values = cols) +
  labs(
    title = "Within-group data",
    subtitle = "Separate regression lines",
    x = "X",
    y = "Y"
  ) +
  theme_simpson +
  theme(legend.position = "none") +
  annotate(
    "label",
    x = 8.2,
    y = 5.5,
    label = "Women",
    color = "white",
    fill = cols["Women"],
    size = 2.5,
    label.size = 0,
    family = "Patua"
  ) +
  annotate(
    "label",
    x = 8.2,
    y = 2.9,
    label = "Men",
    color = "white",
    fill = cols["Men"],
    size = 2.5,
    label.size = 0,
    family = "Patua"
  )

header <- ggdraw() +
  draw_label(
    "Simpson's Paradox",
    x = 0.5,
    y = 0.65,
    hjust = 0.5,
    vjust = 0.5,
    fontfamily = "Patua",
    fontface = "bold",
    size = 14,
    color = "#25364A"
  ) +
  draw_label(
    "The aggregate trend reverses the patterns observed within each group",
    x = 0.5,
    y = 0.12,
    hjust = 0.5,
    vjust = 0.5,
    fontfamily = "Patua",
    size = 7,
    color = "grey40"
  )

panels <- plot_grid(
  p1,
  p2,
  nrow = 1,
  align = "hv",
  axis = "tblr",
  rel_widths = c(1, 1)
)

final_plot <- plot_grid(
  header,
  panels,
  ncol = 1,
  rel_heights = c(0.17, 1)
)


ggsave(
  "src/stories/misc/illustrations/plot04.svg",
  plot = final_plot,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
