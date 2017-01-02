# see http://ellisp.github.io/blog/2015/11/26/violent-deaths

library(grid)
library(gridExtra) # added 27/11/2015, for grid.arrange() to work!
library(rsdmx)    # for importing OECD data
library(rvest)    # for screen scraping data about Catholicism
library(extrafont)
library(stringr)
library(Cairo)

theme_set(theme_grey(base_family = "Calibri"))

#----------Import and mung the death from assault data---------------
# load deaths by assault from OECD.Stat
if(!exists("viol_sdmx")){
  myUrl <- "http://stats.oecd.org/restsdmx/sdmx.ashx/GetData/HEALTH_STAT/CICDHOCD.TXCMFETF+TXCMHOTH+TXCMILTX.AUS+AUT+BEL+CAN+CHL+CZE+DNK+EST+FIN+FRA+DEU+GRC+HUN+ISL+IRL+ISR+ITA+JPN+KOR+LUX+MEX+NLD+NZL+NOR+POL+PRT+SVK+SVN+ESP+SWE+CHE+TUR+GBR+USA+NMEC+BRA+CHN+COL+CRI+IND+IDN+LVA+LTU+RUS+ZAF/all?startTime=1960&endTime=2018"
  dataset <- readSDMX(myUrl) # takes about 30 seconds on a slow hotel internet connection
  viol_sdmx <- as.data.frame(dataset) # takes about 10 seconds on an i5
}



# load Country codes from ISOcodes R package
data("ISO_3166_1")

# mung:
viol <- viol_sdmx %>%
  # match country codes to country names:
  left_join(ISO_3166_1[ , c("Alpha_3", "Name")], by = c("COU" = "Alpha_3")) %>%
  # more friendly names:
  rename(Country = Name,
         Year = obsTime,
         Value = obsValue) %>%
  # limit to columns we want:
  select(UNIT, Country, Year, Value) %>%
  # make graphics-friendly versions of Unit and Year variables:
  mutate(Unit = ifelse(UNIT == "TXCMILTX", 
                       "Deaths per 100 000 population", "Deaths per 100 000 males"),
         Unit = ifelse(UNIT == "TXCMFETF", "Deaths per 100 000 females", Unit),
         Unit = factor(Unit, levels = 
                         c("Deaths per 100 000 females",    "Deaths per 100 000 population", "Deaths per 100 000 males")),
         Year = as.numeric(Year)) %>%
  # not enough data for Turkey to be useful so we knock it out:
  filter(Country != "Turkey")

maxyear <- max(viol$Year)

# create country x Unit summaries   
viol_sum <- viol %>%
  filter(Year > 1990) %>%
  group_by(Country, Unit) %>%
  summarise(Value = mean(Value)) %>%
  ungroup()

# create country totals (for ordering in charts)
totals <- viol_sum %>%
  group_by(Country) %>%
  summarise(Value = mean(Value)) %>%
  arrange(Value)

# create wider version, with one column per variable:
viol_spread <- viol_sum %>%
  mutate(Unit = as.character(Unit),
         Unit = ifelse(grepl("female", Unit), "Female", Unit),
         Unit = ifelse(grepl(" males", Unit), "Male", Unit),
         Unit = ifelse(grepl("population", Unit), "Population", Unit)) %>%
  spread(Unit, Value) %>%
  mutate(Country = factor(Country, levels = totals$Country))


png("oecd_assaults.png", 1000, 800, res = 100)
viol_sum %>%
  mutate(Country = factor(Country, levels = totals$Country)) %>%
  mutate(Label = ifelse(grepl("population", Unit), as.character(Country), "|")) %>%
  ggplot(aes(x = Value, y = Country)) +
  geom_segment(data = viol_spread, aes(y = Country, yend = Country, x = Male, xend = Female),
               colour = "white", size = 3) +
  geom_text(size = 4, aes(label = Label, colour = Unit), alpha = 0.8,
            family = "Calibri") +
  labs(y = "") +
  scale_x_log10(("Deaths per 100,000 (logarithmic scale)")) +
  theme(legend.position = "bottom") +
  scale_colour_manual("", values = c("red", "grey10", "blue")) +
  labs(colour = "") +
  ggtitle(paste("Mean annual deaths from assault 1990 to", maxyear)) 
