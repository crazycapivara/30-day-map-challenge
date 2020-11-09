# Polygons: "https://data.cityofnewyork.us/City-Government/Neighborhood-Tabulation-Areas-NTA-/cpf4-rkhq"
# Pop: "https://data.cityofnewyork.us/City-Government/New-York-City-Population-By-Neighborhood-Tabulatio/swpk-hqdp"

library(magrittr)
library(sf)
library(mapboxer)

#nta_sf <- st_read("data/NeighborhoodTabulationAreas-NTA.geojson")
#nta_pop <- data.table::fread("data/New_York_City_Population_By_Neighborhood_Tabulation_Areas.csv") %>%

# Prepare data
nta_sf <- st_read("https://data.cityofnewyork.us/api/geospatial/cpf4-rkhq?method=export&format=GeoJSON")
nta_pop <- data.table::fread("https://data.cityofnewyork.us/api/views/swpk-hqdp/rows.csv") %>%
  dplyr::filter(Year == 2010) %>%
  dplyr::select(ntacode = "NTA Code", pop = Population)

nta_sf %<>%
  dplyr::left_join(nta_pop, by = c("ntacode")) %>%
  dplyr::mutate(color = scales::col_quantile(c("#c2c2a3", "#d6d6c2"), pop)(pop))

# Create viz
mapboxer(
  bounds = st_bbox(nta_sf)
  #, style = basemap_background_style("#c2c2a3")
  , pitch = 45
  , element_id = "nyc"
  , width = 1000
  , height = 600
) %>%
  set_paint_property("water", "fill_color", "#878778") %>%
  add_source(as_mapbox_source(nta_sf), "nta") %>%
  add_fill_extrusion_layer(
    id = "nta",
    source = "nta",
    fill_extrusion_color = c("get", "color"),
    fill_extrusion_height = list("/", c("get", "pop"), 10)
    , fill_extrusion_opacity = 0.4
    , popup = mapbox_popup("Pop: {{pop}}", event = "hover")
  )
