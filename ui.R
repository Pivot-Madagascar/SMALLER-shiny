#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
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

tagList(
  # Your application UI logic
  #newer font awesome version
  tags$style("@import url(https://use.fontawesome.com/releases/v6.4.0/css/all.css);"),
  fluidPage(
    dashboardPage(
     
      skin = "green",
      
      # HEADER -----------------------------------------
      header = dashboardHeader(
                               title = "SMALLER: Prédire le palu dans le district d'Ifanadiana",
                               titleWidth = 550,
                               tags$li(a(href = "https://sante.gov.mg",
                                         img(src = "msanp-logo.jpg",
                                             height = "30px"),
                                         style = "padding-top:10px; padding-bottom:10px;"),
                                       class = "dropdown"),
                               tags$li(a(href = "https://www.pivotworks.org",
                                         img(src = "pivot-logo.png",
                                             height = "30px"),
                                         style = "padding-top:10px; padding-bottom:10px;"),
                                       class = "dropdown"),
                               tags$li(a(href = "https://www.ird.fr/",
                                         img(src = "ird-logo.png",
                                             height = "30px"),
                                         style = "padding-top:10px; padding-bottom:10px;"),
                                       class = "dropdown")),
      
      # SIDEBAR -------------------------------------
      sidebar = dashboardSidebar(width = 250,
                                 sidebarMenu(
                                   menuItem("Palu en Bref", icon = icon("gauge", lib = 'font-awesome'),
                                            tabName = "flash_dash"),
                                   menuItem("Santé\nCommunautaire", icon = icon('people-roof', lib = "font-awesome"),
                                            menuSubItem("Taux aux Fokontany", tabName = "comm_time")),
                                   menuItem("Santé Primaire", icon = icon("hospital", lib = "font-awesome"),
                                            menuSubItem("Taux aux Communes", tabName = "commune_time"),
                                            menuSubItem("Ruptures du Stock", tabName = "stock_csb2")),
                                   menuItem("À propos", icon = icon("circle-info", lib = "font-awesome"),
                                            menuSubItem("L'application", tabName = "about"),
                                            menuSubItem("Le modèle", tabName = "model_info"))
                                 ) # end sidebarMenu
      ), #end dashboardSidebar
      
      # BODY -------------------------------------------------
      body = dashboardBody(
        #change background to white
        #eventually do in bslib
        tags$head(tags$style(HTML('
                  .content-wrapper {
                    background-color: #fff;
                  }
                '
        ))),
        tabItems(
          ## landing page with highlights ---------
          tabItem(tabName = "flash_dash",
                  fluidRow(
                    valueBox(value = "PREDICTONS JANVIER 2021",
                             color = "black",
                             subtitle = "",
                             width = 12),
                    #these will eventually need to update automatically every month
                    valueBox(value = 8000,
                             subtitle = "cas pour 100k",
                             color = "purple",
                             icon = icon("person-rays", lib = "font-awesome"),
                             width = 3),
                    valueBox(value = 15000,
                             subtitle = "cas totals prédit",
                             color = "aqua",
                             icon = icon("person-burst", lib = "font-awesome"),
                             width = 3),
                    valueBox(value = "+140%",
                             subtitle = "comparé à l'année passée",
                             color = "red",
                             icon = icon("chart-line", lib = "font-awesome"),
                             width = 3),
                    valueBox(value = "4 CSB",
                             subtitle = "au risque du rupture du stock",
                             color = "teal",
                             icon = icon("pills", lib = "font-awesome"),
                             width = 3)
                  ),
                  mod_landing_map_ui("land_map")
          ), #end landing page tab
          ## community health tab -------------
          tabItem(tabName = "comm_time",
                  #intro and instructions
                  fluidRow(box(status = "info",
                               title = "Séries Temporels au Niveau Communautaire",
                               includeMarkdown("assets/community-time.md"),
                               width = 12)),
                  #sante communautaire UI
                  mod_sante_comm_ui("comm1")),
          ## commune time series tab -----------
          tabItem(tabName = "commune_time",
                  fluidRow(box(status = "info",
                               title = "Séries Temporels au Niveau Commune",
                               includeMarkdown("assets/commune-time.md"),
                               width = 12)),
                  mod_sante_primaire_ui("commune")),
          
          ## stockout tab ------------------
          tabItem(tabName = "stock_csb2",
                  #intro and instruction
                  fluidRow(box(status = "info",
                               title = "Risque du Rupture du Stock aux CSBs",
                               includeMarkdown("assets/stock-act-csb2.md"),
                               width = 12)),
                  #bar chart of ACTs
                  mod_stock_act_ui("act1")),
          ## about the model page ------------------
          tabItem(tabName = 'about',
                  includeMarkdown("assets/home.md")
          ),
          tabItem(tabName = "model_info",
                  includeMarkdown("assets/model-info.md"))
        )
      ) #end dashboardBody
      
      
    ) #end  dashboardPage
  ) #end fluidPage
) #end tagList
