---
title: "oecd-assaults"
author: "Peter Ellis and Kay Fisher"
date: "7 January 2017"
output: html_document
---



## OECD Deaths From Assault
Age-standardised death rates per 100,000 for females, males and population.  From the OECD Health Status database (note - this is the same source as used for the suicide data).

Created by the script `./grooming/import-oecd-assault-deaths.R` with the SDMX url:

```
http://stats.oecd.org/restsdmx/sdmx.ashx/GetData/HEALTH_STAT/CICDHOCD.TXCMFETF+TXCMHOTH+TXCMILTX.AUS+AUT+BEL+CAN+CHL+CZE+DNK+EST+FIN+FRA+DEU+GRC+HUN+ISL+IRL+ISR+ITA+JPN+KOR+LUX+MEX+NLD+NZL+NOR+POL+PRT+SVK+SVN+ESP+SWE+CHE+TUR+GBR+USA+NMEC+BRA+CHN+COL+CRI+IND+IDN+LVA+LTU+RUS+ZAF/all?startTime=1960&endTime=2018
```

Note that crude rates are also available at the source, but are not downloaded into this project.

There are two versions of the data, both of them in `tibble` format:

- **oecd_assaults** is the full time series back to 1960 to the latest year, which is 2014 at the time of writing.  The time series has a lot of noise, so to represent graphically you should use some kind of smoothing.
- **oecd_assaults_sum** is an aggregate version of the data with mean values from 1990 to the latest year.  

Example usage for analysis can be found in [/analysis/explore-oecd-assaults-data.R](https://github.com/ellisp/international-crime-stats/blob/master/analysis/explore-oecd-assaults-data.R)

## oecd_assaults

```r
dim(oecd_assaults)
```

```
## [1] 5389    6
```

```r
datatable(oecd_assaults)
```

![plot of chunk oecd_assaults1](figure/oecd_assaults1-1.png)

The columns are:

- **UNIT** Measure code from OECD.Stat
- **Country** Country name
- **Year** 
- **Value** Age-standardised deaths by assault per 100,000 population
- **Alpha_2** Two character ISO3166 code for country
- **Unit** Unit description from OECD.Stat

## oecd_assaults_sum


```r
dim(oecd_assaults_sum)
```

```
## [1] 40  5
```

```r
datatable(oecd_assaults_sum)
```

![plot of chunk oecd_assaults2](figure/oecd_assaults2-1.png)

The columns are:

- **Country** Country name
- **Alpha_2** Two character ISO3166 code for country
- **Female** Female age-standardised deaths by assault per 100,000 population
- **Male** As Female but for Males
- **Population** As Female but for whole population

## Example usage


```r
maxyear <- max(oecd_assaults$Year)
numberin <- 25
countriesin <- oecd_assaults_sum %>%
  arrange(Population) %>%
  slice(1:25) %$%
  Country

oecd_assaults %>%
  mutate(Unit = str_to_title(gsub("Deaths per 100 000 ", "", Unit)),
         Unit = factor(Unit, levels = c("Females", "Population", "Males"))) %>%
  filter(Country %in% countriesin) %>%
  mutate(Country = factor(Country, levels = oecd_assaults_sum$Country)) %>%
  ggplot(aes(x = Year, y = Value, colour = Unit)) +
  facet_wrap(~Country, ncol = 5) +
  geom_smooth(se = FALSE, method = "loess") +
  geom_point(alpha = 0.6, size = 0.3) +
  scale_colour_manual("", values = c("red", "grey10", "steelblue")) +
  theme_grey(11, base_family = "Calibri") +
  theme(legend.position = "bottom") +
  labs(y = "Deaths per 100,000 per year\n", 
       title = paste0("Deaths per 100,000 from assault 1960 to ", maxyear, 
                      ", in order of average rate since 2008")) +
  scale_x_continuous("", breaks = seq(1960, 2010, by = 10)) +
  coord_cartesian(ylim = c(0, 4)) 
```

![plot of chunk oecd_assaults3](figure/oecd_assaults3-1.png)

