mod_interventions_ui <- function(id){
  
  ns <- NS(id)
  fluidPage(
    fluidRow(id = "customBox",
             h4("Selectionnez l'age et le type de cas pour les deux scenarios:"),
             column(3,
                    selectInput(ns("age"), "Age", choices = c("<5 Ans" = "case_u5",
                                                          "5+ Ans" = "case_adult"),
                                selected = "case_u5")
             ), #column
             column(3,
                    selectInput(ns("case_type"), "Type de cas:", choices = c("Simple" = "newC", "Grave" = "newG"),
                                selected = "newC")
             ) #column
    ), #fluidRow
    fluidRow(id = "customBox",
             column(12, h4("Scenario 1:")),
             column(2,
                    selectInput(ns("tgt1"), "Methode de Ciblage", choices = c("Égal" = "none",
                                                                          "Proche aux CSBs" = "nearCSB",
                                                                          "Loin de CSBs" = "farCSB",
                                                                          "Incidence Historique" = "incidence",
                                                                          "Connectivité" = "centrality"),
                                selected = "none"),
                    checkboxGroupInput(ns("int1"), "Intervention",
                                       choices = c("Moustiquaires (MID)" = "llin", 
                                                   "Pulverisation à Domicile (PAD)" = "irs",
                                                   "Renforcement de Système de Santé (RSS)" = "propT")),
                    selectInput(ns("cov1"), "Couverture", choices = c("Bas" = "low",
                                                                  "Haut" = "high"),
                                selected = "low")),
             column(5,
                    leafletOutput(ns("map1"))),
             column(5,
                    plotOutput(ns("plot1")))
    ), #fluidRow
    fluidRow(id = "customBox",
             column(12, h4("Scenario 2:")),
             column(2,
                    selectInput(ns("tgt2"), "Methode de Ciblage", choices = c("Égal" = "none",
                                                                          "Proche aux CSBs" = "nearCSB",
                                                                          "Loin de CSBs" = "farCSB",
                                                                          "Incidence Historique" = "incidence",
                                                                          "Connectivité" = "centrality"),
                                selected = "none"),
                    checkboxGroupInput(ns("int2"), "Intervention",
                                       choices = c("Moustiquaires (MID)" = "llin", 
                                                   "Pulverisation à Domicile (PAD)" = "irs",
                                                   "Renforcement de Système de Santé (RSS)" = "propT")),
                    selectInput(ns("cov2"), "Couverture", choices = c("Bas" = "low",
                                                                  "Haut" = "high"),
                                selected = "low")),
             column(5,
                    leafletOutput(ns("map2"))),
             column(5,
                    plotOutput(ns("plot2")))
    ) #fluidRow
  ) #fluidPage
  
}

