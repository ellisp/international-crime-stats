library(knitr)
library(rmarkdown)
library(caret)
library(boot)
library(viridis)
library(DT)
library(webshot)

# suicide and homicide data
source("grooming/download-small-arms-survey-2007.R") 
source("grooming/import-hdi.R")
source("grooming/import-oecd-suicide.R")
source("grooming/indicators2005.R") # 2005 combined indicators, for purpose of testing the small arms data


# OECD assault data


# Documentation of repository and datasets
knit("README.Rmd", output = "README.md")
render("doc/suicide.Rmd")

