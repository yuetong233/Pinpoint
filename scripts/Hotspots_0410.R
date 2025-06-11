rm(list = ls(all = TRUE))
load("data/GIS_data0410.rda")

############# Interactive Map for Heatwaves and Coldspells 0410#################
library(leaflet)
library(sf)
library(dplyr)
library(htmlwidgets)

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

county_phw10 <- sf_data0410_5hh1_phwcs_clean %>%
  group_by(GEOID.weather) %>%
  summarize(mean_p_hw = mean(p_value_hw, na.rm = TRUE))

# drop the geometry so it's just a data.frame
county_phw10_df <- county_phw10 %>%
  st_drop_geometry() %>%
  rename(GEOID = GEOID.weather)

county_pcp10 <- sf_data0410_5hh1_phwcs_clean %>%
  group_by(GEOID) %>%
  summarize(mean_p_cp = mean(p_value_cp, na.rm = TRUE))

county_pcp10_df <- county_pcp10 %>%
  st_drop_geometry()

# Join to spatial data (now safe)
county_map_hw10 <- counties_sf %>%
  left_join(county_phw10_df, by = "GEOID")

county_map_cp10 <- counties_sf %>%
  left_join(county_pcp10_df, by = "GEOID")

# Define reversed palettes
pal_hw <- colorNumeric("YlOrRd", domain = county_map_hw10$mean_p_hw, reverse = TRUE, na.color = "transparent")
pal_cp <- colorNumeric("BuGn",  domain = county_map_cp10$mean_p_cp,  reverse = TRUE, na.color = "transparent")

# Build leaflet with overlay groups
combined_leaflet <- leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  setView(lng = -95, lat = 37, zoom = 4) %>%
  
  # Heatwave overlay
  addPolygons(
    data        = county_map_hw10,
    fillColor   = ~pal_hw(mean_p_hw),
    color       = "white", weight = 1, fillOpacity = 0.7,
    group       = "Heatwave Hotspots",
    label       = ~paste0(NAME, ": p = ", formatC(mean_p_hw, digits = 3, format = "f")),
    highlightOptions = highlightOptions(weight = 2, color = "#666", fillOpacity = 0.9, bringToFront = TRUE)
  ) %>%
  addLegend(
    pal      = pal_hw,
    values   = county_map_hw10$mean_p_hw,
    position = "bottomright",
    title    = "Heatwave p-value",
    group    = "Heatwave Hotspots"
  ) %>%
  
  # Cold-spell overlay
  addPolygons(
    data        = county_map_cp10,
    fillColor   = ~pal_cp(mean_p_cp),
    color       = "white", weight = 1, fillOpacity = 0.7,
    group       = "Cold-Spell Hotspots",
    label       = ~paste0(NAME, ": p = ", formatC(mean_p_cp, digits = 3, format = "f")),
    highlightOptions = highlightOptions(weight = 2, color = "#666", fillOpacity = 0.9, bringToFront = TRUE)
  ) %>%
  addLegend(
    pal      = pal_cp,
    values   = county_map_cp10$mean_p_cp,
    position = "bottomleft",
    title    = "Cold-spell p-value",
    group    = "Cold-Spell Hotspots"
  ) %>%
  
  # Allow both overlays simultaneously
  addLayersControl(
    overlayGroups = c("Heatwave Hotspots", "Cold-Spell Hotspots"),
    options       = layersControlOptions(collapsed = FALSE)
  )

# Render in Viewer
combined_leaflet

# Save standalone HTML
saveWidget(
  combined_leaflet,
  file          = "figures/leaflet_Gi_heat_cold10.html",
  selfcontained = TRUE
)