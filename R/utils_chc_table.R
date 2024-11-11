#function to create a barplot of cases split by CSB and community level

create_community_barplot <- function(table_raw, communeSelect, 
                                     fokontanySelect,
                                     monthSelect){
  
  inspect <- FALSE
  if(inspect){
    plotly_data <- read.csv("data/dynamic/CHW_cases.csv") %>%
      dplyr::mutate(date = as.Date(date)) %>%
      dplyr::mutate(month_year = paste(month.abb[lubridate::month(date)], 
                                lubridate::year(date), sep = " ")) %>%
      select(-date) %>%
      tidyr::separate(comm_fkt, into = c("Commune", "Fokontany"), sep = "_") %>%
      select(Commune, Fokontany, Mois = month_year, "Cas Total" = mal_case_total, 
             "Nombre de cas prévus pour être traités au CSB" = mal_case_csb, 
             "Nombre de cas prévus restant au niveau communautaire" = mal_case_chc) %>%
      #fake a selection
      filter(Mois == Mois[1]) %>%
      filter(Commune == sample(Commune,1)) %>%
      tidyr::pivot_longer(c("Nombre de cas prévus pour être traités au CSB", 
                            "Nombre de cas prévus restant au niveau communautaire"),
                          names_to = "variable",
                          values_to = "value")
  }
  
  plotly_data <- table_raw %>%
    filter(is.null(communeSelect) | Commune %in% toupper(communeSelect),
           is.null(fokontanySelect) | Fokontany %in% toupper(fokontanySelect),
           Mois == monthSelect) %>%
    tidyr::pivot_longer(c("Nombre de cas prévus pour être traités au CSB", 
                          "Nombre de cas prévus restant au niveau communautaire"),
                        names_to = "variable",
                        values_to = "value")
  
  plot_ly(plotly_data, y = ~Fokontany, x = ~value,
          name = ~variable, type = "bar", text = ~value) %>%
    layout(barmode = 'stack',
           xaxis = list(title = "Nombre de cas"),
           yaxis = list(title = ""),
           title = list(text = paste(str_to_title(plotly_data$Commune[1]), 
                         "-", plotly_data$Mois[1])),
           legend = list(xanchor = "center",
                         x = 0.5,
                         y = -0.2,
                         orientation = "h")) %>%
    #remove buttons on top
    config(modeBarButtonsToRemove = c("zoom2d", "zoomIn2d", "zoomOut2d", "pan2d", 'autoScale2d', "resetScale2d"),
           displaylogo = FALSE)
  
  
}
