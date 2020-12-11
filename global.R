library(shiny)
library(shinydashboard)
library(DT)
library(data.table)
library(lubridate)
library(ggthemes)
library(ggplot2)
library(bioC.logs)
library(readr)

pkgs = c("MSstats", "MSstatsTMT", "MSstatsConvert",
         "MSstatsPTM", "MSstatsTMTPTM", "MSstatsQC",
         "MSstatsSampleSize", "Cardinal", "matter")
all_packages = bioC.logs::bioC_downloads(pkgs)
all_packages = rbindlist(lapply(1:length(pkgs),
                         function(x) {
                             all_packages[[x]]$package = pkgs[[x]]
                             all_packages[[x]]
                         }))
all_packages = as.data.table(all_packages)
all_packages = all_packages[Month != "all"]
all_packages$date = readr::parse_date(paste(all_packages$Year, all_packages$Month, "01", sep = "-"),
                                       format = "%Y-%b-%d", locale = locale("en"))
# all_packages
