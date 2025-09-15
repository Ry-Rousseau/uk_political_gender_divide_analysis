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

cat("Data loaded successfully!\n")
cat("Dataset dimensions:", nrow(uk_data), "rows x", ncol(uk_data), "columns\n\n")

# Display data structure
cat("Data overview:\n")
glimpse(uk_data)