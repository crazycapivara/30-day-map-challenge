library(mapboxer)

image_url <- paste0(
  "https://raw.githubusercontent.com/",
  "uber-common/deck.gl-data/master/",
  "website/sf-districts.png"
)

# left, bottom, right, top
bounds <- list(left = -122.5190, bottom = 37.7045, right = -122.355, top = 37.829)

# top left, top right, bottom right, bottom left
coords <- list(
  c(bounds$left, bounds$top),
  c(bounds$right, bounds$top),
  c(bounds$right, bounds$bottom),
  c(bounds$left, bounds$bottom)
)

image_source <- mapbox_source(
  type = "image",
  url = image_url,
  coordinates = coords
)

raster_style <- list(
  id = "overlay",
  type = "raster",
  source = image_source,
  paint = list(
    "raster-opacity" = 0.85
  )
)

usgs_us_imagery <- structure(
  list("https://basemap.nationalmap.gov/arcgis/rest/services/USGSImageryOnly/MapServer/tile/{z}/{y}/{x}"),
  attribution = 'Tiles courtesy of the <a href="https://usgs.gov/">U.S. Geological Survey</a>'
)

esri_tiles <- structure(
  list("https://server.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer/tile/{z}/{y}/{x}"),
  attribution = 'Tiles &copy; Esri &mdash; National Geographic, Esri, DeLorme, NAVTEQ, UNEP-WCMC, USGS, NASA, ESA, METI, NRCAN, GEBCO, NOAA, iPC'
)
# Create viz
mapboxer(
  style = basemap_raster_style(stamen_raster_tiles()),
  #style = basemap_raster_style(usgs_us_imagery),
  center = c(-122.45, 37.8),
  zoom = 11,
  element_id = "day13raster",
  width = 1000,
  height = 600
) %>%
  add_layer(raster_style)
