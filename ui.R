ui = dashboardPage(
    dashboardHeader(title = "MSstatsTracker: tracking MSstats Ecosystem usage"),
    dashboardSidebar(disable = TRUE),
    dashboardBody(
        column(6,
               fluidRow(box(
                   title = "Controls",
                   selectInput("package", "Select package",
                               choices = pkgs,
                               selected = "MSstats"),
                   dateRangeInput("date", "Date range",
                                  start = min(all_packages$date),
                                  end = max(all_packages$date),
                                  min = min(all_packages$date),
                                  max = max(all_packages$date))
               )),
               fluidRow(box(title = "Bioconductor downloads",
                            DT::DTOutput("raw_downloads")))
        ),
        column(6,
               fluidRow(box(title = "Summary for the selected period",
                            DT::DTOutput("summary_output"))),
               fluidRow(column(6,
                               box(selectInput("plot_type", "Plot",
                                               choices = c("number of downloads" = "downloads",
                                                           "number of distinct IPs" = "distinctIPs")),
                                   checkboxInput("smooth", "Add smoothed line",
                                                 value = FALSE)),
                               box(selectInput("plot_geom", "Type",
                                               choices = c("scatter" = "point",
                                                           "bar plot" = "bar"))))),
               fluidRow(box(plotOutput("time_plot"))))
    ),
    skin = "purple"
)