dev.off()

knockouts <- c("Colombia", "Brazil", "Russian Federation", "Mexico")

png("oecd_assaults_nonlog.png", 1000, 800)
viol_sum %>%
  mutate(Country = factor(Country, levels = totals$Country)) %>%
  filter(!grepl("population", Unit)) %>%
  mutate(Label = "|") %>%
  filter(!Country %in% knockouts) %>%
  ggplot(aes(y = Country)) +
  geom_segment(data = filter(viol_spread, !Country %in% knockouts),  
               aes(y = Country, yend = Country, x = Male, xend = Female),
               colour = "white", size = 3) +
  geom_text(size = 4, aes(x = Value, label = Label, colour = Unit), alpha = 0.8) +
  labs(y = "") +
  scale_x_continuous(("Deaths per 100,000")) +
  theme(legend.position = "bottom") +
  scale_colour_manual("", values = c("red", "blue")) +
  labs(colour = "") +
  ggtitle(paste("Mean annual deaths from assault 1990 to", maxyear, 
                "\n(Colombia, Brazil, Russia, Mexico not shown as too large)"))
dev.off()

#-----------order by female-------------
# create country totals (for ordering in charts)
totals2 <- viol_sum %>%
  filter(grepl("females", Unit)) %>%
  arrange(Value)

# create wider version, with one column per variable:
viol_spread2 <- viol_sum %>%
  mutate(Unit = as.character(Unit),
         Unit = ifelse(grepl("female", Unit), "Female", Unit),
         Unit = ifelse(grepl(" males", Unit), "Male", Unit),
         Unit = ifelse(grepl("population", Unit), "Population", Unit)) %>%
  spread(Unit, Value) %>%
  mutate(Country = factor(Country, levels = totals2$Country))

png("oecd_assaults_nonlog_female_ordered.png", 1000, 800)
viol_sum %>%
  mutate(Country = factor(Country, levels = totals2$Country)) %>%
  filter(!grepl("population", Unit)) %>%
  mutate(Label = "|") %>%
  filter(!Country %in% knockouts) %>%
  ggplot(aes(y = Country)) +
  geom_segment(data = filter(viol_spread2, !Country %in% knockouts),  
               aes(y = Country, yend = Country, x = Male, xend = Female),
               colour = "white", size = 3) +
  geom_text(size = 4, aes(x = Value, label = Label, colour = Unit), alpha = 0.8) +
  labs(y = "") +
  scale_x_continuous(("Deaths per 100,000")) +
  theme(legend.position = "bottom") +
  scale_colour_manual("", values = c("red", "blue")) +
  labs(colour = "") +
  ggtitle(paste("Mean annual deaths from assault 1990 to", maxyear, 
                "\n(Colombia, Brazil, Russia, Mexico not shown as too large)"))
dev.off()


#=============plots over time==================
rectcol <- "darkgreen"

totals3 <- viol %>%
  filter(Year > 2007) %>%
  group_by(Country, Unit) %>%
  summarise(Value = mean(Value)) %>%
  ungroup() %>%
  group_by(Country) %>%
  summarise(Value = mean(Value)) %>%
  arrange(Value)

