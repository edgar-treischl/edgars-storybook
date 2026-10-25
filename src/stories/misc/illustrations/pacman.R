sysfonts::font_add_google("Press Start 2P", "Press Start 2P")
## Automatically use showtext to render text for future devices
showtext::showtext_auto()

df <- tidyr::tribble(
  ~Charts, ~Amount,
  "Resembles", 80.0,
  "Does not resemble", 20.0
)


# Very reduce blank theme
blank_theme <- ggplot2::theme_minimal(base_size = 10) +
  ggplot2::theme(
    axis.title.x = ggplot2::element_blank(),
    axis.title.y = ggplot2::element_blank(),
    panel.border = ggplot2::element_blank(),
    panel.grid = ggplot2::element_blank(),
    axis.ticks = ggplot2::element_blank(),
    axis.text = ggplot2::element_blank(),
    plot.subtitle = ggplot2::element_text(size = 12),
    plot.title = ggplot2::element_text(size = 16)
  )


p <- ggplot2::ggplot(df, ggplot2::aes(x = "", y = Amount, fill = Charts)) +
  ggplot2::geom_bar(width = 60, stat = "identity", colour = "black") +
  ggplot2::coord_polar("y", start = pi / 1.5) +
  ggplot2::scale_fill_manual(values = c("white", "#ffff00")) +
  blank_theme +
  ggplot2::theme(legend.position = "right") +
  ggplot2::theme(text = ggplot2::element_text(family = "Press Start 2P")) +
  ggplot2::guides(fill = ggplot2::guide_legend(reverse = TRUE)) +
  ggplot2::labs(
    title = "Pie Charts and Pac-Man",
    subtitle = "How many resemble a Pac-Man?",
    fill = " "
  )


# Expo
ggplot2::ggsave(
  "src/stories/misc/illustrations/plot01.svg",
  plot = p,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
