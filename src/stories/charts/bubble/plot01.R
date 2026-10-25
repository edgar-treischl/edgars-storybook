
library(ggplot2)

p <- gapminder::gapminder |>
  dplyr::filter(year == 2007) |>
  dplyr::mutate(pop_m = pop / 1e6) |>
  dplyr::arrange(pop_m) |>
  ggplot2::ggplot(
    ggplot2::aes(
      x = gdpPercap,
      y = lifeExp,
      size = pop_m,
      color = continent
    )
  ) +
  ggplot2::geom_point(
    alpha = 0.7,
    stroke = 0
  ) +
  ggplot2::scale_x_log10(
    breaks = c(
      500, 1000, 2500, 5000,
      10000, 25000, 50000
    ),
    labels = scales::label_dollar(accuracy = 1)
  ) +
  ggplot2::scale_y_continuous(
    breaks = seq(30, 90, 10)
  ) +
  ggplot2::scale_size(
    range = c(1, 12),
    guide = "none"
  ) +
  ggplot2::coord_cartesian(
    ylim = c(30, 90)
  ) +
  viridis::scale_color_viridis(
    discrete = TRUE,
    option = "viridis",
    name = "Continent"
  ) +
  ggplot2::labs(
    title = "GDP and life expectancy",
    subtitle = "Bubble size represents population",
    x = "GDP per capita",
    y = "Life expectancy",
    caption = "Source: Gapminder"
  ) +
  ggtext::geom_richtext(
    data = data.frame(
      x = 2000,
      y = 44
    ),
    ggplot2::aes(x = x, y = y),
    label = paste0(
      "<b>Example interpretation:</b><br>",
      "<span style='color:#666666'>",
      "Higher GDP per capita is generally<br>",
      "associated with longer life expectancy.",
      "</span>"
    ),
    hjust = 0,
    vjust = 1,
    size = 2.4,
    lineheight = 1.0,
    family = "sans",
    color = "#303030",
    fill = scales::alpha("white", 0.92),
    label.color = "#D9D9D9",
    label.padding = grid::unit(
      c(0.45, 0.6, 0.45, 0.6),
      "lines"
    ),
    label.r = grid::unit(0.15, "lines"),
    inherit.aes = FALSE
  ) +
  ggplot2::guides(
    color = ggplot2::guide_legend(
      override.aes = list(
        size = 3,
        alpha = 1
      ),
      reverse = TRUE
    )
  ) +
  ggplot2::theme_minimal(base_size = 9) +
  ggplot2::theme(
    plot.title = ggtext::element_markdown(
      size = 12,
      face = "bold",
      color = "#25364A",
      margin = ggplot2::margin(b = 4)
    ),
    plot.subtitle = ggtext::element_markdown(
      size = 8,
      color = "grey40",
      lineheight = 1.1,
      margin = ggplot2::margin(b = 8)
    ),
    axis.title.x = ggplot2::element_text(
      size = 8,
      face = "bold",
      color = "grey30",
      margin = ggplot2::margin(t = 5)
    ),
    axis.title.y = ggplot2::element_text(
      size = 8,
      face = "bold",
      color = "grey30",
      margin = ggplot2::margin(r = 8)
    ),
    axis.text.x = ggplot2::element_text(
      size = 7,
      color = "grey50"
    ),
    axis.text.y = ggplot2::element_text(
      size = 7,
      color = "grey50"
    ),
    panel.grid.minor = ggplot2::element_blank(),
    panel.grid.major.x = ggplot2::element_line(
      linewidth = 0.26,
      color = "#E8EBEF"
    ),
    panel.grid.major.y = ggplot2::element_line(
      linewidth = 0.26,
      color = "#E8EBEF"
    ),
    legend.position = "bottom",
    legend.title = ggplot2::element_text(
      size = 8,
      face = "bold",
      color = "#25364A"
    ),
    legend.text = ggplot2::element_text(
      size = 7,
      color = "grey40"
    ),
    legend.key.height = grid::unit(8, "pt"),
    legend.key.width = grid::unit(12, "pt"),
    legend.spacing.x = grid::unit(4, "pt"),
    plot.caption = ggtext::element_markdown(
      size = 6,
      color = "grey55",
      hjust = 0,
      margin = ggplot2::margin(t = 8)
    ),
    plot.margin = ggplot2::margin(8, 12, 8, 8)
  )

p

# Bubble chart
ggplot2::ggsave(
  "src/stories/charts/bubble/plot01-r.svg",
  plot = p,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
