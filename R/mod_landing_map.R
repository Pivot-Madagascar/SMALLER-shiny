#' landing_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom leaflet leafletOutput renderLeaflet
mod_landing_map_ui <- function(id){
  ns <- NS(id)

  leafletOutput(ns("map"), height = "60vh")

}


#' landing_panel UI Function
#'
#' @description A shiny Module that creates the UI for a panel to be inside the map
#' 
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom leaflet leafletOutput renderLeaflet
mod_map_panel_ui <-function(id){
  ns <- NS(id)
  
  #conditional panel is still kind of broekn, could change to a phrase asking to click
  conditionalPanel(condition = "input.map_shape_click", ns = ns,
                   absolutePanel(
                draggable = TRUE, fixed = FALSE,
                top = "10vh", left = "20vw", right = "auto", bottom = "auto",
                width = "auto", height = "auto",
                style = "background-color: white;
                         opacity: 0.85;
                         padding: 20px 20px 20px 20px;
                         border-radius: 5pt;
                         box-shadow: 0pt 0pt 6pt 0px rgba(61,59,61,0.48);
                         padding-bottom: 2mm;
                         padding-top: 1mm;",
                
                
                  plotlyOutput(ns("time_plot"), width = "30vw", height = "27vh")
                   )
  )
}

#' landing_map Server Functions
#'
#' @noRd
#' @import dplyr
#' @import leaflet
#' @import sf
#' @importFrom lubridate months
mod_landing_map_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    #load new end date
    new_end <- readRDS("data/dynamic/new_end.rds")
    
    #create map, data is already provided at correct date
    map_data <- readRDS("data/dynamic/inc_map_popup.rds") |>
      #drop NAs
      filter(!(is.na(median)))

    colorpal <- colorNumeric(
      palette = "YlOrRd",
      #set domain to min max of full dataset
      # domain = c(0,550),
      #or just current dataset (then it changes each month)
      domain = map_data$median,
      na.color = NA
    )
    colorpalLegend <- colorNumeric(
      palette = "YlOrRd",
      # domain = c(0,550),
      domain = map_data$median,
      na.color = NA,
      reverse = TRUE
    )
    #create map
    output$map <- renderLeaflet(
    leaflet(map_data) %>%
      addTiles() %>%
      setView(lat = -21, lng = 48.3, zoom = 9) %>%
      addPolygons(data = map_data,
                  fillColor = ~colorpal(median),
                  color = "black",
                  opacity = 1,
                  weight = 0.5,
                  fillOpacity = 0.8,
                  highlightOptions = highlightOptions(color = "black", bringToFront = FALSE,
                                                      weight = 3),
                  # popup = ~popup,
                  layerId = ~comm_fkt) %>%
      #add outlines
      addPolylines(data = map_data,
                  color = "black",
                  opacity = 1,
                  weight = 3,
                  fillOpacity = 0.8,
                  group = ~comm_fkt) %>%
      hideGroup(group = map_data$comm_fkt) %>%
      addLegend_decreasing("bottomleft", pal = colorpal, values = ~median,
                           title = "Incidence Prédit<br>(pour 1000)",
                           na.label = "", decreasing = TRUE)
    )
    
    proxy_map <- leafletProxy("map")
    
    #get selected fokontany from map for time series
    observeEvent(input$map_shape_click, {
      
      clicked_fkt <- input$map_shape_click$id
      communeSelect <- str_split_1(clicked_fkt, "_")[[1]]
      fktSelect <- str_split_1(clicked_fkt, "_")[[2]]
      
      #hide old selected and highlight new
      proxy_map |>
        hideGroup(map_data$comm_fkt) |>
        showGroup(clicked_fkt)
      
      output$time_plot <- renderPlotly(timeseries_comm(communeSelect = communeSelect,
                                                  fktSelect = fktSelect,
                                                  indicator = "inc"))
    })


  })
}

#testing function
map_demo <- function(){
  #source functions
  source("R/leaflet-legend-decreasing.R")
  source("R/utils_plotlyTime.R")
  source("R/utils_sante_comm.R")
  #declare packages
  library(shiny)
  library(dplyr)
  library(leaflet)

  ui <- fluidPage(
    fluidRow(
      column(10,
      mod_landing_map_ui("test1"),
      mod_map_panel_ui("test1")
      )
    )
  )

  server <- function(input, output, session){

    mod_landing_map_server("test1")
  }
  shinyApp(ui, server)
}

map_demo()
