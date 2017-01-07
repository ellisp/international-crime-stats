---
title: "HDI"
author: "Peter Ellis and Kay Fisher"
date: "3 January 2017"
output: html_document
---



## Human Development Indicators

These data are downloaded from http://hdr.undp.org/en/data and in particular from the "Download Data" button, which provides a CSV (not the "Download all 2015 data by indicator , year and country" link, which goes to an Excel file that for some reason doesn't have 2005, 1995 or 1985 data data)

Data in the CSV are provided for 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2011, 2012, 2013 and 2014 and these are all available in the object `hdi` in `/data/hdi.rda`:


```r
dim(hdi)
```

```
## [1] 1792    6
```

```r
datatable(hdi)
```

![plot of chunk hdi1](figure/hdi1-1.png)


```r
ggplot(hdi, aes(x = year, y = HDI, colour = Country)) +
  geom_point() +
  geom_line() + 
  theme(legend.position = "none")
```

![plot of chunk hdi2](figure/hdi2-1.png)


