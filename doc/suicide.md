---
title: "suicide"
author: "Peter Ellis and Kay Fisher"
date: "3 January 2017"
output: html_document
---



## suicide

The `suicide` dataset is sourced from the OECD, created in `/grooming/import-oecd-suicide.R` script.  It is downloaded with SDMX from the ["OECD Health Status" database]() with all variables unselected except "External causes of mortality", "Intentional self-harm".


```r
datatable(suicide)
```

![plot of chunk suich1](figure/suich1-1.png)

The original codes for "measures" selected are:

- TXCMILTX: Deaths per 100 000 population (standardised rates)
- TXCMHOTH: Deaths per 100 000 males (standardised rates)
- TXCMFETF: Deaths per 100 000 females (standardised rates)
- TXCRUDTX: Deaths per 100 000 population (crude rates)

Standardised rates of suicide are preferred.  TODO - link to study that recommended this.
