library(shiny)
library(shinydashboard)
library(leaflet)
library(tidyverse)
library(xml2)

lastUpdate <- "2017-05-25"
htmlArticle <- read_html("./data/List_of_school_shootings_in_the_United_States.html")

# Load Data -----------------------------------------------------------------------------------
set.seed(234)
dt <- readRDS("./data/cleaned.RDS") %>% 
  # filter colonial data point
  filter(year > 1800)

# Colors
myFillColors <- c(Deaths = "#e34a33", Injuries = "#fdbb84")
testColors <- colorFactor(palette = c(Deaths = "#e34a33", Injuries = "#fdbb84"), 
                          domain = c("Incidents with deaths", "No deaths"))


