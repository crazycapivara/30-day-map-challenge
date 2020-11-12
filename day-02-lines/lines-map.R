library(magrittr)
library(sf)
library(mapboxer)

PALETTE <- "YlOrRd"
TIME_LIMIT <- 10 # Units in min

points <- data.table::fread("data/graphhopper-point-cloud-berlin.csv") %>%
  dplyr::filter(time <= TIME_LIMIT & time > 0) %>%
  dplyr::mutate(
    prev_longitude = as.double(prev_longitude),
    prev_latitude = as.double(prev_latitude),
    #time = as.integer(time),
    color = scales::col_bin(PALETTE, time)(time)
  ) %>%
  tibble::as_tibble()

### Use deckgl layer

points$col_rgb <- lapply(points$color, function(x) as.list(col2rgb(x)))

# Create viz
mapboxer(
  center = c(13.404694, 52.521235),
  zoom = 12,
  pitch = 35
) %>%
  add_deckgl_layer(
    type = "LineLayer",
    id = "deckgl-lines",
    data = points,
    getWidth = 3,
    getSourcePosition = "@=[ {{prev_longitude}}, {{prev_latitude}} ]",
    getTargetPosition = "@=[ {{longitude}}, {{latitude}} ]",
    getColor = htmlwidgets::JS("d => d.col_rgb")
  )

### Use mapbox layer

# Prepare line features
build_line <- function(row) {
  matrix(unlist(row), ncol = 2, byrow = TRUE) %>%
    sf::st_linestring()
}

lines_sf <- lapply(1:nrow(points), function(i) build_line(points[i, 1:4])) %>%
  sf::st_sfc(crs = 4326) %>%
  sf::st_sf()
lines_sf$color <- points$color

# Create viz
mapboxer(
  bounds = sf::st_bbox(lines_sf),
  pitch = 40
) %>%
  add_line_layer(
    source = as_mapbox_source(lines_sf),
    line_color = c("get", "color"),
    line_width = 3
  )
