anscombe_m <- data.frame()

sysfonts::font_add_google("Vollkorn", "Vollkorn")
showtext::showtext_auto()

for (i in 1:4) {
  anscombe_m <- rbind(anscombe_m, data.frame(
    set = i,
    x = anscombe[, i],
    y = anscombe[, i + 4]
  ))
}

anscombe_m <- anscombe_m |>
  dplyr::mutate(set_new = dplyr::case_when(
    set == 1 ~ "Case I",
    set == 2 ~ "Case II",
    set == 3 ~ "Case III",
    set == 4 ~ "Case IV"
  ))

anscombe_plot <- ggplot2::ggplot(
  anscombe_m,
  ggplot2::aes(x, y)
) +
  ggplot2::geom_point(
    size = 1.1,
    color = "black",
    fill = "black",
    shape = 21
  ) +
  ggplot2::geom_smooth(
    method = "lm",
    fill = NA,
    fullrange = TRUE,
    color = "red",
    alpha = 0.5,
    linewidth = 0.49
  ) +
  ggplot2::facet_wrap(~set_new, ncol = 2) +
  cowplot::theme_minimal_grid() +
  ggplot2::labs(
    title = "Anscombe's Quartet",
    alt = "www.edgar-treischl.de"
  ) +
  ggplot2::theme(
    strip.text.x = ggplot2::element_text(
      size = 9,
      color = "black",
      face = "bold"
    )
  ) +
  ggplot2::annotate(
    x = 12.5,
    y = 4.45,
    label = paste(
      "R = ",
      round(cor(anscombe_m$x, anscombe_m$y), 2)
    ),
    geom = "text",
    size = 2.5
  ) +
  ggplot2::theme(
    text = ggplot2::element_text(family = "Vollkorn"),
    plot.title = ggplot2::element_text(size = 12)
  )

# Export
ggplot2::ggsave(
  "src/stories/misc/fun/plot02.svg",
  plot = anscombe_plot,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
