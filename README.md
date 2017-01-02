---
title: "README"
author: "Peter Ellis and Kay Fisher"
date: "3 January 2017"
output: html_document
---



## International Crime Statistics

This project is for comparative analysis of international statistics on crime.  It examines country-level data on homicide, assault, suicide; in the light of other variables such as Gross National Income, Human Development Index, economic inequality, and civilian firearm ownership.

![suicide](/images/suicide-hdi-gini.png)

## Principles for using this repository

This project has a [GPL-3 license](LICENSE).

The `./integrate.R` script acts a bit like a make file.  It creates all datasets from original source data, and performs all analysis and documentation that produce persistent artefacts.  Any new analysis or data should be created with their own individual scripts which are then called with `source()` from `integrate.R`.

### data
The `./data/` folder contains only final, cleaned and concorded analysis-ready data sets, in either rda or csv format.  

- `.rda` files should have a single data frame, with the same name as the `*.rda` file itself.
-  Data that is a cross-sectional snapshot should have that reflected in the data.frame's name eg `indicators2005`.
- hand-curated small datasets (eg concordances like `conc_iso3166.csv`) are ok but should be in csv format for easy tracking by Git and editing by a text editor or Excel.

### raw_data
The `./raw_data/` folder contains only untouched downloaded data.  Generally this should have been programmatically downloaded by one of the scripts in `./grooming/` but in some cases they might have been downloaded by hand.


### grooming
The `./grooming/` folder contains scripts that download data (and in some cases save it to the `./raw_data/` folder), tidies, cleans and concords it and saves it in the `./data/` folder.

### analysis
The `./analysis/` folder contains scripts that perform analysis.  These can be R or .Rmd scripts

### doc
The `./doc/ folder contains .Rmd and HTML files with documentation.

See also the project [issues](https://github.com/ellisp/international-crime-stats/issues) and project [Wiki](https://github.com/ellisp/international-crime-stats/wiki).

### images
The `./images/` folder holds images (typically analysis output) that is used in common across the project - for example analytical outputs.

