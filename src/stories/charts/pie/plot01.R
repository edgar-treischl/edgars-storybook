library(dplyr)
library(ggplot2)
library(scales)
library(ggtext)
library(sysfonts)
library(showtext)
library(tibble)


treemap_data <- tribble(
  ~Topic,        ~Subtopic,          ~Raw, ~percentage, ~percentage_facet,
  "Democrats",   "Others",             24L,       14.04,           63.16,
  "Democrats",   "Chuck & Nancy",       6L,        3.51,           15.79,
  "Democrats",   "Hillary",             8L,        4.68,           21.05,
  "GOP",         "Corker",              4L,        2.34,           33.33,
  "GOP",         "Others",              8L,        4.68,           66.67,
  "The media",   "Others",             14L,        8.19,           15.73,
  "The media",   "NYT",                17L,        9.94,           19.10,
  "The media",   "CNN",                13L,        7.60,           14.61,
  "The media",   "NBC",                12L,        7.02,           13.48,
  "The media",   '"Fake News!"',        33L,       19.30,           37.08,
  "Others",      "Int'l figures",       3L,        1.75,            9.38,
  "Others",      "Companies",           4L,        2.34,           12.50,
  "Others",      "Sports",              8L,        4.68,           25.00,
  "Others",      "Celebrities",         6L,        3.51,           18.75,
  "Others",      "Comey",               7L,        4.09,           21.88,
  "Others",      "Others",              4L,        2.34,           12.50
)




sysfonts::font_add_google("Lato", "Lato")
showtext::showtext_auto()

topic_colors <- c(
  "Democrats" = "#377EB8",
  "GOP"       = "#D94841",
  "The media" = "#E6AB35",
  "Others"    = "#8C7AA9"
)

pie_data <- treemap_data |>
  group_by(Topic) |>
  summarise(
    n = sum(Raw, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    Topic = factor(Topic, levels = names(topic_colors))
  ) |>
  arrange(Topic) |>
  mutate(
    freq = n / sum(n),
    label = paste0(
      as.character(Topic), "\n",
      percent(freq, accuracy = 0.1)
    )
  )

p <- ggplot(
  pie_data,
  aes(x = 1, y = freq, fill = Topic)
) +
  geom_col(
    width = 1,
    color = "#FFFFFF",
    linewidth = 0.6
  ) +
  coord_polar(theta = "y") +
  geom_text(
    aes(label = label),
    position = position_stack(vjust = 0.5),
    color = "#FFFFFF",
    family = "Lato",
    fontface = "bold",
    size = 2.0,
    lineheight = 1.1
  ) +
  scale_fill_manual(
    values = topic_colors,
    drop = FALSE
  ) +
  labs(
    title = "Donald’s Twitter Topics",
    subtitle = "Share of all observations",
    caption = paste0(
      "Total observations: ",
      comma(sum(pie_data$n))
    )
  ) +
  theme_void(base_size = 9, base_family = "Lato") +
  theme(
    legend.position = "none",
    plot.title = element_text(
      size = 12,
      face = "bold",
      color = "#25364A",
      hjust = 0.5,
      margin = margin(b = 4)
    ),
    plot.subtitle = element_text(
      size = 8,
      color = "grey40",
      hjust = 0.5,
      margin = margin(b = 8)
    ),
    plot.caption = element_text(
      size = 6,
      color = "grey55",
      hjust = 0,
      margin = margin(t = 8)
    ),
    plot.background = element_rect(
      fill = "white",
      color = NA
    ),
    panel.background = element_rect(
      fill = "white",
      color = NA
    ),
    plot.margin = margin(8, 8, 8, 8)
  )

p

ggsave(
  "src/stories/charts/pie/plot01-r.svg",
  plot = p,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
