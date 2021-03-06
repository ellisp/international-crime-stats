# deaths from assault per 100,000, age-standardised. data covers from 1960 to max year (currently 2014)
#but since data not available prior to 1990 for many countries - choosing to plot from 1990 

load("data/oecd_assaults.rda")
load("data/oecd_assaults_sum.rda")
maxyear <- max(oecd_assaults$Year)


#======================"bar" charts showing average rates since 1990=================
png("output/oecd_assaults_bypop.png", 1000, 800, res = 100)
# make a temporary version of the data that is longer, with a Sex variable
# rather than a column for the values of each sex
tmp <- oecd_assaults_sum %>%
  select(Country, Male, Female) %>%
  gather(Sex, Value, -Country)

print(
oecd_assaults_sum %>%
  # which order to present in? Can be Population, Male or Female
  arrange(Population) %>%
  mutate(Country = factor(Country, levels = Country)) %>%
  ggplot(aes(y = Country)) +
  geom_segment(aes(yend = Country, x = Male, xend = Female),
               colour = "white", size = 3) +
  geom_text(size = 4, aes(label = Country, x = Population), alpha = 0.8,
            family = "Calibri") +
  # now we use that `tmp` object we created earlier:
  geom_text(data = tmp, aes(x = Value, colour = Sex), label = "|") +
  labs(y = "") +
  scale_x_log10(("Age-standardised deaths per 100,000 (logarithmic scale)")) +
  theme(legend.position = "bottom") +
  scale_colour_manual("", values = c(Female = "red", Male = "blue")) +
  labs(colour = "") +
  ggtitle(paste("Age-standardised mean annual deaths from assault per 100,000 from 1990 to", maxyear)) 
)
dev.off()

knockouts <- c("Colombia", "Brazil", "Russian Federation", "Mexico")

png("output/oecd_assaults_nonlog.png", 1000, 800)
tmp <- oecd_assaults_sum %>%
  filter(!Country %in% knockouts) %>%
  select(Country, Male, Female) %>%
  gather(Sex, Value, -Country)

print(
oecd_assaults_sum %>%
  # which order to present in? Can be Population, Male or Female
  filter(!Country %in% knockouts) %>%
  arrange(Population) %>%
  mutate(Country = factor(Country, levels = Country)) %>%
  ggplot(aes(y = Country)) +
  geom_segment(aes(yend = Country, x = Male, xend = Female),
               colour = "white", size = 3) +
  geom_text(size = 4, aes(label = Country, x = Population), alpha = 0.8,
            family = "Calibri") +
  # now we use that `tmp` object we created earlier:
  geom_text(data = tmp, aes(x = Value, colour = Sex), label = "|") +
  labs(y = "") +
  scale_x_continuous(("Age-standardised deaths per 100,000 (logarithmic scale)")) +
  theme(legend.position = "bottom") +
  scale_colour_manual("", values = c(Female = "red", Male = "blue")) +
  labs(colour = "") +
  ggtitle(paste("Age-standardised mean annual deaths from assault per 100,000 from 1990 to", maxyear)) 
)
dev.off()


#=============plots over time==================
rectcol <- "darkgreen"

# 25 best countries
CairoPDF("output/oecd_assaults_25countries_overtime.pdf", 16, 11)

numberin <- 25
countriesin <- oecd_assaults_sum %>%
  arrange(Population) %>%
  slice(1:25) %$%
  Country

print(
oecd_assaults %>%
  mutate(Unit = str_to_title(gsub("Age-standardised deaths per 100 000 ", "", Unit)),
         Unit = factor(Unit, levels = c("Females", "Population", "Males"))) %>%
  filter(Country %in% countriesin) %>%
  mutate(Country = factor(Country, levels = oecd_assaults_sum$Country)) %>%
  ggplot(aes(x = Year, y = Value, colour = Unit)) +
  facet_wrap(~Country, ncol = 5) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point(alpha = 0.6, size = 0.3) +
  scale_colour_manual("", values = c("red", "grey10", "steelblue")) +
  theme_grey(16, base_family = "Calibri") +
  theme(legend.position = "bottom") +
  labs(y = "Age-standardised deaths per 100,000 per year\n", 
       title = paste0("Age-standardised deaths from assault per 100,000 from 1960 to ", maxyear, 
                      ", in order of average rate since 2008")) +
  scale_x_continuous("", breaks = seq(1960, 2010, by = 10)) +
  coord_cartesian(ylim = c(0, 4))
)

