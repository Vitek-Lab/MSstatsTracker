server <- function(input, output) {

    package_stats = reactive({
        all_packages[package == input$package,
                     .(package, date,
                       downloads = Nb_of_downloads,
                       distinctIPs = Nb_of_distinct_IPs)][
                           date >= input$date[1] & date <= input$date[2]
                           ]
    })

    output$raw_downloads = DT::renderDT({
        package_stats()
    }, extensions = 'Buttons',
    options = list(dom = 'tpB',
                   buttons = c('copy', 'csv', 'excel')))

    output$summary_output = DT::renderDT({
        out_dt = melt(package_stats(), id.vars = c("package", "date"),
                      variable.name = "typeDownloads", value.name = "numDownloads")
        out_dt = out_dt[numDownloads > 0,
                        .(min_d = min(numDownloads, na.rm = TRUE),
                          mean_d = mean(numDownloads, na.rm = TRUE),
                          median_d = round(median(numDownloads, na.rm = TRUE), 0),
                          max_d = max(numDownloads, na.rm = TRUE),
                          total = sum(numDownloads, na.rm = TRUE)),
                        by = c("typeDownloads")]
        out_dt = melt(out_dt, id.vars = "typeDownloads")
        out_dt$value = round(out_dt$value, 0)
        out_dt = dcast(out_dt, variable ~ typeDownloads)
        out_dt$variable = c("min", "mean", "median", "max", "sum")
        out_dt
    }, options = list(dom = "t"))

    output$time_plot = renderPlot({
        if (input$plot_geom == "point") {
            plot = ggplot(package_stats(),
                          aes_string(x = "date", y = input$plot_type)) +
                geom_point(alpha = 0.7) +
                theme_tufte() +
                xlab("date") +
                ylab("number of downloads")
            if (input$smooth) {
                plot = plot +
                    geom_smooth(size = 1.2, se = FALSE)
            }
        } else {
            input = melt(package_stats(), id.vars = c("package", "date"),
                         variable.name = "typeDownloads", value.name = "numDownloads")
            input$typeDownloads = ifelse(input$typeDownloads == "downloads",
                                         "all downloads", "distinct IPs")
            plot = ggplot(input, aes(x = date, y = numDownloads, fill = typeDownloads)) +
                geom_bar(position = "dodge", stat = "identity") +
                theme_tufte() +
                theme(legend.position = "bottom") +
                guides(fill = guide_legend(title = "")) +
                xlab("date") +
                ylab("number of downloads")
        }
        plot
    })

    output$totals = DT::renderDT({
        output_df = all_packages
        output_df$IsMSstats = ifelse(!(output_df$package %in% c("Cardinal", "matter")),
                                 "MSstats ecosystem", "Cardinal + matter")
        output_df = output_df[Nb_of_downloads > 0 & date >= input$date[1] & date <= input$date[2],
                       .(TotalDownloads = sum(Nb_of_downloads, na.rm = TRUE),
                         TotalDistinct = sum(Nb_of_distinct_IPs, na.rm = TRUE)),
                       by = "IsMSstats"]
        output_df = rbind(output_df, data.table(IsMSstats = "MSstats Skyline external (all time)",
                                          TotalDownloads = external_downloads,
                                          TotalDistinct = NA))
        colnames(output_df) = c("Packages", colnames(output_df)[2:3])
        output_df
    }, options = list(dom = "t"))
}
