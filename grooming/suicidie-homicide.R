library(WHO)
library(fuzzyjoin)

codes <- get_codes()
dim(codes) # 2230 codes


codes[grepl("omicide", codes$display), ]



# VIOLENCE_HOMICIDERATE  # per 100,000
# MH_12 # age standardised per 100,000
# SDGSUICIDE # crude  per 100,000


suicide_standard <- get_data("MH_12")
suicide_crude <- get_data("SDGSUICIDE")
homicide_crude <- get_data("VIOLENCE_HOMICIDERATE")
homicide_crude$sex <- "Both sexes"

violent_deaths <- rbind(suicide_standard, suicide_crude, homicide_crude) %>%
  mutate(value = as.numeric(value))




total_deaths <- violent_deaths %>%
  filter(gho != "Age-standardized suicide rates (per 100 000)") %>%
  filter(sex == "Both sexes") %>%
  mutate(cause = ifelse(grepl("suicide", gho), "Suicide", "Homicide")) %>%
  dplyr::select(-gho) %>%
  spread(cause, value) %>%
  mutate(Both = Homicide + Suicide) %>%
  arrange(Both) %>%
  mutate(country = factor(country, levels = country)) %>%
  # remove non-country regions:
  filter(!is.na(country)) %>%
  rename(Country = country) %>%
  # rename countries to match those in the gun ownership data %>%
  mutate(CountrySAS = country,
         CountrySAS = gsub("United Arab Emirates", "UAE", CountrySAS),
         CountrySAS = gsub("Luxembourg", "Luxemborg", CountrySAS),
         CountrySAS = gsub("Venezuela (Bolivarian Republic of)", "Venezuela", CountrySAS),
         CountrySAS = gsub("Russian Federation", "Russia", CountrySAS),
         CountrySAS = gsub("Iran (Islamic Republic of", "Iran", CountrySAS),
         CountrySAS = gsub("Iran (Islamic Republic of", "Iran", CountrySAS),
                           
                           
                           )
  
total_deaths  %>%
  filter(!is.na(Both)) %>%
  ggplot(aes(x = Both, y = Country, label = Country, colour = region))  +
  geom_text(size = 2) 

total_deaths %>%
  filter(!is.na(Both)) %>%
  dplyr::select(Country, Suicide, Homicide) %>%
  gather(cause, value, -Country) %>%
  ggplot(aes(weight = value, x = Country, fill = cause)) +
  geom_bar(position = "stack") +
  coord_flip() +
  labs(x = "", y = "Deaths per 100,000") +
  theme(axis.text.y = element_text(size = 6))




tmp <- total_deaths %>%
  dplyr::select(Country, Suicide, Homicide, Both) %>%
  mutate(Country = as.character(Country)) %>%
  right_join(sas_df, by = "Country")


sas_df$Country[!sas_df$Country %in% total_deaths$Country]
