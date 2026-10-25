
library(ggplot2)
library(patchwork)
library(showtext)
library(sysfonts)

sysfonts::font_add_google("Lato", "lato")
showtext::showtext_auto()

theme_tiles <- ggplot2::theme_void(
  base_size = 9,
  base_family = "lato"
) +
  ggplot2::theme(
    text = ggplot2::element_text(
      family = "lato",
      color = "#25364A"
    ),
    plot.title = ggplot2::element_text(
      size = 9,
      face = "bold",
      color = "#25364A",
      hjust = 0.5,
      margin = ggplot2::margin(b = 5)
    ),
    plot.margin = ggplot2::margin(4, 5, 4, 5)
  )

make_tile_plot <- function(data, labels, colours, title = NULL) {
  data$label <- labels
  data$fill <- colours
  
  ggplot2::ggplot(
    data,
    ggplot2::aes(x = x, y = y)
  ) +
    ggplot2::geom_tile(
      ggplot2::aes(fill = fill),
      color = "white",
      linewidth = 0.7
    ) +
    ggplot2::geom_text(
      ggplot2::aes(label = label),
      color = "white",
      size = 3.1,
      family = "lato",
      fontface = "bold"
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::coord_flip() +
    ggplot2::labs(title = title) +
    theme_tiles
}

dfx <- expand.grid(x = 1:4, y = 1:2)

labels_x <- c(
  "3", "2", "1", "ID",
  "x3", "x2", "x1", "X"
)

colour_x <- c(
  "#74a9cf", "#0570b0", "#045a8d", "#302E2E",
  "#74a9cf", "#0570b0", "#045a8d", "#302E2E"
)

p1 <- make_tile_plot(
  dfx, labels_x, colour_x,
  "Data A"
)

labels_y <- c(
  "4", "2", "1", "ID",
  "y4", "y2", "y1", "Y"
)

colour_y <- c(
  "#023858", "#0570b0", "#045a8d", "#302E2E",
  "#023858", "#0570b0", "#045a8d", "#302E2E"
)

p2 <- make_tile_plot(
  dfx, labels_y, colour_y,
  "Data B"
)

df_ij <- expand.grid(x = 1:3, y = 1:3)

labels_ij <- c(
  "2", "1", "ID",
  "x2", "x1", "X",
  "y2", "y1", "Y"
)

colour_ij <- c(
  "#0570b0", "#045a8d", "#302E2E",
  "#0570b0", "#045a8d", "#302E2E",
  "#0570b0", "#045a8d", "#302E2E"
)

p3 <- make_tile_plot(
  df_ij, labels_ij, colour_ij,
  "A. Inner join"
)

df_fj <- expand.grid(x = 1:5, y = 1:3)

labels_fj <- c(
  "4", "3", "2", "1", "ID",
  "NA", "x3", "x2", "x1", "X",
  "y4", "NA", "y2", "y1", "Y"
)

colour_fj <- c(
  "#023858", "#74a9cf", "#0570b0", "#045a8d", "#302E2E",
  "#c1121f", "#74a9cf", "#0570b0", "#045a8d", "#302E2E",
  "#023858", "#c1121f", "#0570b0", "#045a8d", "#302E2E"
)

p4 <- make_tile_plot(
  df_fj, labels_fj, colour_fj,
  "B. Full join"
)

df_lj <- expand.grid(x = 1:4, y = 1:3)

labels_lj <- c(
  "3", "2", "1", "ID",
  "x3", "x2", "x1", "X",
  "NA", "y2", "y1", "Y"
)

colour_lj <- c(
  "#74a9cf", "#0570b0", "#045a8d", "#302E2E",
  "#74a9cf", "#0570b0", "#045a8d", "#302E2E",
  "#c1121f", "#0570b0", "#045a8d", "#302E2E"
)

p5 <- make_tile_plot(
  df_lj, labels_lj, colour_lj,
  "C. Left join"
)

df_rj <- expand.grid(x = 1:4, y = 1:3)

labels_rj <- c(
  "4", "2", "1", "ID",
  "y4", "y2", "y1", "Y",
  "NA", "x2", "x1", "X"
)

colour_rj <- c(
  "#023858", "#0570b0", "#045a8d", "#302E2E",
  "#023858", "#0570b0", "#045a8d", "#302E2E",
  "#c1121f", "#0570b0", "#045a8d", "#302E2E"
)

p6 <- make_tile_plot(
  df_rj, labels_rj, colour_rj,
  "D. Right join"
)

source_row <- (p1 | p2) +
  patchwork::plot_layout(
    widths = c(1, 1)
  )

join_grid <- (p3 | p4) / (p5 | p6) +
  patchwork::plot_layout(
    widths = c(1, 1),
    heights = c(1, 1)
  )

final_plot <- (
  source_row /
    join_grid
) +
  patchwork::plot_layout(
    heights = c(0.7, 1.5)
  ) +
  patchwork::plot_annotation(
    title = "Understanding data joins",
    subtitle = "Source tables and the results of four common join operations",
    theme = ggplot2::theme(
      text = ggplot2::element_text(family = "lato"),
      plot.title = ggplot2::element_text(
        size = 12,
        face = "bold",
        color = "#25364A",
        hjust = 0.5,
        margin = ggplot2::margin(b = 4)
      ),
      plot.subtitle = ggplot2::element_text(
        size = 8,
        color = "grey40",
        hjust = 0.5,
        margin = ggplot2::margin(b = 8)
      ),
      plot.background = ggplot2::element_rect(
        fill = "white",
        color = NA
      )
    )
  )

print(final_plot)

ggplot2::ggsave(
  "src/stories/misc/illustrations/plot02.svg",
  plot = final_plot,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
