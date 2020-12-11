library(shiny)
library(shinydashboard)
library(DT)
library(data.table)
library(lubridate)
library(ggthemes)
library(ggplot2)
library(bioC.logs)
library(readr)
library(stringr)
library(xml2)
library(rvest)

test = xml2::read_html("https://skyline.ms/skyts/home/software/Skyline/tools/details.view?name=MSstats")
test_body = rvest::html_node(test, "body")
external_downloads = as.numeric(stringr::str_match(xml2::xml_text(test_body), "Downloaded: ([0-9]+)")[, 2])


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
