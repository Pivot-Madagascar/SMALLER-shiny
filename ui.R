#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#flash dash from dynamic output
flash_list <- readRDS("data/dynamic/flash-alerts.rds")
#set new end date [should be provided as an object from backend]
new_end <- readRDS("data/dynamic/new_end.rds")
# new_end <- as.Date("2024-05-01")

#adjust for missing data
if(is.na(flash_list$flash_inc)){
  flash_list$flash_inc <- "--"
}

if(is.na(flash_list$compare_ratio)){
  flash_list$compare_ratio <- "--"
}

#update year comparison
if(is.numeric(flash_list$compare_ratio)){
  if(flash_list$compare_ratio>=100){
    year_comparison <- paste0("+", flash_list$compare_ratio-100, "%")
  } else {
    year_comparison <- paste0("-", 100-flash_list$compare_ratio, "%")
  }
} else {
  year_comparison <- "--"
}


chc_months_avail <- seq.Date((new_end %m+% months(1)),
                                          (new_end %m+% months(3)), 
                                          by = "month")
chc_months_avail <- paste(month.abb[month(chc_months_avail)], year(chc_months_avail))


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
require(reactable)

tagList(
  # Your application UI logic
  #newer font awesome version
  tags$style("@import url(https://use.fontawesome.com/releases/v6.4.0/css/all.css);"),
  fluidPage(
    dashboardPage(title = "SMALLER Dashboard",
     
      skin = "green",
      
      # HEADER -----------------------------------------
      header = dashboardHeader(
                               title = "SMALLER: Prédire le paludisme dans le district d'Ifanadiana",
                               titleWidth = 600,
                               tags$li(a(href = "http://www.sante.gov.mg/ministere-sante-publique/",
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
                                 minified = FALSE,
                                 sidebarMenu(
                                   # style = "position: fixed;",
                                   menuItem("Palu en Bref", icon = icon("gauge", lib = 'font-awesome'),
                                            tabName = "flash_dash"),
                                   menuItem("Tableau des Données", icon = icon("table", lib = "font-awesome"),
                                            tabName = "fokontany_table"),
                                   menuItem("Besoins Communautaires", tabName = "chc_cases",
                                            icon = icon("people-roof", lib = "font-awesome")),
                                   menuItem("Besoins aux CSB", tabName = "stock_csb2",
                                            icon = icon("hospital", lib = "font-awesome")),
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
                  };
                  .small-box {
                  height: 80px
                  }
                '
        ))),
        tabItems(
          ## landing page with highlights ---------
          tabItem(tabName = "flash_dash",
                  fluidRow(
                    h1(flash_list$header, style = "font-size:38px; color:#008d4c; font-variant:small-caps; text-align:end; font-family: sans-serif;"),
                    hr(),
                  ),
                  fluidRow(
                    column(width = 3, 
                            fluidRow(
                              valueBox(value =  flash_list$flash_inc,
                                       subtitle = "cas pour 100k",
                                       color = "purple",
                                       icon = icon("person-rays", lib = "font-awesome"),
                                       width = 12)
                            ),
                            fluidRow(
                              valueBox(value = flash_list$flash_case,
                                       subtitle = "cas totals prédit",
                                       color = "aqua",
                                       icon = icon("person-burst", lib = "font-awesome"),
                                       width = 12)
                            ),
                            fluidRow(
                              valueBox(value = year_comparison,
                                       subtitle = "comparé à l'année passée",
                                       color = "red",
                                       icon = icon("chart-line", lib = "font-awesome"),
                                       width = 12)
                            ),
                            fluidRow(
                              valueBox(value = paste(flash_list$stock_alert_numCSB, "CSB"),
                                       subtitle = "voient plus de cas que l'année dernière",
                                       color = "teal",
                                       icon = icon("pills", lib = "font-awesome"),
                                       width = 12)
                            ),
                           fluidRow(
                             #add info to fill out rest of screen
                           )
                    ), #end column 1
          ## ----landing page map ------------------#########
                    column(width = 9,
          
                           mod_landing_map_ui("land_map"),
                           mod_map_panel_ui("land_map")
                           )
                  ) #end fluidRow
                   
                  
                  

                  #   absolutePanel(class = "panel panel-default", fixed = TRUE, draggable = TRUE, 
                  #               top = "auto", left = "auto", right = 40, bottom = 60,
                  #               width = 300, height = "auto",
                  #               
                  #               h2("Select a fokontany"))
                  # )
          ), #end landing page tab
          ## Data Table Tab ---------------------
          tabItem(tabName = "fokontany_table",
                  mod_tableau_donnees_ui("fokontany_table")),
          ## CHC Case Tab ------------------------
          tabItem(tabName = "chc_cases",
                  #intro and instruction
                  fluidRow(box(status = "info",
                               title = "Nombre de cas prévus restant au niveau communautaire",
                               includeMarkdown("assets/community-cases.md"),
                               collapsible = TRUE,
                               collapsed = FALSE,
                               width = 12)),
                  mod_chc_besoins_ui("chc_cases")),
          
          ## stockout tab ------------------
          tabItem(tabName = "stock_csb2",
                  #intro and instruction
                  fluidRow(box(status = "info",
                               title = "Besoins des ACTs prévus aux CSB",
                               includeMarkdown("assets/stock-act-csb2.md"),
                               collapsible = TRUE,
                               collapsed = TRUE,
                               width = 12)),
                  #bar chart of ACTs
                  mod_besoins_csb_ui("act_table")),
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
