#' UI function for table of cases at CHCs
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom shinyWidgets pickerInput
#' @import plotly DT
#' 
mod_chc_besoins_ui <- function(id){
ns <- NS(id)

new_end <- readRDS("data/dynamic/new_end.rds")
chc_months_avail <- as.character(seq.Date((new_end %m+% months(1)),
                                          (new_end %m+% months(3)), 
                                          by = "month"))
chc_months_avail <- paste(month.abb[month(chc_months_avail)], year(chc_months_avail))

fluidRow(
  column(3,
         #commune selection
         selectInput(ns("commune"), label = "Choix du commune:",
                     choices = c("Tous" = "", "Ambiabe", "Ambohimanga du Sud", "Ambohimiera", "Ampasinambo",
                                 "Analampasina", "Androrangavola", "Antaretra", "Antsindra",
                                 "Fasintsara", "Ifanadiana", "Kelilalina", "Maroharatra",
                                 "Marotoko", 'Ranomafana', "Tsaratanana"),
                     multiple = FALSE)
  ),
  column(3,
         #fokontany selection (this gets updated based on commune)
         selectInput(inputId = ns("fokontany"), label = "Choix du fokontany:",
                     choices = c("Tous"=""), multiple = TRUE)
  ),
  column(3,
         selectInput(inputId = ns("select_month"), label = "Choix du mois:",
                     choices = chc_months_avail, multiple = FALSE)
  ),
  column(12,
         plotly::plotlyOutput(ns("comm_barplot"))
         ),
  column(12,
         dataTableOutput(ns("table"))
  ),
  column(5,),
  column(3,
         shiny::downloadButton(
           outputId = ns("download_button"),
           label = "Télécharger le tableau.")
  )
) #fluidRow
}

mod_chc_besoins_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    #full table of table (read once)
    table_raw <- read.csv("data/dynamic/CHW_cases.csv") %>%
      dplyr::mutate(date = as.Date(date)) %>%
      dplyr::mutate(month_year = paste(month.abb[lubridate::month(date)], 
                                lubridate::year(date), sep = " ")) %>%
      select(-date) %>%
      tidyr::separate(comm_fkt, into = c("Commune", "Fokontany"), sep = "_") %>%
      select(Commune, Fokontany, Mois = month_year, "Cas Total" = mal_case_total, 
            "Nombre de cas prévus pour être traités au CSB" = mal_case_csb, 
             "Nombre de cas prévus restant au niveau communautaire" = mal_case_chc)

    
    #track selected inputs ------------
    
    # for choosing a fokontany
    observe({
      fokontany_names <- if(is.null(input$commune)) character(0) else {
        filter(table_raw, Commune %in% toupper(input$commune)) %>%
          pull(Fokontany) %>%
          unique() %>%
          sort() %>%
          stringr::str_to_title()
      }
      # print(fokontany_names)
      
      stillSelected <- isolate(input$fokontany[input$fokontany %in% fokontany_names])
      # print(stillSelected)
      updateSelectizeInput(session,
                           inputId = "fokontany", 
                           choices = fokontany_names,
                           selected = stillSelected, server = TRUE)
    }) #end observe

    
    # reactive data table -----------------
    
    table_react <- reactive({
      #filter based on inputs
      table_raw %>%
        filter(
          is.null(input$commune) | Commune %in% toupper(input$commune),
          is.null(input$fokontany) | Fokontany %in% toupper(input$fokontany),
          Mois == input$select_month
        ) 
    })
    
    output$table <- DT::renderDataTable({
     create_dt_chc(table_react()) 
    })
    
    output$comm_barplot <- renderPlotly({
      validate(need(input$commune, 
                    "Choissesez un commune pour visualizer 
                    les cas par fokontany."))
      create_community_barplot(table_raw = table_raw,
                                                    monthSelect = input$select_month,
                                                    fokontanySelect = input$fokontany,
                                                    communeSelect = input$commune)
      })
    
    output$download_button <- shiny::downloadHandler(
      filename = function(){
        paste0(input$month, " Malaria CHC Cases.csv")
      },
      content = function(file_path)
      {
        write_file(file_path = file_path, data = table_react())
      }
    )
    
    # reactive bar plot ------------- ##
    
  }) #end moduleServer
}

chc_besoins_demo <- function(){
  #source functions
  source("R/utils_sante_comm.R")
  source("R/utils_chc_table.R")
  #declare packages
  library(shiny)
  library(dplyr)
  library(lubridate)
  library(stringr)
  library(DT)

  ui <- fluidPage(
    mod_chc_besoins_ui("test1")
  )
  
  server <- function(input,output,session){
    mod_chc_besoins_server("test1")
    
  }
  
  shinyApp(ui, server)
  
}

# chc_besoins_demo()
