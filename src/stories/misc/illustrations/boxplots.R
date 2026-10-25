
library(ggplot2)
library(cowplot)
library(showtext)
library(sysfonts)

sysfonts::font_add_google("Lato", "lato")
showtext::showtext_auto()

median_mpg <- median(mtcars$mpg)
min_mpg <- min(mtcars$mpg)
max_mpg <- max(mtcars$mpg)

box_stats <- ggplot2::ggplot_build(
  ggplot2::ggplot(mtcars, ggplot2::aes(x = mpg)) +
    ggplot2::geom_boxplot()
)$data[[1]]

q1_mpg <- box_stats$lower
q3_mpg <- box_stats$upper
whisker_min <- box_stats$ymin
whisker_max <- box_stats$ymax

plot <- ggplot2::ggplot(
  mtcars,
  ggplot2::aes(y = mpg)
) +
  ggplot2::geom_boxplot(
    width = 0.24,
    outlier.shape = 16,
    outlier.size = 1.8,
    outlier.colour = "#C51717",
    colour = "#404040",
    fill = "#F1F1F1",
    linewidth = 0.45
  ) +
  ggplot2::geom_segment(
    data = data.frame(
      y = whisker_min,
      yend = whisker_max,
      x = 0,
      xend = 0
    ),
    ggplot2::aes(
      x = x,
      y = y,
      xend = xend,
      yend = yend
    ),
    inherit.aes = FALSE,
    colour = "#C51717",
    linewidth = 0.8
  ) +
  ggplot2::coord_flip(clip = "off") +
  ggplot2::annotate(
    "text",
    y = median_mpg,
    x = 0.38,
    label = "Median",
    family = "lato",
    size = 2.5,
    colour = "#25364A"
  ) +
  ggplot2::annotate(
    "text",
    y = max_mpg - 1,
    x = -0.48,
    label = "Maximum",
    family = "lato",
    size = 2.5,
    colour = "#25364A"
  ) +
  ggplot2::geom_segment(
    ggplot2::aes(
      x = -0.12,
      y = max_mpg - 1.3,
      xend = -0.40,
      yend = max_mpg - 1.3
    ),
    inherit.aes = FALSE,
    arrow = ggplot2::arrow(
      length = grid::unit(0.09, "in"),
      type = "closed"
    ),
    colour = "#C51717",
    linewidth = 0.5
  ) +
  ggplot2::annotate(
    "text",
    y = 36.5,
    x = 0,
    label = "Potential\noutliers",
    family = "lato",
    size = 2.5,
    lineheight = 0.95,
    colour = "#C51717"
  ) +
  ggplot2::annotate(
    "text",
    y = min_mpg,
    x = -0.48,
    label = "Minimum",
    family = "lato",
    size = 2.5,
    colour = "#25364A"
  ) +
  ggplot2::geom_segment(
    ggplot2::aes(
      x = -0.12,
      y = min_mpg,
      xend = -0.40,
      yend = min_mpg
    ),
    inherit.aes = FALSE,
    arrow = ggplot2::arrow(
      length = grid::unit(0.09, "in"),
      type = "closed"
    ),
    colour = "#C51717",
    linewidth = 0.5
  ) +
  ggplot2::annotate(
    "text",
    y = (q1_mpg + q3_mpg) / 2,
    x = -0.48,
    label = "Interquartile\nrange",
    family = "lato",
    size = 2.5,
    lineheight = 0.95,
    colour = "#25364A"
  ) +
  ggplot2::scale_y_continuous(
    breaks = seq(5, 40, 5),
    expand = ggplot2::expansion(mult = c(0, 0))
  ) +
  ggplot2::scale_x_continuous(
    breaks = NULL,
    expand = ggplot2::expansion(mult = c(0, 0))
  ) +
  ggplot2::labs(
    title = "Understand Box Plots",
    subtitle = "Median, range, interquartile range and potential outliers",
    x = NULL,
    y = NULL,
    caption = "Source: mtcars dataset"
  ) +
  ggplot2::theme_minimal(base_size = 9, base_family = "lato") +
  ggplot2::theme(
    plot.title = ggplot2::element_text(
      size = 12,
      face = "bold",
      colour = "#25364A",
      margin = ggplot2::margin(b = 4)
    ),
    plot.subtitle = ggplot2::element_text(
      size = 8,
      colour = "grey40",
      margin = ggplot2::margin(b = 8)
    ),
    axis.text.x = ggplot2::element_text(
      size = 7,
      colour = "grey50"
    ),
    axis.text.y = ggplot2::element_blank(),
    axis.ticks = ggplot2::element_blank(),
    panel.grid.minor = ggplot2::element_blank(),
    panel.grid.major.y = ggplot2::element_blank(),
    panel.grid.major.x = ggplot2::element_line(
      linewidth = 0.26,
      colour = "#E8EBEF"
    ),
    plot.caption = ggplot2::element_text(
      size = 6,
      colour = "grey55",
      hjust = 0,
      margin = ggplot2::margin(t = 8)
    ),
    plot.margin = ggplot2::margin(8, 12, 8, 8)
  )

dots <- ggplot2::ggplot(
  mtcars,
  ggplot2::aes(x = mpg)
) +
  ggplot2::geom_dotplot(
    binwidth = 0.65,
    stackdir = "up",
    dotsize = 0.65,
    fill = "#939191",
    colour = "white",
    stroke = 0.15
  ) +
  ggplot2::scale_x_continuous(
    limits = c(5, 40),
    breaks = NULL,
    expand = ggplot2::expansion(mult = c(0, 0))
  ) +
  ggplot2::scale_y_continuous(
    NULL,
    breaks = NULL,
    expand = ggplot2::expansion(mult = c(0, 0.05))
  ) +
  ggplot2::theme_void(base_family = "lato") +
  ggplot2::theme(
    plot.margin = ggplot2::margin(0, 0, 0, 0)
  )

final_plot <- cowplot::ggdraw() +
  cowplot::draw_plot(
    plot,
    x = 0,
    y = 0.12,
    width = 1,
    height = 0.85
  ) +
  cowplot::draw_plot(
    dots,
    x = 0.205,
    y = 0.02,
    width = 0.64,
    height = 0.20
  )

print(final_plot)

ggplot2::ggsave(
  "src/stories/misc/illustrations/plot05.svg",
  plot = final_plot,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
