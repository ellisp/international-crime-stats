

sas_df3 <- sas_df2 %>%
  left_join(indicators2005[ , c("Alpha_2", "Pop2005")], by = "Alpha_2") %>%
  rename(ActualPopulation = Pop2005,
         SASPopulation = OriginalPopulation2005,
         SASDerivedAverageFirearms = DerivedAverageFirearms,
         SASOriginalAverageFirearms = OriginalAverageFirearms) %>%
  mutate(ActualFirearmsDividedByActual100Population = `Average total all civilian firearms` / ActualPopulation * 100) %>%
  select(Alpha_2, Country, `Average total all civilian firearms`, `SASPopulation`, `ActualPopulation`, 
         `SASOriginalAverageFirearms`, SASDerivedAverageFirearms, ActualFirearmsDividedByActual100Population)
  
  
write.csv(sas_df3,  file = "output/comparisons-discrepencies-sas2007.csv", row.names = FALSE)