mod_interventions_server <- function(id){
  moduleServer(id, function(input,output, session){
    ns <- session$ns
    
    fkt_poly <- sf::st_read("data/for-app/interventions/ifd_fokontany_prep.gpkg") 
    
    selected_patch1 <- reactiveVal(FALSE)
    selected_patch2 <- reactiveVal(FALSE)
    
    observeEvent(input$map1_shape_click, {
      selected_patch1(input$map1_shape_click$id)
    })
    observeEvent(input$map2_shape_click, {
      selected_patch2(input$map2_shape_click$id)
    })
    
    # ---- read in intervention input -----
    
    format_interventions <- function(this_int){
      if(is.null(this_int) || length(this_int)==0){
        return("none")
      } else {
        all_ints <- c("propT", "llin", "irs")
        int_list <- all_ints[all_ints %in% this_int]
        if(length(int_list)==0) return("none")
        return(paste(int_list, collapse = "_"))
      }
    }
    
    this_int1 <- reactive({
      format_interventions(input$int1)
    })
    this_int2 <- reactive({
      format_interventions(input$int2)
    })
    
    df_age_case <- reactive({
      qs2::qs_read(paste0(paste("data/for-app/interventions/data", input$age, input$case_type, sep = "_"), ".qs"))
    })
    
    # ------ subset data ------
    #subset according to targeting method and coverage
    get_subset <- function(chosen_int_list, chosen_tgt, chosen_cov, select_df_age_case = df_age_case()){
      if(chosen_int_list == "none"){
        return(filter(df_age_case(),
                      target == "none",
                      coverage == "base"))
      } else {
        data_intermediate <- filter(df_age_case(),
                                    target == chosen_tgt,
                                    intervention == chosen_int_list,
                                    coverage == chosen_cov)
        return(data_intermediate)
      }
    }
    subset1 <- reactive({
      get_subset(this_int1(), input$tgt1, input$cov1)
    })
    
    subset2 <- reactive({
      get_subset(this_int2(), input$tgt2, input$cov2)
    })
    
    #---- annual averages for maps ---------#
    # Average cases per patch for map
    avg_cases <- function(data) {
      data |>
        summarise(avg_cases = round(mean(cases)*12,1), .by = "comm_fkt") |>
        left_join(fkt_poly, by = "comm_fkt") |>
        st_as_sf()
    }
    
    map_data1 <- reactive({
      avg_cases(subset1())
    })
    map_data2 <- reactive({
      avg_cases(subset2())
    })

    
    #----- set up map --------
    mapPal <- reactive({
      max_val <- max(c(map_data2()$avg_cases, map_data1()$avg_cases), na.rm = TRUE)
      if(is.na(max_val) | max_val == -Inf | max_val == Inf) {
        if(input$case_type == "newC"){
          max_val <- 500
        } else if(input$case_type == "newG"){
          max_val <- 15
        }
      }
      colorNumeric(palette = "plasma",
                   domain = c(0,max_val))
    })
    
    create_map <- function(this_map_data){
      label_text <- lapply(paste0(this_map_data$comm_fkt, "<br>", 
                                  "Cas Annuel Moyenne: ", this_map_data$avg_cases),
                           htmltools::HTML)
      this_map <- leaflet(this_map_data) %>%
        addTiles() %>%
        addPolygons(
          fillColor = ~mapPal()(avg_cases),
          color = "black", weight = 1, opacity = 1,
          fillOpacity = 0.7,
          label = label_text,
          layerId = ~comm_fkt) %>%
        addLegend(pal = mapPal(), values = ~avg_cases, position = "bottomleft",
                  title = "Cas Annuel Moyenne", group = "Affiche Legend") %>%
        addLayersControl(overlayGroups = c("Affiche Legend"),
                         options = layersControlOptions(collapsed = FALSE),
                         position = "bottomright")
      
      return(this_map)
    }
    

    # Render maps
    output$map1 <- renderLeaflet({
      create_map(map_data1())
    })
    
    output$map2 <- renderLeaflet({
      create_map(map_data2())
    })
    
    #---- time series plots ----------
    
    intervention_labels <- c("none" = "Pas d'intervention",
                             "llin" = "MID",
                             "irs" = "PAD",
                             "propT" = "RSS",
                             "propT_llin" = "RSS & MID",
                             "propT_irs" = "RSS & PAD",
                             "llin_irs" = "MID & PAD",
                             "propT_llin_irs" = "RSS & MID & PAD")
    
    
    rename_lookup <- c(intervention = "irs",
                       intervention = "propT",
                       intervention = "llin",
                       intervention = "propT_llin",
                       intervention = "propT_irs",
                       intervention = "llin_irs",
                       intervention = "propT_llin_irs")
    
    create_plot <- function(data_subset, selected_patch){
      
      # validate(
      #   need(selected_patch,
      #        "Cliquez sur un fokontany sur la carte à gauche pour voir sa série temporelle.")
      # )
      
      # if(is.null(selected_patch)){
      #   return("Cliquez sur un fokontany sur la carte à gauche pour voir sa série temporelle.")
      # }
      
      plot_data <- bind_rows(data_subset,
                             filter(filter(df_age_case(),
                                           target == "none",
                                           coverage == "base",
                                           intervention == "none"))
      )|>
        distinct() |>
        filter(comm_fkt == selected_patch) |>
        mutate(intervention = factor(intervention,
                                     levels= c("none", "llin", "irs", "propT",
                                               "propT_llin","propT_irs", "llin_irs",
                                               "propT_llin_irs")))
      
      
      
      #estimate annual cases averted
      if(length(unique(plot_data$intervention)) == 1){
        case_averted <- 0
      } else {
        case_averted <- select(plot_data, date, cases, intervention) |>
          mutate(year = substr(date, 1,4)) |>
          filter(year %in% c(2017:2020)) |>
          summarise(cases = sum(cases),
                    .by = c("year", "intervention")) |>
          tidyr::pivot_wider(names_from = intervention, values_from = cases) |>
          rename(any_of(rename_lookup)) |>
          mutate(averted = pmax(none-intervention,0)) |>
          pull(averted) |>
          mean() |>
          round()
      }
      
      ts_plot <- plot_data |>
        ggplot(aes(x = date, y = cases)) +
        geom_line(aes(color = intervention, linewidth = intervention)) +
        scale_color_manual(values = c("gray10", "darkred"), name = "Intervention",
                           labels = intervention_labels) +
        scale_linetype_manual(values = c("solid", "dashed"),
                              labels = intervention_labels) +
        scale_linewidth_manual(values = c(1,1.5)) +
        #add nice labels for interventions
        theme_bw() +
        guides(linetype = 'none', linewidth = 'none') +
        xlab("Date") +
        ylab("Nombre de cas mensuelle") +
        ggtitle(paste("Fokontany:", selected_patch, "\nMoyenne Cas Annuel Evité:", case_averted))
      
      return(ts_plot)
    }
    
    output$plot1 <- renderPlot({
      validate(
        need(selected_patch1(),
             "Cliquez sur un fokontany sur la carte à gauche pour voir sa série temporelle.")
      )
      
      req(selected_patch1())
      
      create_plot(data_subset = subset1(),
                  selected_patch = selected_patch1())
    })
    
    output$plot2 <- renderPlot({
      validate(
        need(selected_patch2(),
             "Cliquez sur un fokontany sur la carte à gauche pour voir sa série temporelle.")
      )
      
      create_plot(data_subset = subset2(),
                  selected_patch = selected_patch2())
    })
  }) #end moduleServer
}

interventions_demo <- function(){
  # source("R/utils_interventions.R")
  
  library(shiny)
  library(bslib)
  library(dplyr)
  library(leaflet)
  library(sf)
  library(ggplot2)
  library(paletteer)
  library(qs2)
  
  ui <- fluidPage(
    titlePanel("Comparaison des Interventions Ciblés"),
  tags$style(HTML("
    #customBox {
        border: 3px solid gray;
    }
  ")),
  mod_interventions_ui("test1")
  )

  
  server <- function(input, output,session){
    mod_interventions_server("test1")
  }
  
  
  
  shinyApp(ui, server)
}

interventions_demo()