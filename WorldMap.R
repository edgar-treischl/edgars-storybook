
# WORLD TRAVEL JOURNAL

library(ggplot2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(dplyr)
library(patchwork)


if (!exists("world")) {
  message("Loading world map...")
  world <- ne_countries(
    scale = "medium",
    returnclass = "sf"
  )
}



visited <- c(
  "Germany",
  "Croatia",
  "France",
  "Italy",
  "Spain",
  "Portugal",
  "Austria",
  "Switzerland",
  "Peru",
  "Argentina",
  "United States of America",
  "Mexico",
  "Cuba",
  "Netherlands",
  "Kenya",
  "Thailand",
  "Cambodia",
  "United Kingdom",
  "Ireland",
  "Turkey",
  "Poland",
  "Czechia"
)


world <- world %>%
  mutate(
    country_fill = if_else(
      name %in% visited,
      name,
      "Not visited"
    )
  )


paper_color <- "#FFF"
map_background <- "#FAF8F3"

unvisited_color <- "#E7DDCA"
border_color <- "#AD9C84"


graticule_color <- "#AD9C84"
graticule_color <- "#403A33"
title_color <- "#403A33"
subtitle_color <- "#817669"



country_colors <- c(
  
  "Not visited" = "#E3DED3",
  # Europe
  "Germany"        = "#C6A12B",
  "France"         = "#557A9E",
  "Italy"          = "#5F896F",
  "Spain"          = "#B45B52",
  "Portugal"       = "#4F7D5F",
  "Austria"        = "#A4545D",
  "Switzerland"    = "#B6534A",
  "Netherlands"    = "#A94A52",
  "United Kingdom" = "#526A8B",
  "Ireland"        = "#579875",
  "Turkey"         = "#B94A4F",
  "Poland"         = "#B85A69",
  "Czechia"        = "#52749A",
  "Croatia"        = "#A94F55",
  # Americas
  "Peru"           = "#B65B61",
  "Argentina"      = "#6F9FC1",
  "United States of America" = "#55547D",
  "Mexico"         = "#4D866D",
  "Cuba"            = "#B4514D",
  # Africa
  "Kenya"          = "#54805F",
  # Asia
  "Thailand"       = "#A84D5A",
  "Cambodia"       = "#52759A"
)






missing_colors <- setdiff(
  visited,
  names(country_colors)
)

if (length(missing_colors) > 0) {

  stop(
    paste(
      "Missing colors for:",
      paste(missing_colors, collapse = ", ")
    )
  )
}




world_robinson <- st_transform(
  world,
  crs = "+proj=robin"
)


graticule_wgs84 <- st_graticule(
  lat = seq(-60, 60, by = 30),
  lon = seq(-150, 150, by = 30),
  crs = st_crs(4326)
)

graticule <- st_transform(
  graticule_wgs84,
  crs = st_crs(world_robinson)
)



set.seed(42)

texture <- expand.grid(
  x = seq(-180, 180, length.out = 500),
  y = seq(-90, 90, length.out = 250)
)

texture$alpha <- runif(
  nrow(texture),
  min = 0.003,
  max = 0.010
)




title_plot <- ggplot() +

  annotate(
    "text",
    x = 0.5,
    y = 0.62,
    label = "Around the World",
    family = "serif",
    fontface = "bold",
    size = 12,
    color = title_color
  ) +

  annotate(
    "text",
    x = 0.5,
    y = 0.30,
    label = "I haven't been everywhere, but it's on my list.",
    family = "serif",
    fontface = "italic",
    size = 5,
    color = subtitle_color
  ) +

  # subtle divider underneath header
  annotate(
    "segment",
    x = 0.28,
    xend = 0.72,
    y = 0.08,
    yend = 0.08,
    color = "#CFC2AD",
    linewidth = 0.35
  ) +

  xlim(0, 1) +
  ylim(0, 1) +

  theme_void() +

  theme(
    plot.background = element_rect(
      fill = paper_color,
      color = NA
    ),

    panel.background = element_rect(
      fill = paper_color,
      color = NA
    ),

    plot.margin = margin(
      t = 12,
      r = 20,
      b = 0,
      l = 20
    )
  )



# 11. MAP ######

map_plot <- ggplot() +
geom_sf(
  data = graticule,
  color = graticule_color,
  linewidth = 0.12,
  alpha = 0.30
) +
geom_sf(
  data = world_robinson,
  aes(fill = country_fill),
  color = border_color,
  linewidth = 0.20
) +
scale_fill_manual(
  values = country_colors,
  guide = "none"
) +
coord_sf(
  expand = FALSE
) +
theme_void() +
  theme(
    panel.background = element_rect(
      fill = map_background,
      color = NA
    ),
    plot.background = element_rect(
      fill = map_background,
      color = NA
    ),
    plot.margin = margin(
      t = 0,
      r = 20,
      b = 20,
      l = 20
    ),
    legend.position = "none"
  )




final_clean <- title_plot /
               map_plot +
               plot_layout(
                 heights = c(1.35, 6)
               )

final_clean



# Export

# ggsave(
#   filename = "world_travel_journal.png",
#   plot = final_clean,
#   width = 14,
#   height = 9,
#   units = "in",
#   dpi = 400,
#   bg = paper_color
# )


