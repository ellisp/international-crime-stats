library(knitr)
library(rmarkdown)
library(caret)
library(boot)
library(viridis)
library(DT)
library(webshot) # used for making png versions of DT::datatable, for use in markdown
library(ISOcodes)
library(rsdmx)    # for importing OECD data
library(magrittr) # for %$%
library(grid)
library(gridExtra)
library(Cairo)
library(WHO)
library(WDI)
library(tabulizer)
# tabulizer is non-trivial to install.  Requires the Java Development Kit.
# see https://github.com/ropensci/tabulizer 
# Depending on your JDK install, you may need to adapt the following depending on where the JDK is:
# Sys.setenv(JAVA_HOME = "C:/Program Files/Java/jdk1.7.0_79")
# ghit::install_github(c("ropensci/tabulizerjars", "ropensci/tabulizer"), INSTALL_opts = "--no-multiarch")

#================Data imports====================
# Country code concordance.  Note that this is one to many for name to Alpha_x.
ISO3166 <- read_csv("data/conc_iso3166.csv", na = "", col_types = "ccc") # na.strings important otherwise Namibia is an NA!
data("ISO_3166_1") # for one to one version when Alpha_x to name needed one to one

# suicide and homicide data
source("grooming/download-small-arms-survey-2007.R") 
source("grooming/import-hdi.R")
source("grooming/import-oecd-suicide.R")
source("grooming/indicators2005.R") # 2005 combined indicators, for purpose of testing the small arms data
source("grooming/create-comparison-dataset-sas.R")

# OECD assault data
source("grooming/import-oecd-assault-deaths.R")
#============Analysis==================

source("analysis/explore-oecd-assaults-data.R")

#==============Documentation of repository and datasets===========
# this should maybe be automated so all .Rmd files and so on are done, rather than listing them individually

knit("README.Rmd", output = "README.md")

# Make HTML versions for local use:
docs <- list.files("doc", "Rmd$", full.name = TRUE)
analysis <- list.files("analysis", "Rmd$", full.name = TRUE)
lapply(docs, render)
lapply(analysis, render)

# Make Markdown versions for use in the Wiki.  Note the Wiki needs to be independently cloned.
for(x in docs){
  outfile <- gsub("^doc/", "../international-crime-stats.wiki/", x)
  outfile <- gsub(".Rmd$", ".md", outfile)
  knit(x, output = outfile)
}

# copy images needed by the markdown versions over to the Wiki repository:
system("cp figure/*.* ../international-crime-stats.wiki/figure")
