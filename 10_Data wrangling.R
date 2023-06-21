### OSC: Session 10 Data wrangling ###

# 0. load packages and define working directory ----
library(tidyverse)
rm(list = ls())
setwd("C:/Users/Ecker/Seafile/teaching/2023_Summer/OSC/01_slides/open-science-and-replication")


# 1. data import ----
## slide 2 ----
# the load() function loads RData files (with multiple objects)
load("test_data.RData")

# the save() function stores (multiple objects) as RData file
save(qog, file = "new_test_data.RData")


## slide 3 ----
# the read_csv() function loads data sets in CSV format
read_csv("qog_bas_cs_jan22.csv")
df <- read_csv("qog_bas_cs_jan22.csv")

# the write_csv() function stores one object as CSV file
write_csv(df, file = "new_test_data.csv")


# 2. relational data ----
## slide 5 ----
df_netflix <- read_csv("netflix_data.csv")
df_prod <- read_csv("netflix_productions.csv")
df_lang <- read_csv("netflix_language.csv")


# 3. pivoting data ----
## slide 6 ----
df_wide <- read_csv("wide_data.csv")
df_long <- read_csv("long_data.csv")


## slide 7 ----
df <- df_wide %>% pivot_longer(cols = c(starts_with("cpi_"), starts_with("rank_")),
                               names_to = c(".value", "year"),
                               names_sep = "_") %>%
  arrange(Country, year)
                               

## slide 8 ----
df <- df_long %>% pivot_wider(names_from = "name", 
                              values_from = "value") %>%
  arrange(Country, year)

## standard pivoting ----
df_wide <- read_csv("UNIGME-2021.csv") 
df <- df_wide %>% pivot_longer(cols = starts_with("U5MR"),
                          names_to = "year",
                          values_to = "child_mort",
                          names_prefix = "U5MR.")
