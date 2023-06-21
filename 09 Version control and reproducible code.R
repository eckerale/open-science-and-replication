### OSC: Session 09 Version control and writing reproducible code ###

# 0. load packages and define working directory ----
rm(list = ls())
library(tidyverse)
setwd("C:/Users/Ecker/Seafile/teaching/2023_Summer/OSC/01_slides/open-science-and-replication")


# 1. load data ----
df <- read_csv("latinobarometro_2020.csv")


# 2. hardcoding and copy & paste ----
table(df$p30st_a)

df <- df %>% 
  # recode variable so that higher values indicate more favorable opinions
  mutate(p30st_a = p30st_a * -1 + 5) %>%
  # change numeric values to missing values
  mutate(p30st_a = na_if(p30st_a, 6),
         p30st_a = na_if(p30st_a, 10)) %>%
  # convert to factor variable, i.e. relabel values 
  mutate(p30st_a = case_match(p30st_a,
                              1 ~ "very unfavorable",
                              2 ~ "somewhat unfavorable",
                              3 ~ "somewhat favorable",
                              4 ~ "very favorable")) %>%
  mutate(p30st_a = fct_relevel(p30st_a, "very unfavorable", "somewhat unfavorable", 
              "somewhat favorable", "very favorable")) %>%
  # rename variable
  rename(opinion_us = p30st_a)
  # rinse and repeat
  # ...
table(df$opinion_us, useNA = "ifany")


# 3. use vectorized tidyverse functions ----
# reload data set
df <- read_csv("latinobarometro_2020.csv")

# define factor levels
fct_lvls <- c("very unfavorable",
              "somewhat unfavorable",
              "somewhat favorable",
              "very favorable")
# define countries
names_to <- c("us", "russ", "chn", "eu", "cub")

# apply functions across variables
df <- df %>% mutate(across(starts_with("p30st_"),
                           ~ na_if(.x * -1 + 5, 6) %>%
                             na_if(10))) %>%
  mutate(across(starts_with("p30st_"),
                ~ case_match(.x,
                             1 ~ fct_lvls[1],
                             2 ~ fct_lvls[2],
                             3 ~ fct_lvls[3],
                             4 ~ fct_lvls[4]))) %>%
  mutate(across(starts_with("p30st_"), 
                ~ fct_relevel(.x, fct_lvls))) %>%
  rename_with(., ~ paste("opinion", names_to, sep = "_"),
              starts_with("p30st_"))


# 4. standardize variables, i.e. mean of 0 and standard deviation of 1 ----
# reload data set
df <- read_csv("latinobarometro_2020.csv")
df <- df %>%
  mutate(p30st_a = p30st_a * -1 + 5) %>%
  mutate(p30st_a = na_if(p30st_a, 6),
         p30st_a = na_if(p30st_a, 10))
df %>% summarise(mean(p30st_a, na.rm = TRUE),
                 sd(p30st_a, na.rm = TRUE))
df <- df %>%
  mutate(p30st_a_std = (p30st_a - 2.81)/0.885)
  # ...

df <- df %>%
  mutate(across(starts_with("p30st_"),
                ~ (.x - mean(.x, na.rm = TRUE))/sd(.x, na.rm = TRUE),
         .names = "{.col}_std"))
