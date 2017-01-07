---
title: "indicators2005"
author: "Peter Ellis and Kay Fisher"
date: "3 January 2017"
output: html_document
---



## indicators2005

`indicators2005` is the main data frame for analysis of the impact of civilian small arms ownership on homicide and suicide.  Each indicator is as close to 2005 as possible.


```r
dim(indicators2005)
```

[1] 194  20

```r
datatable(indicators2005)
```

![plot of chunk i2005ch1](figure/i2005ch1-1.png)

The variables are

- **region** Regional grouping
- **Pop2005** Country population, sourced from WHO
- **country** Country name, WHO format
- **Alpha_2** and **Alpha_3** - ISO3166 country codes, 2 and 3 character versions
- **worldbankincomegroup**
- **Alcohol** Alcohol use in 2005 - Alcohol consumption among adults aged >15 years, litres of pure alcohol per person per year.  Sourced from WHO.
- **FemaleSuicide**, **MaleSuicide** and **Suicide** standardised suicide rates per 100,000.  Sourced from the OECD and only available for 37 countries.
- **giniyear** year for inequality data.  Chosen to be as close to 2005 as possible.
- **gini** Gini coefficient of income.  Meausre of inequality.  Sourced from World Bank World Development Indicators.
- **gnpyear** year for GNP data.  Chosen to be as close to 2005 as possible.
- **GNPPerCapitaPPP** Gross National Income per capita, purchasing power parity measure. `NY.GNP.PCAP.PP.CD` measure in World Development Indicators.
- **homicideyear** year for homicide data.  Chosen to be as close to 2005 as possible.  Varies from 2004 to 2014 but mostly is 2005.
- **Homicide** homicides per 100,000 population.  Series `VC.IHR.PSRC.P5` from the World Bank World Development Indicators. 
- **Average total all civilian firearms** Taken directly from the Small Arms Survey 2007, not edited.
- **FirearmsPer100People2005"** Calculated from total firearms divided by population, time 100.  Not taken directly from the Small Arms Survey, which has a column for firearms per 100 people but which involves errors and inconsistencies.
- **HDI** Human Development Index for 2005.  Calculated as average of HDI in 2000 and 2010 for most countries.  Some countries (when only one value available) is HDI for 2010.  Source is the UNDP Human Development Index 2015 report Excel tables, which has incomplete historical data.
- **rich** Logical value, `TRUE` if country is one of the top 25 by HDI.

### Data that comes from different years:

```r
table(indicators2005$giniyear)
```

```
## 
## 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2013 
##    1    5   11   13   71   18   10    7    5    3    2    1
```

```r
table(indicators2005$gnpyear)
```

```
## 
## 2005 2008 2011 
##  184    1    1
```

```r
table(indicators2005$homicideyear)
```

```
## 
## 2004 2005 2006 2007 2008 2009 2010 2011 2012 2014 
##    3  118    7    9    7    4    2    2   39    1
```

### Basic descriptive graphic

```r
indicators2005 %>%
  select(worldbankincomegroup, Suicide, gini, GNPPerCapitaPPP, Homicide, FirearmsPer100People2005, HDI) %>%
  ggpairs(mapping = ggplot2::aes(colour=worldbankincomegroup))
```

![plot of chunk i2005ch3](figure/i2005ch3-1.png)

