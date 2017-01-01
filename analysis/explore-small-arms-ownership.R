library(ggplot2)
library(scales)
library(tidyverse)
library(ggrepel)


load("data/sas_df.rda")

sas_df %>%
  ggplot(aes(x = `GNI (2005$) per capita`, y = `Average firearms per 100 people`, label = Country)) +
  geom_smooth() +
  geom_text_repel(colour = "white") +
  geom_point(colour = "steelblue") +
  scale_x_log10(label = dollar, breaks = 10 ^ (2:5)) +
  scale_y_log10(breaks = c(1, 10, 100)) 


