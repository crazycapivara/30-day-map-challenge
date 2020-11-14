#install.packages("rnaturalearth")
library(rnaturalearth)

WEGo <- c("Scotland", "Iceland", "New Zealand", "Wales")

countries_sf <- ne_countries(
  returnclass = "sf",
  scale = 110,
  type = "map_units")[, c("name_long")] %>%
  dplyr::mutate(
    color = ifelse(name_long %in% WEGo, "green", "#ff6699")
  )

happy_map_style <- "mapbox://styles/examples/cke97f49z5rlg19l310b7uu7j"

mapboxer(
  bounds = sfheaders::sf_bbox(countries_sf)
  , style = basemap_background_style("#ffff80")
  #, style = happy_map_style
  , element_id = "day4climate-change"
  , height = 700
) %>%
  add_source(as_mapbox_source(countries_sf), "countries") %>%
  add_fill_layer(
    source = "countries"
    , fill_color = c("get", "color")
    , popup = "{{name_long}}"
    #, fill_opacity = 0.3
  ) %>%
  add_line_layer(
    source = "countries"
    , line_color = "white"
    , line_width = 1
    #, visibility = "none"
  )

### ggplot
library(ggplot2)

p <- ggplot(data = countries_sf) +
  theme_bw() +
  geom_sf(fill = countries_sf$color)