# 25 best countries
CairoPDF("oecd_assaults_30countries_overtime.pdf", 16, 11)
numberin <- 25
countriesin <- totals[1:numberin, ]$Country
viol %>%
  mutate(Unit = str_to_title(gsub("Deaths per 100 000 ", "", Unit)),
         Unit = factor(Unit, levels = c("Females", "Population", "Males"))) %>%
  filter(Country %in% countriesin) %>%
  mutate(Country = factor(Country, levels = totals3$Country)) %>%
  ggplot(aes(x = Year, y = Value, colour = Unit)) +
  facet_wrap(~Country, ncol = 5) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point(alpha = 0.6, size = 0.3) +
  scale_colour_manual("", values = c("red", "grey10", "steelblue")) +
  theme_grey(16, base_family = "Calibri") +
  theme(legend.position = "bottom") +
  labs(y = "Deaths per 100,000 per year\n", 
       title = paste0("Deaths per 100,000 from assault 1960 to ", maxyear, 
                      ", in order of average rate since 2008")) +
  scale_x_continuous("", breaks = seq(1960, 2010, by = 10)) +
  coord_cartesian(ylim = c(0, 4))

grid.rect(0.521, 0.175, 0.192, 0.203, 
          gp = gpar(fill = NA, col = rectcol, lwd = 4))

dev.off()


countrycomp <- c("Australia", "United Kingdom", "Sweden", "Ireland", "Canada", "New Zealand")



p2 <- viol %>%
  mutate(Unit = str_to_title(gsub("Deaths per 100 000 ", "", Unit)),
         Unit = factor(Unit, levels = c("Females", "Population", "Males"))) %>%
  filter(Country %in% countrycomp) %>%
  mutate(Country = factor(Country, levels = totals3$Country)) %>%
  ggplot(aes(x = Year, y = Value, colour = Unit)) +
  facet_wrap(~Country, ncol = 3) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point(alpha = 0.6, size = 0.3) +
  scale_colour_manual("", values = c("red", "grey10", "steelblue")) +
  theme_grey(16, base_family = "Calibri") +
  theme(legend.position = "bottom") +
  labs(y = "Deaths per 100,000 per year\n", 
       title = paste0("Deaths per 100,000 from assault 1960 to ", maxyear,
                      ", in order of average rate since 2008")) +
  scale_x_continuous("", breaks = seq(1960, 2010, by = 10)) +
  coord_cartesian(ylim = c(0, 4))


totals4 <- viol %>%
  filter(grepl("female", Unit)) %>%
  filter(Year > 2009) %>%
  group_by(Country, Unit) %>%
  summarise(Value = mean(Value)) %>%
  ungroup() %>%
  group_by(Country) %>%
  summarise(Value = mean(Value)) %>%
  arrange(Value)

earlier <- 1960 # starting point for chart
p3 <- viol %>%
  mutate(Unit = str_to_title(gsub("Deaths per 100 000 ", "", Unit)),
         Unit = factor(Unit, levels = c("Females", "Population", "Males"))) %>%
  filter(Country %in% countrycomp) %>%
  filter(Unit == "Females") %>%
  mutate(Country = factor(Country, levels = totals4$Country)) %>%
  ggplot(aes(x = Year, y = Value, colour = Unit)) +
  facet_wrap(~Country, ncol = 3) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point(alpha = 0.6, size = 0.3) +
  scale_colour_manual("", values = c("red", "grey10", "steelblue")) +
  theme_grey(16, base_family = "Calibri") +
  theme(legend.position = "none") +
  labs(y = "Deaths per 100,000 per year", 
       title = paste0("Female deaths per 100,000 from assault 1960 to ", maxyear,
                      ", in order of average female rate since 2008")) +
  scale_x_continuous(breaks = seq(earlier, 2010, by = 10)) +
  labs(x = "\nNew Zealand's slower improvement in female deaths from assault means it now has the highest rate of the comparison countries in this chart.\n") +
  coord_cartesian(xlim = c(earlier, 2015))

CairoPDF("oecd_assaults_6countries_overtime.pdf", 16, 11)
  grid.arrange(p2, p3, ncol = 1)
  
  # bottom
  grid.rect(0.838, 0.171, 0.315, 0.218, 
            gp = gpar(fill = NA, col = rectcol, lwd = 4))
  
  # top
  grid.rect(0.522, 0.675, 0.315, 0.225, 
            gp = gpar(fill = NA, col = rectcol, lwd = 4))
  
  
dev.off()

