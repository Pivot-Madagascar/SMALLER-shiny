#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#declare packages
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
library(reactable)
library(paletteer)
library(bslib)

# Define server logic
shinyServer(function(input, output) {

  #landing page map
  mod_landing_map_server("land_map")
  #data table server
  mod_tableau_donnees_server("fokontany_table")
  #community health server
  # mod_sante_comm_server("comm1")
  # mod_fktselect_server("comm1")
  # 
  # #commune level server
  # mod_sante_primaire_server("commune")
  
  #community cases server
  mod_chc_besoins_server("chc_cases")
  
  #stockout barchart module
  # mod_stock_act_server("act1")
  
  #stockout table module
  mod_besoins_csb_server("act_table")
  
  #interventions modeul
  mod_interventions_server("model_scenarios")

})
