rm(list = ls(all = TRUE))

load("data/county_HDD_CDD.rda") 
library(sf)
library(leaflet)
library(viridis)
library(htmlwidgets)
library(dplyr)

# Data preparation
non_mainland <- c("02", "15", "60", "66", "69", "72")
mainland_counties <- us_counties %>%
  filter(!STATEFP %in% non_mainland) %>%
  st_transform(crs = 4326)

# Define palettes for HDD and CDD
pal_hdd <- colorNumeric(
  palette  = viridis(7, option = "plasma"),
  domain   = mainland_counties$HDD,
  na.color = "transparent"
)

pal_cdd <- colorNumeric(
  palette  = viridis(7, option = "cividis"),
  domain   = mainland_counties$CDD,
  na.color = "transparent"
)

# Build and assign the leaflet map
hdd_cdd_map <- leaflet(mainland_counties) %>%
  addProviderTiles("CartoDB.Positron") %>%
  setView(lng = -95, lat = 37, zoom = 4) %>%    # 
  
  # HDD layer
  addPolygons(
    fillColor   = ~pal_hdd(HDD),
    color       = "white",
    weight      = 1,
    fillOpacity = 0.8,
    group       = "HDD",
    label       = ~paste0(NAME, ": ", round(HDD, 1), " °F·day")
  ) %>%
  
  # CDD layer
  addPolygons(
    fillColor   = ~pal_cdd(CDD),
    color       = "white",
    weight      = 1,
    fillOpacity = 0.8,
    group       = "CDD",
    label       = ~paste0(NAME, ": ", round(CDD, 1), " °F·day")
  ) %>%
  
  # Legends
  addLegend(
    position  = "bottomright",
    pal       = pal_hdd,
    values    = ~HDD,
    title     = "HDD (2020)",
    group     = "HDD"
  ) %>%
  addLegend(
    position  = "bottomleft",
    pal       = pal_cdd,
    values    = ~CDD,
    title     = "CDD (2020)",
    group     = "CDD"
  ) %>%
  
  # Layer controls
  addLayersControl(
    overlayGroups = c("HDD", "CDD"),
    options       = layersControlOptions(collapsed = FALSE)
  )

# Print it so RStudio Viewer displays the map
hdd_cdd_map

saveWidget(
  widget        = hdd_cdd_map,
  file          = "figures/leaflet_HDD_CDD.html",
  selfcontained = TRUE
)