# draw rectangle highlighting New Zealand
grid.rect(0.521, 0.175, 0.192, 0.203, 
          gp = gpar(fill = NA, col = rectcol, lwd = 4))

dev.off()


#=================Six comparison countries, two charts on one page====================

countrycomp <- c("Australia", "United Kingdom", "Sweden", "Ireland", "Canada", "New Zealand")

# we need the average population rate since 2009
totals3 <- oecd_assaults %>%
  filter(grepl("population", Unit)) %>%
  filter(Year >= 2009) %>%
  group_by(Country, Unit) %>%
  summarise(Value = mean(Value)) %>%
  arrange(Value)

p2 <- oecd_assaults %>%
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
  labs(y = "Age-standardised deaths per 100,000 per year\n", 
       title = paste0("Age-standardised deaths from assault per 100,000 from 1960 to ", maxyear,
                      ", in order of average rate since 2008")) +
  scale_x_continuous("", breaks = seq(1960, 2010, by = 10)) +
  coord_cartesian(ylim = c(0, 4))

totals4 <- oecd_assaults %>%
  filter(grepl("female", Unit)) %>%
  filter(Year >= 2009) %>%
  group_by(Country, Unit) %>%
  summarise(Value = mean(Value)) %>%
  arrange(Value)

earlier <- 1960 # starting point for chart
p3 <- oecd_assaults %>%
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
  labs(y = "Age-standardised deaths per 100,000 per year", 
       title = paste0("Age-standardised female deaths from assault per 100,000 from 1960 to ", maxyear,
                      ", in order of average female rate since 2008")) +
  scale_x_continuous(breaks = seq(earlier, 2010, by = 10)) +
  labs(x = "\nNew Zealand's slower improvement in female deaths from assault means it now has the highest rate of the comparison countries in this chart.\n") +
  coord_cartesian(xlim = c(earlier, 2015))

CairoPDF("output/oecd_assaults_6countries_overtime.pdf", 16, 11)
  grid.arrange(p2, p3, ncol = 1)
  
  # draw rectangles highlighting New Zealand
  
  # bottom
  grid.rect(0.838, 0.171, 0.315, 0.218, 
            gp = gpar(fill = NA, col = rectcol, lwd = 4))
  
  # top
  grid.rect(0.522, 0.675, 0.315, 0.225, 
            gp = gpar(fill = NA, col = rectcol, lwd = 4))
  
  
dev.off()

#==== Modified non-log female ordered plot 1990-2014 ====

# make a temporary version of the data that is longer, with a Sex variable
# rather than a column for the values of each sex
tmp <- oecd_assaults_sum %>%
 # filter(!Country %in% knockouts) %>%
  select(Country, Male, Female) %>%
  gather(Sex, Value, -Country)

p1 <-  oecd_assaults_sum %>%
    # which order to present in? Can be Population, Male or Female
   # filter(!Country %in% knockouts) %>%
    arrange(Female) %>%
    mutate(Country = factor(Country, levels = Country)) %>%
    ggplot(aes(y = Country)) +
    geom_segment(aes(yend = Country, x = Male, xend = Female),
                 colour = "white", size = 3) +
    #geom_text(size = 4, aes(label = Country, x = Population), alpha = 0.8,
     #family = "Calibri") +
    # now we use that `tmp` object we created earlier:
    geom_text(data = tmp, aes(x = Value, colour = Sex), label = "|") +
    labs(y = "") +
    scale_x_continuous("Deaths per 100,000", breaks = 0:7 * 25) +
    theme(legend.position = "bottom") +
    scale_colour_manual("", values = c(Female = "red", Male = "blue")) +
    ggtitle(paste("Age-standardised mean annual deaths from assault per 100,000 from 1990 to", maxyear)) 

CairoPDF("output/1990-2014_oecd_assaults_nonlog_female_ordered-A4.pdf", 8.27, 11.69)
print(p1)
dev.off()

CairoPDF("output/1990-2014_oecd_assaults_nonlog_female_ordered-A3.pdf", 16.53, 11.69)
print(p1)
dev.off()


CairoPDF("output/1990-2014_oecd_assaults_log_female_ordered-A4.pdf", 8.27, 11.69)
  print(p1 + scale_x_log10("Deaths per 100,000 (logarithmic scale)"))
dev.off()

CairoPDF()

