library(magrittr)
library(sf)
library(mapboxer)

PALETTE <- "YlOrRd"
TIME_LIMIT <- 8 # Units in min

points <- data.table::fread("data/graphhopper-point-cloud-berlin.csv") %>%
  dplyr::select(lng = longitude, lat = latitude, time) %>%
  dplyr::filter(time <= TIME_LIMIT) %>%
  dplyr::mutate(
    time = as.integer(time),
    color = scales::col_bin(PALETTE, time)(time)
  )

mapboxer(
  center = c(13.404694, 52.521235)
) %>%
  add_circle_layer(
    source = as_mapbox_source(points),
    circle_color = c("get", "color"),
    circle_blur = 1
  )
