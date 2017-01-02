library(knitr)
library(rmarkdown)
library(caret)
library(boot)
library(viridis)
library(DT)
library(webshot)

#================Data imports====================
# Country code concordance
ISO3166 <- read_csv("data/conc_iso3166.csv", na = "", col_types = "ccc") # na.strings important otherwise Namibia is an NA!


# suicide and homicide data
source("grooming/download-small-arms-survey-2007.R") 
source("grooming/import-hdi.R")
source("grooming/import-oecd-suicide.R")
source("grooming/indicators2005.R") # 2005 combined indicators, for purpose of testing the small arms data


# OECD assault data

#============Analysis==================


#==============Documentation of repository and datasets===========
knit("README.Rmd", output = "README.md")

# Make HTML versions for local use:
render("doc/suicide.Rmd")
render("doc/indicators2005.Rmd")
render("doc/hdi.Rmd")


# Make Markdown versions for use in the Wiki.  Note the Wiki needs to be independently cloned.
knit("doc/indicators2005.Rmd", output = "../international-crime-stats.wiki/indicators2005.md")
knit("doc/suicide.Rmd", output = "../international-crime-stats.wiki/suicide.md")
knit("doc/hdi.Rmd", output = "../international-crime-stats.wiki/HDI.md")
# copy images needed by the markdown versions over to the Wiki repository:
system("cp figure/*.* ../international-crime-stats.wiki/figure")
