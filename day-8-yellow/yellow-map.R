# Use dev version of mapboxer (needed for deckgl layer)
#remotes::install_github("crazycapivara/mapboxer", ref = "develop")
library(mapboxer)

# Prepare data
data_url <- paste0(
  "https://raw.githubusercontent.com/plotly/datasets/master/",
  "2011_february_aa_flight_paths.csv"
)
flights <- data.table::fread(data_url)
#head(flights)
flights_from <- flights %>%
  dplyr::select(lng = "start_lon", lat = "start_lat", name = "airport1")
flights_to <- flights %>%
  dplyr::select(lng = "end_lon", lat = "end_lat", name = "airport2")

# Create a text style for the generic 'add_layer' func
text_style <- list(
  id = "labels",
  type = "symbol",
  source = "airports1",
  layout = list(
    "text-field" = "{name}",
    "text-size" = 15,
    "text-rotate" = 45
  ),
  paint = list(
    "text-color" = "#9B870C",
    "text-translate" = c(20, 20)
  )
)
# Create viz
mapboxer(
  center = c(-87.6500523, 41.850033),
  zoom = 2,
  pitch = 45,
  element_id = "day8yellow",
  height = 600,
  width = 1000
) %>%
  set_paint_property("water", "fill_color", "#ffff33") %>%
  add_source(as_mapbox_source(flights_from), "airports1") %>%
  add_source(as_mapbox_source(flights_to), "airports2") %>%
  add_layer(text_style) %>%
  add_circle_layer(
    id = "airports1",
    source = "airports1",
    circle_color = "#ffff00",
    circle_blur = 1,
    circle_radius = 10
  ) %>%
  add_circle_layer(
    id = "airports2",
    source = "airports2",
    circle_color = "orange",
    circle_radius = 5,
    circle_blur = 1
  ) %>%
  add_deckgl_layer(
    type = "ArcLayer",
    data = flights,
    getSourcePosition = "@=[{{start_lon}}, {{start_lat}}]",
    getTargetPosition = "@=[{{end_lon}}, {{end_lat}}]",
    getSourceColor = c(240, 195, 11),
    getTargetColor = c(230, 230, 0),
    getWidth = 2
  )
