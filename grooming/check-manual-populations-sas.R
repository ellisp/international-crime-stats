# assumes existence of `combined` created by grooming/suicidie-homicide.R

library(openxlsx)
library(tidyverse)


popcheck <- read.xlsx("data/population-checks.xlsx") %>%
  rename(ManualCheckedPop2005 = checked.population.2005) %>%
  # remove unwanted:
  filter(!Country %in% c("scotland", "Transdniester", "England & Wales")) %>%
  mutate(Country = gsub("Madegascar", "Madagascar", Country)) %>%
  dplyr::select(Country, ManualCheckedPop2005)
  
combined %>%
  left_join(popcheck, by = c("CountrySAS" = "Country")) %>% 
  rename(WHOPop2005 = Pop2005) %>%
  select(OriginalPopulation2005, WHOPop2005, ManualCheckedPop2005) %>%
  map_df(log) %>%
  pairs()


combined %>%
  left_join(popcheck, by = c("CountrySAS" = "Country")) %>% 
  rename(WHOPop2005 = Pop2005) %>% 
  select(CountrySAS, OriginalPopulation2005, WHOPop2005, ManualCheckedPop2005) %>%View
  ggplot(aes(x = WHOPop2005, y = ManualCheckedPop2005, label = CountrySAS)) +
  geom_text() +
  scale_x_log10() +
  scale_y_log10()

View(combined)
