# --------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE.txt in the project root for license information.
# --------------------------------------------------------------------------------------------

#' @title Run a summary of Key Metrics from the Standard Query data
#'
#' @description
#' Returns a heatmapped table by default, with options to return a table.
#'
#' @param data A Standard Query dataset in the form of a data frame.
#' @param hrvar HR Variable by which to split metrics. Accepts a character vector, e.g. "Organization"
#' @param mingroup Numeric value setting the privacy threshold / minimum group size. Defaults to 5.
#' @param metrics A character vector containing the variable names to calculate averages of.
#' @param return Character vector specifying what to return, defaults to "plot".
#' Valid inputs are "plot" and "table".
#' @param textsize A numeric value specifying the text size to show in the plot.
#'
#' @import dplyr
#' @import ggplot2
#' @import reshape2
#' @importFrom stats reorder
#'
#' @return
#' Returns a ggplot object by default, where 'plot' is passed in `return`.
#' When 'table' is passed, a summary table is returned as a data frame.
#'
#' @examples
#' keymetrics_scan(sq_data, hrvar = "LevelDesignation", return = "table")
#'
#' @export

keymetrics_scan <- function(data,
                            hrvar = "Organization",
                            mingroup = 5,
                            metrics = c("Workweek_span",
                                        "Collaboration_hours",
                                        "After_hours_collaboration_hours",
                                        "Meetings",
                                        "Meeting_hours",
                                        "After_hours_meeting_hours",
                                        "Low_quality_meeting_hours",
                                        "Meeting_hours_with_manager_1_on_1",
                                        "Meeting_hours_with_manager",
                                        "Emails_sent",
                                        "Email_hours",
                                        "After_hours_email_hours",
                                        "Generated_workload_email_hours",
                                        "Total_focus_hours",
                                        "Internal_network_size",
                                        "Networking_outside_organization",
                                        "External_network_size",
                                        "Networking_outside_company"),
                            return = "plot",
                            textsize = 2){

  myTable <-
    data %>%
    rename(group = !!sym(hrvar)) %>% # Rename HRvar to `group`
    group_by(group, PersonId) %>%
    summarise_at(vars(metrics), ~mean(., na.rm = TRUE)) %>%
    group_by(group) %>%
    summarise_at(vars(metrics), ~mean(., na.rm = TRUE)) %>%
    left_join(hrvar_count(data, hrvar = hrvar, return = "table") %>%
                rename(Employee_Count = "n"),
              by = c("group" = hrvar)) %>%
    filter(Employee_Count >= mingroup)  # Keep only groups above privacy threshold

  myTable %>%
    reshape2::melt(id.vars = "group") %>%
    reshape2::dcast(variable ~ group) -> myTable_wide

  myTable_long <- reshape2::melt(myTable, id.vars=c("group")) %>%
    mutate(variable = factor(variable)) %>%
    group_by(variable) %>%
    # Heatmap by row
    mutate(value_rescaled = value/mean(value)) %>%
    ungroup()

  # Underscore to space
  us_to_space <- function(x){
    gsub(pattern = "_", replacement = " ", x = x)
  }


  plot_object <-
    myTable_long %>%
    filter(variable != "Employee_Count") %>%
    ggplot(aes(x = group,
               y = stats::reorder(variable, desc(variable)))) +
    geom_tile(aes(fill = value_rescaled)) +
    geom_text(aes(label=round(value, 1)), size = textsize) +
    scale_fill_distiller(palette = "Blues",  direction = 1) +
    scale_x_discrete(position = "top") +
    scale_y_discrete(labels = us_to_space) +
    theme_light() +
    labs(title = "Key Workplace Analytics metrics",
         subtitle = paste("Weekly average by", camel_clean(hrvar)),
         y =" ",
         x =" ",
         caption = extract_date_range(data, return = "text")) +
    theme(axis.text.x = element_text(angle = 90, hjust = 0),
          plot.title = element_text(color="grey40", face="bold", size=20)) +
    guides(fill=FALSE)


  if(return == "table"){

    myTable_wide %>%
      as_tibble() %>%
      return()

  } else if(return == "plot"){

    return(plot_object)

  } else {

    stop("Please enter a valid input for `return`.")

  }

}
