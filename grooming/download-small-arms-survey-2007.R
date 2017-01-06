
if(!"Small-Arms-Survey-2007-Ch2.pdf" %in% list.files(path = "raw_data")){
download.file("http://www.smallarmssurvey.org/fileadmin/docs/A-Yearbook/2007/en/Small-Arms-Survey-2007-Chapter-02-annexe-4-EN.pdf",
              destfile = "raw_data/Small-Arms-Survey-2007-Ch2.pdf", mode = "wb")
}

sas <- extract_tables("raw_data/Small-Arms-Survey-2007-Ch2.pdf")


mung <- function(x){
  colnames(x) <- str_trim(gsub("\r", "", x[1, ]))
  colnames(x) <- gsub("per100", "per 100", colnames(x))
  return(x[-1, ])
}
sas2 <- lapply(sas, mung)

sas_orig <- as.data.frame(do.call("rbind", sas2)) %>%
  as.data.frame(stringsAsFactors  = FALSE) %>%
  dplyr::filter(Country != "") %>%
  map_df(as.character) %>%
  gather(variable, value, -Country) %>%
  mutate(value = gsub("'", "", value)) %>%
  mutate(value = as.numeric(value)) %>%
  spread(variable, value) %>%
  arrange(`Rank by rate of ownership`) 

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
  left_join(ISO3166, by = c("Country" = "Name"))



