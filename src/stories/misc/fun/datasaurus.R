r
sysfonts::font_add_google("Amatic SC", "Amatic+SC")
showtext::showtext_auto()

# 1. Datasaurus dino
dino <- dplyr::filter(
  datasauRus::datasaurus_dozen,
  dataset == "dino"
)

p1 <- ggplot2::ggplot(
  dino,
  ggplot2::aes(x = x, y = y)
) +
  ggplot2::geom_point(size = 0.75) +
  ggplot2::theme(legend.position = "none") +
  ggplot2::theme_minimal() +
  ggplot2::theme(
    text = ggplot2::element_text(
      size = 9,
      family = "Amatic+SC"
    )
  ) +
  ggplot2::labs(
    title = "The datasauRus and friends"
  ) +
  ggplot2::theme(
    plot.title = ggplot2::element_text(
      size = 12,
      face = "bold"
    ),
    strip.text.x = ggplot2::element_text(
      size = 9,
      color = "black",
      face = "bold"
    )
  )

# 2. Datasaurus selection
datasaurus_dozen2 <- dplyr::filter(
  datasauRus::datasaurus_dozen,
  dataset == "away" |
    dataset == "bullseye" |
    dataset == "circle" |
    dataset == "dots" |
    dataset == "star" |
    dataset == "x_shape"
)

p2 <- ggplot2::ggplot(
  datasaurus_dozen2,
  ggplot2::aes(x = x, y = y)
) +
  ggplot2::geom_point(size = 0.75) +
  ggplot2::theme(legend.position = "none") +
  ggplot2::facet_wrap(~dataset, ncol = 2) +
  ggplot2::theme_minimal() +
  ggplot2::theme(
    text = ggplot2::element_text(
      size = 9,
      family = "Amatic+SC"
    ),
    strip.text.x = ggplot2::element_text(
      size = 9,
      color = "black",
      face = "bold"
    )
  )

# 3. Combine plots
combined_plot <- cowplot::plot_grid(p1, p2)

# 4. Export combined plot
ggplot2::ggsave(
  "src/stories/misc/fun/plot01.svg",
  plot = combined_plot,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)