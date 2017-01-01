library(tidyverse)
library(purrr)

Sys.setenv(JAVA_HOME = "C:/Program Files/Java/jdk1.7.0_79")


ghit::install_github(c("ropensci/tabulizerjars", "ropensci/tabulizer"), INSTALL_opts = "--no-multiarch")


library(tabulizer)

download.file("http://www.smallarmssurvey.org/fileadmin/docs/A-Yearbook/2007/en/Small-Arms-Survey-2007-Chapter-02-annexe-4-EN.pdf",
              destfile = "raw_data/Small-Arms-Survey-2007-Ch2.pdf", mode = "wb")


sas <- extract_tables("raw_data/Small-Arms-Survey-2007-Ch2.pdf")
str(sas)

dim(sas[[1]])
dim(sas[[2]])
dim(sas[[3]])
dim(sas[[4]])

sas[[1]][1,]
sas[[2]][1,]

mung <- function(x){
  colnames(x) <- str_trim(gsub("\r", "", x[1, ]))
  return(x[-1, ])
}
sas2 <- lapply(sas, mung)

sas_df <- as.data.frame(do.call("rbind", sas2)) %>%
  as.data.frame(stringsAsFactors  = FALSE) %>%
  filter(Country != "") %>%
  map_df(as.character) %>%
  gather(variable, value, -Country) %>%
  mutate(value = gsub("'", "", value)) %>%
  mutate(value = as.numeric(value)) %>%
  spread(variable, value) %>%
  arrange(`Rank by rate of ownership`)

sas_df
summary(sas_df)
View(sas_df)
