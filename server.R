#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#declare pacakges
require(shiny)
require(shinyWidgets)
require(shinydashboard)
require(shinydashboardPlus)
require(dplyr)
require(lubridate)
require(stringr)
require(leaflet)
require(plotly)
require(DT)
require(scales)
require(tidyr)
require(ggplot2)
require(sf)
require(fontawesome)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  #landing page map
  mod_landing_map_server("land_map")
  #data table server
  mod_data_explore_server("fokontany_table")
  #community health server
  # mod_sante_comm_server("comm1")
  # mod_fktselect_server("comm1")
  # 
  # #commune level server
  # mod_sante_primaire_server("commune")
  
  #stockout barchart module
  mod_stock_act_server("act1")

})
