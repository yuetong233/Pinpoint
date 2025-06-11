rm(list = ls(all = TRUE))
setwd('/Users/wheeinner/Library/Mobile Documents/com~apple~CloudDocs/DSPG/Dual_Vul')

# app.R
library(shiny)

# Map the URL prefix “web” to your local folder “web/”
addResourcePath("web", "web")

ui <- fluidPage(
  titlePanel(
    div("Dual Vulnerability Maps", style = "text-align: center; width: 100%;")
  ),
  sidebarLayout(
    sidebarPanel(
      # dynamic intro text for each tab
      conditionalPanel(
        condition = "input.which == 'hdd_cdd'",
        h4("Heating & Cooling Degree-Days", align = "center"),
        p(style = "text-align: justify; line-height: 1.5; margin-bottom: 1em;",
        "This map shows county-level patterns of total Heating Degree Days (HDD) 
          and Cooling Degree Days (CDD) for 2020, calculated from daily Daymet data 
          using 10 km × 10 km spatial grids.",
          br(), br(),
        "\u2022 Daily HDD = max(0, 65°F - daily mean temperature)",
        br(), br(),
        "\u2022 Daily CDD = max(0, daily mean temperature - 65°F)",
        br(), br(),
       "You can click on any county to view its annual HDD and CDD values in °F.")
      ),
      conditionalPanel(
        condition = "input.which == 'freq'",
        h4("Heatwave & Cold-Spell Frequencies", align = "center"),
        p(style = "text-align: justify; line-height: 1.5; margin-bottom: 1em;",
        "This map shows the mean frequency of heatwaves and cold spells by county for 2020, 
          derived from MERRA-2 two-meter air temperature (T2M) data using 50 km × 50 km spatial grids.",
          br(), br(),
          "\u2022 A heatwave was defined as any period in 2020 with three or more consecutive days 
        exceeding the respective daily 95th percentile threshold at a given grid.",
          br(), br(), 
        "\u2022 A cold spell was identified as any sequence of three or more consecutive days in which 
        the daily mean temperature fell at or below the 5th percentile threshold for that 
        calendar day and location.",
         br(), br(),
        "\u2022 The percentile-based detection approach enabled the identification of localized, time-specific 
        heatwave and cold spell events in 2020 by comparing daily temperature conditions against a 
        decade-long historical baseline (2010–2019), with events counted by frequency.",
         br(), br(),
        "You can click on any county to view its heatwave and cold spell frequency in 2020.")
      ),  
      conditionalPanel(
        condition = "input.which == 'matched'",
        h4("Matched Households Map", align = "center"),
        p(style = "text-align: justify; line-height: 1.5; margin-bottom: 1em;",
        "This map visualizes the geographic distribution of all matched households included in the sample,
        18,265 out of 18,496, using the method provided in the paper.",
          br(), br(),
        "These households were matched using Heating Degree Days (HDD) and Cooling Degree Days (CDD) 
        from Daymet data and the RECS dataset. Note that multiple households may be matched to the 
        same geographic polygon, so a single point may represent more than one household.",
          br(), br(),
        "Each point on the map represents the location of a matched household, with color  
      indicating its estimated energy burden: light yellow denotes a low burden, red indicates  
      a higher burden, and black marks households with an energy burden exceeding 20%.",
         br(), br(),
        "You can click on any point to view the corresponding household ID(s) and energy burden.")
      ),
      conditionalPanel(
        condition = "input.which == 'hotspots'",
        h4("Bivariate Gi Hotspots", align = "center"),
        p(style = "text-align: justify; line-height: 1.5; margin-bottom: 1em;",
          "This map shows the significance levels of joint clustering between heatwave/cold spell frequency 
          and energy burden, based on the bivariate Getis-Ord Gi*.",
          br(), br(),
          "To ensure meaningful computation and statistical robustness, the map includes only counties with",
          strong("at least five matched households"),
          "resulting in a total of 15,887 observations.",
          br(), br(),
          "Red areas indicate statistically significant hotspots (p < 0.05) where high energy burden coincides 
          with frequent heatwaves, highlighting vulnerability during extreme heat. 
          Green shows similar hotspots for cold spells, signaling risks during colder seasons.",
          br(), br(),
          "You can click on any area to view the corresponding p-value from the Getis-Ord Gi* statistic.")
      ),
      conditionalPanel(
        condition = "input.which == 'policy'",
        h4("Policy Simulation Results", align = "center"),
        p("Coming soon: interactive visualizations of our counterfactual policy scenarios.")
      )
    ),
    
    mainPanel(
      tabsetPanel(id = "which",
                  tabPanel("HDD and CDD", value = "hdd_cdd",
                           tags$iframe(src       = "web/leaflet_HDD_CDD.html",
                                       width     = "100%", height = "750px",
                                       seamless  = "seamless", frameBorder = 0)
                  ),
                  tabPanel("Heat & Cold Frequencies", value = "freq",
                           tags$iframe(src       = "web/county_heat_cold_map.html",
                                       width     = "100%", height = "750px",
                                       seamless  = "seamless", frameBorder = 0)
                  ),
                  tabPanel("Matched Households", value = "matched",
                           # now the browser can fetch /web/pinpoint_matched_0410.html
                           tags$iframe(src       = "web/pinpoint_matched_0410.html",
                                       width     = "100%", height = "750px",
                                       seamless  = "seamless", frameBorder = 0)
                  ),
                  tabPanel("HDD/CDD Hotspots", value = "hotspots",
                           tags$iframe(src       = "web/leaflet_Gi_heat_cold10.html",
                                       width     = "100%", height = "750px",
                                       seamless  = "seamless", frameBorder = 0)
                  ),
                  tabPanel("Policy Simulation", value = "policy")
                  
                  
      ) # /tabsetPanel
    )   # /mainPanel
  )     # /sidebarLayout
)       # /fluidPage

server <- function(input, output, session) {}

shinyApp(ui, server)


