library(magrittr)
library(sfheaders)
library(mapboxer)

# See installation script for h3
library(h3)

# Fetch data
uk_accidents19 <- stats19::get_stats19(2019)

# Convert to class 'sf' without loading 'sf' pkg
uk_accidents19_sf <- uk_accidents19 %>%
  dplyr::filter(!is.na(longitude)) %>%
  sf_point(x = "longitude", y = "latitude")

# Create hexagons
H3_RESOLUTION <- 4

h3_hexagons_sf <- geo_to_h3(uk_accidents19_sf, res = H3_RESOLUTION) %>%
  tibble::tibble(index = .) %>%
  dplyr::count(index) %>%
  dplyr::mutate(
    geometry = h3_to_geo_boundary_sf(index)$geometry,
    color = scales::col_quantile("YlOrRd", n)(n)
  ) %>%
  sf::st_as_sf()

hexagon_points <- sf::st_coordinates(h3_hexagons_sf)[, c("X", "Y")] %>%
  tibble::as_tibble() %>%
  set_names(c("lng", "lat"))

SOURCE_ID_HEXAGONS <- "h3-hexagons"
SOURCE_ID_POINTS <- "hexagon-points"

mapboxer(
  bounds = sf_bbox(h3_hexagons_sf),
  element_id = "day10grid",
  width = 1000,
  height = 600
) %>%
  add_source(as_mapbox_source(h3_hexagons_sf), SOURCE_ID_HEXAGONS) %>%
  add_source(as_mapbox_source(hexagon_points), SOURCE_ID_POINTS) %>%
  set_paint_property("water", "fill_color", "white") %>%
  add_fill_layer(
    source = SOURCE_ID_HEXAGONS,
    fill_color = c("get", "color"),
    fill_opacity = 0.3,
    popup = "Number of crashes: {{n}}"
  ) %>%
  add_line_layer(
    source = SOURCE_ID_HEXAGONS,
    line_color = "white",
    line_width = 3
    , line_blur = 1
    #, visibility = "none"
  ) %>%
  add_circle_layer(
    source = SOURCE_ID_POINTS,
    circle_color = "yellow",
    circle_blur = 1
    , circle_radius = 5
  ) %>%
  add_navigation_control()
