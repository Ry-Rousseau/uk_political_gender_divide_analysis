# Load required packages
library(tidyverse)
library(haven)  # for reading SPSS files
library(estimatr) # for robust lin regression
library(survey) # package for survey analysis
library(lubridate) # for date manipulation

# Load the data and sort by wave number e.g. "wave_1"
sav_files <- list.files(path = file.path("data/mock_waves"), pattern = "\\.sav$", full.names = TRUE)
sav_files <- sav_files[order(as.numeric(gsub(".*wave_(\\d+).*", "\\1", sav_files)))]

# Create list with waves index chronologically
data_waves <- lapply(sav_files, read_sav)

# Set names to the list elements as "wave_1", "wave_2", etc. fomr the raw file names
names(data_waves) <- paste0("wave_", seq_along(data_waves))

# print names 
print(names(data_waves))

# glimpse(data_waves[[1]])

print("Demo setup complete. Data waves loaded and ready for processing.")
