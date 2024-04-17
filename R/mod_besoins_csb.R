#' stock table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom shinyWidgets pickerInput
mod_besoins_csb_ui <- function(id){
  ns <- NS(id)
  
  reactableOutput(ns("table"))
  
}

#' stock_act Server Functions
#'
#' @noRd
mod_besoins_csb_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    stock_table <- readRDS("data/dynamic/stockout-table.rds") 
    
    predict_header <- paste0("Prédictions ", stock_table$month_year[1])
    stock_table <- dplyr::select(stock_table, -month_year, -date_period) %>%
      dplyr::rename("Nombre de cas total" = case_total,
             "Nombre de cas prises en charge aux CSB" = case_csb)
    #create DT datable
    # sketch <- htmltools::withTags(table(
    #   class = 'display',
    #   thead(
    #     tr(
    #       th(rowspan = 2, 'CSB2'),
    #       th(colspan = 2, "Quantité de TDR (historique)"),
    #       th(colspan = 2, predict_header)
    #     ),
    #     tr(
    #       lapply(colnames(stock_table)[2:5], th)
    #     )
    #   )
    # ))
    
    output$table <- renderReactable({
      reactable(stock_table,
        columnGroups = list(
          colGroup(name = predict_header, columns = colnames(stock_table)[2:3]),
          colGroup(name =  "Quantité d'ACT requis", columns = colnames(stock_table)[4:5])
        ),
        defaultPageSize = 15 #number of CSBS
      )
    })
    
  })
}

besoins_csb_demo <- function(){
  #source functions
  source("R/utils_stock_act.R")
  #declare packages
  library(shiny)
  library(shinyWidgets)
  library(dplyr)
  library(lubridate)
  library(stringr)
  library(reactable)
  
  ui <- fluidPage(
    mod_besoins_csb_ui("act1")
  )
  server <- function(input, output, session){
    
    mod_besoins_csb_server("act1")
  }
  shinyApp(ui, server)
}

besoins_csb_demo()