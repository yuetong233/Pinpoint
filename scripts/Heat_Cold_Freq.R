rm(list = ls(all = TRUE))
load("data/county_heatwave_frequency_2020.rda")
load("data/county_coldspell_frequency_2020.rda")

# libraries
library(tigris)   # for U.S. county shapefiles
library(sf)       # for spatial data handling
library(dplyr)    # for data wrangling
library(leaflet)  # for interactive maps

# libraries
library(tigris)      # for U.S. county shapefiles
library(sf)          # for spatial data handling
library(dplyr)       # for data wrangling
library(leaflet)     # for interactive maps
library(htmlwidgets) # for saving html widgets

# Load and prepare county geometries
counties_sf <- counties(
  cb    = TRUE,
  class = "sf",
  year  = 2020
) %>%
  filter(!(STATEFP %in% c("02","15","60","66","69","72"))) %>%
  st_set_crs(4269) %>%    # tigris default is NAD83 (EPSG:4269)
  st_transform(4326) %>%  # convert to WGS84 (EPSG:4326)
  mutate(GEOID = as.character(GEOID))

# Join heatwave and coldspell summaries
counties_map <- counties_sf %>%
  left_join(heatwave_combined, by = "GEOID") %>%
  left_join(coldspell_combined, by = "GEOID")

# Define color palettes
pal_hw <- colorNumeric("YlOrRd", domain = counties_map$heatwave_mean, na.color = "transparent")
pal_cp <- colorNumeric("Blues",  domain = counties_map$coldspell_mean, na.color = "transparent")

# Build Leaflet widget object
m <- leaflet(counties_map) %>%
  addProviderTiles("CartoDB.Positron") %>%
  
  # set initial center & zoom
  setView(lng = -95, lat = 37, zoom = 4) %>%
  
  # Heatwave layer
  addPolygons(
    fillColor   = ~pal_hw(heatwave_mean),
    fillOpacity = 0.8, weight = 0.2, color = "#444444",
    group       = "Heatwave Frequency",
    label       = ~paste0(NAME, ": ", round(heatwave_mean, 2), " events/yr"),
    highlightOptions = highlightOptions(weight = 2, color = "#666666", bringToFront = TRUE)
  ) %>%
  addLegend(pal = pal_hw, values = ~heatwave_mean, position = "bottomright",
            title = "Mean Heatwaves", group = "Heatwave Frequency") %>%
  
  # Cold‐spell layer
  addPolygons(
    fillColor   = ~pal_cp(coldspell_mean),
    fillOpacity = 0.8, weight = 0.2, color = "#444444",
    group       = "Cold‐Spell Frequency",
    label       = ~paste0(NAME, ": ", round(coldspell_mean, 2), " events/yr"),
    highlightOptions = highlightOptions(weight = 2, color = "#666666", bringToFront = TRUE)
  ) %>%
  addLegend(pal = pal_cp, values = ~coldspell_mean, position = "bottomleft",
            title = "Mean Cold Spells", group = "Cold‐Spell Frequency") %>%
  
  # Layer controls (start with heatwaves visible)
  addLayersControl(
    overlayGroups = c("Heatwave Frequency", "Cold‐Spell Frequency"),
    options       = layersControlOptions(collapsed = FALSE)
  ) %>%
  hideGroup("Cold‐Spell Frequency")

# RStudio Viewer
m

# Save as standalone HTML (in your working directory)
saveWidget(
  widget     = m,
  file       = "figures/county_heat_cold_map.html",
  selfcontained = TRUE
)