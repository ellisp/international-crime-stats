library(tidyverse)
library(purrr)
library(tabulizer)


# Sys.setenv(JAVA_HOME = "C:/Program Files/Java/jdk1.7.0_79")
# ghit::install_github(c("ropensci/tabulizerjars", "ropensci/tabulizer"), INSTALL_opts = "--no-multiarch")


download.file("http://www.smallarmssurvey.org/fileadmin/docs/A-Yearbook/2007/en/Small-Arms-Survey-2007-Chapter-02-annexe-4-EN.pdf",
              destfile = "raw_data/Small-Arms-Survey-2007-Ch2.pdf", mode = "wb")


sas <- extract_tables("raw_data/Small-Arms-Survey-2007-Ch2.pdf")


mung <- function(x){
  colnames(x) <- str_trim(gsub("\r", "", x[1, ]))
  colnames(x) <- gsub("per100", "per 100", colnames(x))
  return(x[-1, ])
}
sas2 <- lapply(sas, mung)

sas_orig <- as.data.frame(do.call("rbind", sas2)) %>%
  as.data.frame(stringsAsFactors  = FALSE) %>%
  filter(Country != "") %>%
  map_df(as.character) %>%
  gather(variable, value, -Country) %>%
  mutate(value = gsub("'", "", value)) %>%
  mutate(value = as.numeric(value)) %>%
  spread(variable, value) %>%
  arrange(`Rank by rate of ownership`) 

  

sas_df2 <- sas_orig  %>%
  # fix typo for Egypt population
  # mutate(`Population, 2005` = ifelse(Country == "Egypt", `Population, 2005` * 100, `Population, 2005`)) %>%
  # aggregate up UKI
  mutate(Country = ifelse(Country %in% c("Northern Ireland", "England and Wales", "Scotland"),
                           "United Kingdom", Country)) %>%
  mutate(GNI = `GNI (2005$) per capita` * `Population, 2005`) %>%
  group_by(Country) %>%
  summarise(`DerivedAverageFirearms` = sum(`Average total all civilian firearms`) / sum(`Population, 2005`) * 100,
            `GNI (2005$) per capita` = sum(GNI) / sum(`Population, 2005`)) %>%
  left_join(sas_orig[ , c("Country", "Average firearms per 100 people")], by = "Country") %>%
  rename(OriginalAverageFirearms = `Average firearms per 100 people`)

ggplot(sas_df2, aes(x = `DerivedAverageFirearms`, y = `OriginalAverageFirearms`, label = Country)) +
  geom_text() +
  scale_x_log10(breaks = c(1, 10, 100)) +
  scale_y_log10(breaks = c(1, 10, 100)) +
  coord_equal()




sas_orig %>%
  mutate(DerivedAverage = round(`Average total all civilian firearms` / `Population, 2005` * 100, 1),
         out = DerivedAverage - `Average firearms per 100 people`,
         out_abs = abs(out),
         out_ratio = out_abs / DerivedAverage) %>%
  arrange(desc(out_ratio)) %>%
  select(Country, `Average firearms per 100 people`, DerivedAverage, `Average total all civilian firearms`, 
         `Population, 2005`) %>%
  write.csv("data/population-checks.csv", row.names = FALSE)




save(sas_df, file = "data/sas_df.rda")
