cd <- get_codes()
head(cd)
cd[grep("[Aa]lcohol", cd$display), ][1,]

alcohol <- get_data("SA_0000001746")


alcohol <- get_data("WHOSIS_000011")


alcohol

alcohol %>%
  mutate(value = as.numeric(value)) %>%
  arrange(value) %>%
  filter(!is.na(country)) %>%
  filter(!is.na(value)) %>%
  filter(value > 8) %>%
  mutate(country = factor(country, levels = country)) %>%
  ggplot(aes(y = country, x = value, colour = region, group = country, label = country)) +
  geom_point(size = 4, colour = "grey50") +
  geom_text_repel() +
  theme(legend.position = "none") +
  ggtitle("Alcohol consumption among adults aged >15 years") +
  labs(x = "litres of pure alcohol per person per year", y = "selected heavy-drinking countries")
