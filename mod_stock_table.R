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
mod_stock_table_ui <- function(id){
  ns <- NS(id)
  
  reactableOutput(ns("table"))
  
}

#' stock_act Server Functions
#'
#' @noRd
mod_stock_table_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    table_data <- readRDS("data/dynamic/stockout-table.rds") 
    
    predict_header <- paste0("Prédictions ", table_data$month_year[1])
    table_data <- dplyr::select(table_data, -month_year) |>
      dplyr::rename("Cas total" = case_total,
             "Cas vus aux CSB" = case_csb)
    #create DT datable
    sketch <- htmltools::withTags(table(
      class = 'display',
      thead(
        tr(
          th(rowspan = 2, 'CSB2'),
          th(colspan = 2, "Quantité de TDR (historique)"),
          th(colspan = 2, predict_header)
        ),
        tr(
          lapply(colnames(table_data)[2:5], th)
        )
      )
    ))
    
    output$table <- renderReactable({
      reactable(table_data,
        columnGroups = list(
          colGroup(name =  "Quantités de TDR (historique)", columns = colnames(table_data)[2:3]),
          colGroup(name = predict_header, columns = colnames(table_data)[4:5])
        ),
        defaultPageSize = 15 #number of CSBS
      )
    })
    
  })
}

stock_table_demo <- function(){
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
    mod_stock_table_ui("act1")
  )
  server <- function(input, output, session){
    
    mod_stock_table_server("act1")
  }
  shinyApp(ui, server)
}

stock_table_demo()