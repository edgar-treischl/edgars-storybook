library(geojsonio)
library(dplyr)
library(ggplot2)
library(sf)

# 1. Prepare unemployment data
umemployment <- tibble::tribble(
  ~id, ~Umemployment,
  "Kentucky", 4.3,
  "Utah", 5.1,
  "Idaho", 5.6,
  "North Dakota", 6.1,
  "Maine", 6.6,
  "Oklahoma", 6.6,
  "Nebraska", 6.7,
  "Montana", 7.1,
  "South Dakota", 7.2,
  "Alabama", 7.5,
  "Kansas", 7.5,
  "Georgia", 7.6,
  "North Carolina", 7.6,
  "Wyoming", 7.6,
  "Missouri", 7.9,
  "Arkansas", 8,
  "Iowa", 8,
  "Maryland", 8,
  "New Mexico", 8.3,
  "Virginia", 8.4,
  "Wisconsin", 8.5,
  "District of Columbia", 8.6,
  "Minnesota", 8.6,
  "Texas", 8.6,
  "Mississippi", 8.7,
  "South Carolina", 8.7,
  "Vermont", 9.4,
  "Louisiana", 9.7,
  "Tennessee", 9.7,
  "Connecticut", 9.8,
  "Washington", 9.8,
  "Arizona", 10,
  "Florida", 10.4,
  "West Virginia", 10.4,
  "Colorado", 10.5,
  "Ohio", 10.9,
  "Indiana", 11.2,
  "Oregon", 11.2,
  "New Hampshire", 11.8,
  "Alaska", 12.4,
  "Rhode Island", 12.4,
  "Delaware", 12.5,
  "Pennsylvania", 13,
  "Hawaii", 13.9,
  "Illinois", 14.6,
  "Michigan", 14.8,
  "California", 14.9,
  "Nevada", 15,
  "New York", 15.7,
  "New Jersey", 16.6,
  "Massachusetts", 17.4
)

# 2. Load the hex-grid GeoJSON
spdf <- geojson_read(
  "src/stories/charts/hex/us_states_hexgrid.geojson",
  what = "sp"
)

# 3. Convert to sf
states <- st_as_sf(spdf)

# 4. Clean state names
states <- states %>%
  mutate(
    google_name = gsub(
      " \\(United States\\)",
      "",
      google_name
    )
  )

# 5. Join unemployment data
states <- states %>%
  left_join(
    umemployment,
    by = c("google_name" = "id")
  )

# 6. Calculate label positions
centers_sf <- st_point_on_surface(states)

centers <- cbind(
  st_coordinates(centers_sf),
  id = centers_sf$iso3166_2
)

centers <- as.data.frame(centers)

names(centers)[1:2] <- c("x", "y")

# 7. Create the hex-grid map
p <- ggplot() +
  geom_sf(
    data = states,
    aes(fill = Umemployment),
    color = "white",
    linewidth = 0.2
  ) +
  geom_sf_text(
    data = centers_sf,
    aes(label = iso3166_2),
    size = 7 / ggplot2::.pt,
    color = "#25364A",
    fontface = "bold"
  ) +
  scale_fill_viridis_c(
    name = "Unemployment (%)\nin the US (06/2020)",
    na.value = "white",
    guide = guide_colorbar(
      barwidth = grid::unit(45, "pt"),
      barheight = grid::unit(5, "pt"),
      title.position = "top",
      title.hjust = 0.5
    )
  ) +
  labs(
    caption = "Source: US state unemployment data, June 2020"
  ) +
  theme_void(base_size = 9) +
  theme(
    legend.position = "bottom",
    legend.title = element_text(
      size = 8,
      face = "bold",
      color = "#25364A"
    ),
    legend.text = element_text(
      size = 7,
      color = "grey40"
    ),
    plot.caption = element_text(
      size = 6,
      color = "grey55",
      hjust = 0,
      margin = margin(t = 8)
    ),
    plot.margin = margin(8, 8, 8, 8)
  )

# 8. Export map as SVG
ggsave(
  "src/stories/charts/hex/plot01-r.svg",
  plot = p,
  width = 5.3333,
  height = 3.3333,
  units = "in",
  device = svglite::svglite,
  bg = "white"
)
