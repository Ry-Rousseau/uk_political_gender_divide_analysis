# UK Political Gender Divide Analysis - Setup Script
# Load data and required packages for analysis

# Load required packages
library(tidyverse)
library(haven)  # for reading SPSS files
library(estimatr) # for robust lin regression
library(survey) # package for survey analysis

# Load the data
cat("Loading UK Election Study data...\n")
uk_data <- read_sav("./data/uk_election_data_case_study_weighted.sav")


uk_data <- uk_data %>%
  mutate(across(everything(), ~case_when(
    .x == "Don't know" ~ NA,
    .x == "dk" ~ NA,
    .x == "no_answer" ~ NA,           # religion column
    .x == "prefer_not_to_say" ~ NA,   # marital column
    TRUE ~ .x
  ))) %>% 
  # create gender age variable for ease of use - removing NA's
  mutate(gender_age = str_c(gender,age , sep = "_", na.rm = TRUE))

# Function to recode attitude responses to -1 to 1 scale
recode_attitude_minus_1_to_1 <- function(x) {
  case_when(
    x == "Strongly agree" ~ 1,
    x == "Agree" ~ 0.5,
    x == "Neither agree nor disagree" ~ 0,
    x == "Disagree" ~ -0.5,
    x == "Strongly disagree" ~ -1,
    TRUE ~ NA_real_
  )
}

# Function to recode attitude responses to 0 to 1 scale
recode_attitude_0_to_1 <- function(x) {
  case_when(
    x == "Strongly agree" ~ 1,
    x == "Agree" ~ 0.75,
    x == "Neither agree nor disagree" ~ 0.5,
    x == "Disagree" ~ 0.25,
    x == "Strongly disagree" ~ 0,
    TRUE ~ NA_real_
  )
}

cat("Encoding attitude variables and creating scales in range [0,1]\n")


# Convert attitude variables to numeric and create scales
uk_data <- uk_data %>%
  mutate(
    # Convert social attitude variables to numeric (-1 to 1 scale)
    soc_respect = recode_attitude_0_to_1(soc_respect),
    soc_deathpen = recode_attitude_0_to_1(soc_deathpen),
    soc_schools = recode_attitude_0_to_1(soc_schools),
    soc_censor = recode_attitude_0_to_1(soc_censor),
    soc_punish = recode_attitude_0_to_1(soc_punish),
    # Convert economic attitude variables to numeric (-1 to 1 scale)
    econ_redist = recode_attitude_0_to_1(econ_redist),
    econ_bigbiz = recode_attitude_0_to_1(econ_bigbiz),
    econ_unfair = recode_attitude_0_to_1(econ_unfair),
    econ_onelaw = recode_attitude_0_to_1(econ_onelaw),
    econ_exploit = recode_attitude_0_to_1(econ_exploit)) %>% 
  rowwise() %>%
  mutate(
    social_conservatism = mean(c_across(c(soc_respect, soc_deathpen, soc_schools, soc_censor, soc_punish)), na.rm = TRUE),
    economic_rightism = 1 - mean(c_across(c(econ_redist, econ_bigbiz, econ_unfair, econ_onelaw, econ_exploit)), na.rm = TRUE),
    social_na_count = sum(is.na(c_across(c(soc_respect, soc_deathpen, soc_schools, soc_censor, soc_punish)))),
    economic_na_count = sum(is.na(c_across(c(econ_redist, econ_bigbiz, econ_unfair, econ_onelaw, econ_exploit))))
  ) %>%
  ungroup() %>% 
  # Convert survey items back to [-1, -0.5, 0, 0.5, 1] scale for easier interpretation
  mutate(
    soc_respect = soc_respect * 2 - 1,
    soc_deathpen = soc_deathpen * 2 - 1,
    soc_schools = soc_schools * 2 - 1,
    soc_censor = soc_censor * 2 - 1,
    soc_punish = soc_punish * 2 - 1,
    econ_redist = econ_redist * 2 - 1,
    econ_bigbiz = econ_bigbiz * 2 - 1,
    econ_unfair = econ_unfair * 2 - 1,
    econ_onelaw = econ_onelaw * 2 - 1,
    econ_exploit = econ_exploit * 2 - 1
  )

## Create survey design object
survey_design_full <- svydesign(
  ids = ~1,  # No clustering in this dataset, assumes simple random sampling
  weights = ~wt,
  data = uk_data
)


cat("Dataset dimensions:", nrow(uk_data), "rows x", ncol(uk_data), "columns\n\n")

# Display data structure
cat("Data overview:\n")
glimpse(uk_data)