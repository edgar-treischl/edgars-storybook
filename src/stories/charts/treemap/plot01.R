library(ggplot2)
library(tibble)
library(treemapify)

sysfonts::font_add_google("Lato", "Lato")
showtext::showtext_auto()

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

# Set topic order
treemap_data$Topic <- factor(
  treemap_data$Topic,
  levels = c("Democrats", "GOP", "The media", "Others")
)

topic_colors <- c(
  "Democrats" = "#377EB8",  # Blue
  "GOP"       = "#D94841",  # Red
  "The media" = "#E6AB35",  # Gold
  "Others"    = "#8C7AA9"   # Muted purple
)


p <- ggplot(
  treemap_data,
  aes(
    area = percentage,
    fill = Topic,
    subgroup = Topic,
    label = Subtopic
  )
) +
  # Individual rectangles
  geom_treemap(
    colour = "white",
    size = 1.2
  ) +
  
  # Borders around main topic groups
  geom_treemap_subgroup_border(
    colour = "white",
    size = 2
  ) +
  
  # Main topic labels
  geom_treemap_subgroup_text(
    place = "bottomleft",
    grow = FALSE,
    alpha = 0.95,
    colour = "white",
    fontface = "bold",
    min.size = 0,
    family = "Lato"
  ) +
  
  # Subtopic labels
  geom_treemap_text(
    place = "centre",
    grow = FALSE,
    reflow = TRUE,
    colour = "black",
    fontface = "plain",
    min.size = 8,
    family = "Lato"
  ) +
  
  # Apply category colors
  scale_fill_manual(
    values = topic_colors,
    guide = "none"
  ) +
  
  # Titles
  labs(
    title = "Donald's Tweets",
    subtitle = "Who's to blame?"
  ) +
  
  # Clean editorial theme
  theme_minimal(
    base_size = 12,
    base_family = "Lato"
  ) +
  
  theme(
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    
    plot.title = element_text(
      face = "bold",
      size = 16,
      colour = "#222222"
    ),
    
    plot.subtitle = element_text(
      size = 10,
      colour = "#555555"
    ),
    
    plot.title.position = "plot",
    
    plot.margin = margin(12, 12, 12, 12),
    
    panel.background = element_rect(
      fill = "white",
      colour = NA
    ),
    
    plot.background = element_rect(
      fill = "white",
      colour = NA
    )
  )


p



# Export
ggsave(
  "src/stories/charts/treemap/plot01-r.svg",
  plot = p,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
