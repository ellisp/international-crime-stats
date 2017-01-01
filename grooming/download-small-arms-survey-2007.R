library(tidyverse)
library(purrr)
library(tabulizer)
library(ISOcodes)



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

# This was a one off, then hand-edited, to get a concordance of Small Arms Survey
# "country" names to ISO codes:
# data(ISO_3166_1)  
# missing <- data.frame(Name = sas_orig$Country[!sas_orig$Country %in% ISO_3166_1$Name])
# ISO3166 <- plyr::rbind.fill(missing, ISO_3166_1)
# write.csv(ISO3166, "data/conc_iso3166.csv", row.names = FALSE)

ISO3166 <- read_csv("data/conc_iso3166.csv", na = "") # na.strings important otherwise Namibia is an NA!

sas_df2 <- sas_orig  %>%
  # aggregate up UKI
  mutate(Country = ifelse(Country %in% c("Northern Ireland", "England & Wales", "Scotland"),
                           "United Kingdom", Country)) %>%
  mutate(GNI = `GNI (2005$) per capita` * `Population, 2005`) %>%
  group_by(Country) %>%
  summarise(`DerivedAverageFirearms` = sum(`Average total all civilian firearms`) / sum(`Population, 2005`) * 100,
            `GNI (2005$) per capita` = sum(GNI) / sum(`Population, 2005`),
            OriginalPopulation2005 = sum(`Population, 2005`),
            `Average total all civilian firearms` = sum(`Average total all civilian firearms`)) %>%
  left_join(sas_orig[ , c("Country", "Average firearms per 100 people")], by = "Country") %>%
  rename(OriginalAverageFirearms = `Average firearms per 100 people`) %>%
  mutate(BestGuessFirearmsRate = ifelse(Country == "United Kingdom", DerivedAverageFirearms, OriginalAverageFirearms)) %>%
  left_join(ISO3166, by = c("Country" = "Name"))


ggplot(sas_df2, aes(y = `DerivedAverageFirearms`, x = `OriginalAverageFirearms`, label = Country)) +
  geom_abline(slope = 1, colour = "white") +
  geom_text(size = 3) +
  scale_x_log10(breaks = c(1, 10, 100)) +
  scale_y_log10(breaks = c(1, 10, 100)) +
  coord_equal()



# create a CSV for inspecting by hand to see which ones probably wrong
# sas_orig %>%
#   mutate(DerivedAverage = round(`Average total all civilian firearms` / `Population, 2005` * 100, 1),
#          out = DerivedAverage - `Average firearms per 100 people`,
#          out_abs = abs(out),
#          out_ratio = out_abs / DerivedAverage) %>%
#   arrange(desc(out_ratio)) %>%
#   select(Country, `Average firearms per 100 people`, DerivedAverage, `Average total all civilian firearms`, 
#          `Population, 2005`) %>%
#   write.csv("data/population-checks.csv", row.names = FALSE)


# sas_orig

save(sas_df2, file = "data/sas_df.rda")
