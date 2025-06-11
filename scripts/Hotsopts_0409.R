load("data/GIS_data0409.rda")
############# Interactive Map for Heatwaves and Coldspells 0410#################
library(leaflet)
library(sf)
library(dplyr)
library(htmlwidgets)

# --- Prepare the county sf + 0409 statistics ---------------------------------------

# 1) Heatwave hotspots (0409)
county_map_hw09 <- counties_sf %>%
  filter(!(STATEFP %in% c("02","15","60","66","69","72"))) %>%
  left_join(county_phw_df09, by = "GEOID") %>%  # your mean_p_hw from 0409
  rename(county = NAME) %>%
  st_transform(4326)

# 2) Cold-spell hotspots (0409)
county_map_cp09 <- counties_sf %>%
  filter(!(STATEFP %in% c("02","15","60","66","69","72"))) %>%
  left_join(county_pcp_df09, by = "GEOID") %>%  # your mean_p_cp from 0409
  rename(county = NAME) %>%
  st_transform(4326)

# --- Define reversed palettes ------------------------------------------------------

pal_hw09 <- colorNumeric(
  palette = "YlOrRd",
  domain  = county_map_hw09$mean_p_hw,
  reverse = TRUE,
  na.color = "transparent"
)

pal_cp09 <- colorNumeric(
  palette = "BuGn",
  domain  = county_map_cp09$mean_p_cp,
  reverse = TRUE,
  na.color = "transparent"
)

# --- Build the combined 0409 leaflet map -------------------------------------------

leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  
  # Heatwaves ’09 layer
  addPolygons(
    data        = county_map_hw09,
    fillColor   = ~pal_hw09(mean_p_hw),
    color       = "white", weight = 1, fillOpacity = 0.7,
    group       = "Heatwaves 09",
    highlightOptions = highlightOptions(
      weight       = 2, color = "#666", fillOpacity = 0.9,
      bringToFront = TRUE
    ),
    label = ~paste0(county, ": p = ",
                    formatC(mean_p_hw, digits = 3, format = "f"))
  ) %>%
  
  # Cold Spells ’09 layer
  addPolygons(
    data        = county_map_cp09,
    fillColor   = ~pal_cp09(mean_p_cp),
    color       = "white", weight = 1, fillOpacity = 0.7,
    group       = "Cold Spells 09",
    highlightOptions = highlightOptions(
      weight       = 2, color = "#666", fillOpacity = 0.9,
      bringToFront = TRUE
    ),
    label = ~paste0(county, ": p = ",
                    formatC(mean_p_cp, digits = 3, format = "f"))
  ) %>%
  
  # Legends
  addLegend(
    pal      = pal_hw09,
    values   = county_map_hw09$mean_p_hw,
    position = "bottomleft",
    title    = "Heatwave 09 p-value",
    group    = "Heatwaves 09"
  ) %>%
  addLegend(
    pal      = pal_cp09,
    values   = county_map_cp09$mean_p_cp,
    position = "bottomright",
    title    = "Cold Spell 09 p-value",
    group    = "Cold Spells 09"
  ) %>%
  
  # Layer control
  addLayersControl(
    baseGroups   = c("Heatwaves 09", "Cold Spells 09"),
    options      = layersControlOptions(collapsed = FALSE)
  ) -> map_0409

# View interactively
map_0409

# Save to standalone HTML
saveWidget(
  map_0409,
  file          = "figures/leaflet_Gi_heat_cold09.html",
  selfcontained = TRUE
)
