#' plot_act_bar
#'
#' @description Creates a bar chart of past ACT use and predicted cases
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd
plot_act_bar <- function(plot_data){

  #to debug
  # plot_data <- readRDS("data/dynamic/stockout.rds")
  
  new_end <- readRDS("data/dynamic/new_end.rds")
  
  plot_data |>
    mutate(year = as.factor(year))
  
  missing_coords <- filter(plot_data, rdt_missing == "missing", metric == "sum_act") |>
    filter(year != year(new_end))

  ggplot(plot_data, aes(x = year, group = year)) +
    geom_col(aes(y = med, fill = fill_label), position = position_stack()) +
    # geom_errorbar(aes(ymin = lowCI, ymax = uppCI), width = 0) +
    geom_text(data = missing_coords, aes(x = year, y = med * 1.1), label = "NB") +
    facet_wrap(~CSB, scales = "free") +
    scale_fill_manual(values = c("darkred", "gray50", "black"), name = "") +
    theme(legend.position = "bottom") +
    xlab("") +
    ylab("Nombre de Cas") +
    ggtitle(paste0("Cas Reçu et Traité aux CSB2 (", format(new_end + months(1), "%b"), " - ", format(new_end + months(3), "%b"), ")")) +
    labs(caption = "NB: Manque de données de nombre total de cas pour cette année.")


}
