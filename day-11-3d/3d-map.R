library(magrittr)
library(h3)
library(mapboxer)

# Constants
START_POINT <- list(
  lat = 52.521235,
  lng = 13.404694
)
TIME_LIMT <- 1000 # Units in seconds

H3_RESOLUTION <- 8
PALETTE <- wesanderson::wes_palettes$Rushmore1
PALETTE <- "Blues"

# Get data
query <- paste0(
  "http://localhost:8989/spt",
  "?point=", START_POINT$lat, ",", START_POINT$lng,
  "&time_limit=", TIME_LIMT,
  "&columns=prev_longitude,prev_latitude,longitude,latitude,time"
)

# Use  'docker-compose up -d'
# to start a local graphhopper instance with data of Berlin
# or use the graphhopper dataset included in the data directory
point_cloud_df <- data.table::fread(query) %>%
  dplyr::mutate(time = time/1000/60)

#data.table::fwrite(point_cloud_df, "data/graphhopper-point-cloud-berlin.csv", sep = ";")

# Prepare data
hexagons_sf <- point_cloud_df %>%
  dplyr::mutate(
    h3_index = geo_to_h3(point_cloud_df[, c("latitude", "longitude")], res = H3_RESOLUTION)
  ) %>%
  dplyr::group_by(h3_index) %>%
  dplyr::summarise(time = mean(time)) %>%
  dplyr::mutate(
    time = as.integer(time),
    geometry = h3_to_geo_boundary_sf(h3_index)$geometry,
    color = scales::col_bin(PALETTE, time)(time)) %>%
  sf::st_as_sf()

# Create viz
mapboxer(
  bounds = sf::st_bbox(hexagons_sf),
  fitBoundsOptions = list(padding = 20),
  #style = basemaps$Carto$voyager,
  pitch = 45,
  element_id = "day11_3d",
  width = 1000,
  height = 600
) %>%
  #set_paint_property("water", "fill-color", "blue") %>%
  add_source(as_mapbox_source(hexagons_sf), "hexagons") %>%
  add_fill_extrusion_layer(
    id = "extruded-hexagons",
    source = "hexagons",
    fill_extrusion_color = c("get", "color"),
    fill_extrusion_height = list("*", c("get", "time"), 100)
    , fill_extrusion_opacity = 0.5
    , popup = "Drive time: {{time}}"
  ) %>%
  add_navigation_control()
