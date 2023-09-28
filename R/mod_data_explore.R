#' data Exploration UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom tidyr separate
#' @importFrom DT dataTableOutput formatStyle formatRound

mod_data_explore_ui <- function(id){
  ns <- NS(id)
  
  fluidRow(
    column(3,
           #commune selection
           selectInput(ns("commune"), label = "Choix de commune(s):",
                       choices = c("Tous" = "", "Ambiabe", "Ambohimanga du Sud", "Ambohimiera", "Ampasinambo",
                                   "Analampasina", "Androrangavola", "Antaretra", "Antsindra",
                                   "Fasintsara", "Ifanadiana", "Kelilalina", "Maroharatra",
                                   "Marotoko", 'Ranomafana', "Tsaratanana"),
                       multiple = TRUE)
           ),
    column(3,
           #fokontany selection (this gets updated based on commune)
           selectInput(inputId = ns("fokontany"), label = "Choix de fokontany:",
                       choices = c("Tous"=""), multiple = TRUE)
           ),
    column(3,
           #choose an indicator
           selectInput(ns("indicator"), "Choix d'indicateur:",
                       choices = c("Cas" = "case", "Incidence" = "inc"), selected = "incidence")
           ),
    column(12,
           dataTableOutput(ns("dt_table"))
           ),
    column(5,),
    column(3,
           shiny::downloadButton(
                    outputId = ns("download_button"),
                    label = "Télécharger le tableau.")
           )
  ) #fluidRow
}


mod_data_explore_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    #full table of data
    table_data <- readRDS("data/dynamic/inc-fokontany.rds") |>
      select(-pop, -hist_year, -season, -month_lab) |>
      #adjust error in cases
      mutate(case_med = ifelse(!is.na(case_true), case_true, case_med)) |>
      pivot_longer(-c(comm_fkt, date), names_to = "metric", values_to = "count") |>
      mutate(count= floor(count)) |>
      tidyr::separate(metric, into = c("indicator", "measure"), sep = "_") |>
      filter(measure != "true") |>
      mutate(measure = case_when(
        measure == "lowCI" ~ "Estimation Minimale",
        measure == "med" ~ "Estimation Moyenne",
        measure == "uppCI" ~ "Estimation Maximale"
      )) |>
      tidyr::separate(comm_fkt, into = c("commune", "fokontany"), sep = "_") |>
      pivot_wider(names_from = measure, values_from = count) |>
      rename(Commune = commune, Fokontany = fokontany, Date = date)
      
    #track selected inputs
    # for choosing a fokontany
    observe({
      fokontany_names <- if(is.null(input$commune)) character(0) else {
        filter(table_data, Commune %in% toupper(input$commune)) |>
          pull(Fokontany) |>
          unique() |>
          sort() |>
          stringr::str_to_title()
      }
      print(fokontany_names)
      
      stillSelected <- isolate(input$fokontany[input$fokontany %in% fokontany_names])
      print(stillSelected)
      updateSelectizeInput(session,
                           inputId = "fokontany", 
                           choices = fokontany_names,
                           selected = stillSelected, server = TRUE)
    }) #end observe
    
    this_df <- reactive({
      #filter based on inputs
      table_data |>
        filter(
          is.null(input$commune) | Commune %in% toupper(input$commune),
          is.null(input$indicator) | indicator %in% input$indicator,
          is.null(input$fokontany) | Fokontany %in% toupper(input$fokontany)
        ) |>
        select(-indicator)
    })
    
    output$dt_table <- DT::renderDataTable({
      create_dt(this_df())
      })
    
      output$download_button <- shiny::downloadHandler(
        filename = function(){
          paste0(input$indicator, ".csv")
        },
        content = function(file_path)
        {
          write_file(file_path = file_path, data = this_df())
        }
      )
    
  }) #end moduleServer
}

data_explore_demo <- function(){
  #source functions
  source("R/utils_sante_comm.R")
  #declare packages
  library(shiny)
  library(dplyr)
  library(lubridate)
  library(stringr)
  library(DT)
  
  ui <- fluidPage(
    mod_data_explore_ui("test1")
  )
  
  server <- function(input,output,session){
    mod_data_explore_server("test1")
    
  }
  
  shinyApp(ui, server)
  
}

data_explore_demo()
