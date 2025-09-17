# Mock Survey Wave Generator - Stratified Sampling
# Creates 4 stratified survey waves from existing data for testing tracking functions
# Exists to just simulate real survey waves with realistic demographic distributions 

# Maintains demographic proportions (age, gender, region, ethnicity, education) to preserve survey weights
# These are the confirmed weighting variables used in the original survey

# NOTE: THROUGH SPLITTING WE LOSE RESPONDENTS BUT WE MAINTAIN STATISTICAL ACCURACY BY STRATIFYING WITH SAME DEMOGRAPHICS AS ORIGINAL WEIGHTS

# Load required packages
library(tidyverse)
library(haven)
library(splitstackshape)

# Load the main dataset (assuming setup.R has been run or data is available)
if (!exists("uk_data")) {
  uk_data <- read_sav("./data/uk_election_data_case_study_weighted.sav")
}

# Function to create stratified mock survey waves with UNIQUE respondents across waves
create_mock_waves <- function(data, n_waves = 4, min_sample_size = 5000) {
  
  # Set seed for reproducibility
  set.seed(42)
  
  # Define mock month labels (assumes 4 waves)
  mock_months <- c("May_2024", "June_2024", "July_2024", "August_2024")
  
  # Check that stratification variables exist (all 5 weighting variables)
  required_vars <- c("age", "gender", "region", "ethnicity", "education")
  missing_vars <- required_vars[!required_vars %in% colnames(data)]
  if(length(missing_vars) > 0) {
    stop("Missing required stratification variables: ", paste(missing_vars, collapse = ", "))
  }
  
  # Create stratification variable by combining all 5 weighting variables
  cat("Creating stratification groups for UNIQUE respondent allocation...\n")
  data_with_strata <- data %>%
    mutate(strata_group = paste(age, gender, region, ethnicity, education, sep = "_"))
  
  # Check strata distribution
  strata_counts <- data_with_strata %>%
    count(strata_group) %>%
    arrange(desc(n))
  
  cat("Total unique strata groups:", nrow(strata_counts), "\n")
  cat("Smallest stratum size:", min(strata_counts$n), "respondents\n")
  
  # Calculate total sample needed across all waves
  total_n <- nrow(data)
  max_sample_per_wave <- min(total_n * 0.25, 6000)  # Reduced since no overlap
  sample_sizes <- round(seq(min_sample_size, max_sample_per_wave, length.out = n_waves))
  total_sample_needed <- sum(sample_sizes)
  
  cat("Total respondents needed across all waves:", total_sample_needed, "\n")
  cat("Available respondents:", total_n, "\n")
  
  if(total_sample_needed > total_n) {
    # Adjust sample sizes if we don't have enough respondents
    reduction_factor <- total_n / total_sample_needed * 0.95  # 95% to be safe
    sample_sizes <- round(sample_sizes * reduction_factor)
    cat("⚠ Adjusted sample sizes to avoid overlap:", paste(sample_sizes, collapse = ", "), "\n")
  }
  
  cat("\n")
  
  # Create one large stratified sample that covers all waves
  cat("Creating stratified sample for all waves combined...\n")
  combined_sample_prop <- sum(sample_sizes) / total_n
  
  # Get stratified sample for all waves combined
  all_waves_data <- stratified(data_with_strata, 
                              group = "strata_group", 
                              size = combined_sample_prop,
                              select = list(strata_group = strata_counts$strata_group),
                              replace = FALSE)
  
  # Remove the temporary strata_group column
  all_waves_data <- all_waves_data %>% select(-strata_group)
  
  cat("Total stratified sample obtained:", nrow(all_waves_data), "respondents\n\n")
  
  # Now split this sample into waves while maintaining stratification
  # Add strata group back for splitting
  all_waves_data <- all_waves_data %>%
    mutate(strata_group = paste(age, gender, region, ethnicity, education, sep = "_"))
  
  # Create list to store waves
  mock_waves <- list()
  used_respondents <- character(0)  # Track used respondent IDs
  
  cat("Splitting stratified sample into", n_waves, "unique waves...\n\n")
  
  # Generate each wave by sampling from remaining respondents
  for (i in 1:n_waves) {
    
    cat("Generating Wave", i, "(", mock_months[i], ")...\n")
    
    # Get respondents not yet used
    remaining_data <- all_waves_data %>%
      filter(!respondent_id %in% used_respondents)
    
    cat("  - Remaining respondents available:", nrow(remaining_data), "\n")
    
    # Target sample size for this wave
    target_size <- sample_sizes[i]
    
    # If this is the last wave, use all remaining respondents (within reason)
    if(i == n_waves) {
      if(nrow(remaining_data) < target_size * 1.5) {
        target_size <- nrow(remaining_data)
      }
    }
    
    # Sample from remaining respondents with stratification
    if(nrow(remaining_data) >= target_size) {
      # Calculate sampling proportion for remaining data
      sample_prop_remaining <- min(target_size / nrow(remaining_data), 0.99)
      
      wave_data <- stratified(remaining_data, 
                             group = "strata_group", 
                             size = sample_prop_remaining,
                             replace = FALSE)
    } else {
      # Not enough remaining respondents, use all of them
      wave_data <- remaining_data
    }
    
    # Add wave identifier columns
    wave_data$survey_wave <- mock_months[i]
    wave_data$wave_number <- i
    
    # Add realistic date variation within the month
    base_date <- as.Date(paste0("2024-", sprintf("%02d", i+4), "-01"))  # May=5, June=6, etc.
    days_in_month <- sample(1:28, nrow(wave_data), replace = TRUE)
    wave_data$survey_date <- base_date + (days_in_month - 1)
    
    # Remove the temporary strata_group column
    wave_data <- wave_data %>% select(-strata_group)
    
    # Track used respondents
    used_respondents <- c(used_respondents, wave_data$respondent_id)
    
    # Store the wave
    mock_waves[[mock_months[i]]] <- wave_data
    
    actual_n <- nrow(wave_data)
    cat("  - Actual sample size:", actual_n, "respondents\n")
    cat("  - Target was:", sample_sizes[i], "\n")
    
    # Quick demographic check across all 5 weighting variables
    demo_check <- wave_data %>%
      summarise(
        pct_female = round(mean(gender == "female", na.rm = TRUE) * 100, 1),
        pct_young = round(mean(age %in% c("18_TO_24", "25_TO_34"), na.rm = TRUE) * 100, 1),
        pct_white = round(mean(ethnicity == "white", na.rm = TRUE) * 100, 1),
        pct_degree = round(mean(education == "high", na.rm = TRUE) * 100, 1),
        n_regions = n_distinct(region, na.rm = TRUE)
      )
    
    cat("  - Demographics: ", demo_check$pct_female, "% female, ", 
        demo_check$pct_young, "% young, ", 
        demo_check$pct_white, "% white, ",
        demo_check$pct_degree, "% degree, ",
        demo_check$n_regions, " regions\n\n")
  }
  
  # Validation check
  total_unique_used <- length(unique(used_respondents))
  total_observations <- sum(sapply(mock_waves, nrow))
  
  cat("✓ UNIQUE RESPONDENT VALIDATION:\n")
  cat("  - Total observations across waves:", total_observations, "\n")
  cat("  - Unique respondents used:", total_unique_used, "\n")
  cat("  - Perfect uniqueness:", ifelse(total_observations == total_unique_used, "YES", "NO"), "\n\n")
  
  cat("Stratified mock waves with UNIQUE respondents created successfully!\n")
  return(mock_waves)
}

# Function to save mock waves as separate files
save_mock_waves <- function(waves_list, output_dir = "./data/mock_waves/") {
  
  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
    cat("Created directory:", output_dir, "\n")
  }
  
  # Save each wave as separate file
  for (wave_name in names(waves_list)) {
    filename <- paste0(output_dir, "uk_election_wave_", wave_name, ".sav")
    write_sav(waves_list[[wave_name]], filename)
    cat("Saved:", filename, "\n")
  }
  
  # Also create a combined dataset with all waves
  combined_waves <- bind_rows(waves_list)
  combined_filename <- paste0(output_dir, "uk_election_all_waves_combined.sav")
  write_sav(combined_waves, combined_filename)
  cat("Saved combined dataset:", combined_filename, "\n")
  
  return(combined_waves)
}

# Function to create summary of mock waves
summarize_mock_waves <- function(waves_list) {
  
  cat("\n=== MOCK SURVEY WAVES SUMMARY ===\n\n")
  
  # Create summary table
  summary_df <- map_dfr(waves_list, function(wave) {
    # Check if wave columns exist
    wave_name <- if("survey_wave" %in% colnames(wave)) unique(wave$survey_wave)[1] else "Unknown"
    wave_num <- if("wave_number" %in% colnames(wave)) unique(wave$wave_number)[1] else NA
    date_info <- if("survey_date" %in% colnames(wave)) paste(min(wave$survey_date), "to", max(wave$survey_date)) else "No dates"
    
    # Calculate demographics safely
    mean_age_val <- NA
    if("exact_age" %in% colnames(wave)) {
      mean_age_val <- round(mean(wave$exact_age, na.rm = TRUE), 1)
    }
    
    pct_female_val <- if("gender" %in% colnames(wave)) round(mean(wave$gender == "female", na.rm = TRUE) * 100, 1) else NA
    pct_degree_val <- if("education" %in% colnames(wave)) round(mean(wave$education == "high", na.rm = TRUE) * 100, 1) else NA
    
    tibble(
      wave = wave_name,
      wave_number = wave_num,
      n_respondents = nrow(wave),
      date_range = date_info,
      mean_age = mean_age_val,
      pct_female = pct_female_val,
      pct_degree = pct_degree_val
    )
  })
  
  print(summary_df)
  
  # Enhanced validation - check for overlap between waves (should be ZERO)
  all_ids <- map(waves_list, ~.x$respondent_id)
  cat("\n=== UNIQUE RESPONDENT VALIDATION ===\n")
  
  # Check overlaps between all wave pairs
  overlaps_found <- FALSE
  for (i in 1:(length(all_ids)-1)) {
    for (j in (i+1):length(all_ids)) {
      overlap <- length(intersect(all_ids[[i]], all_ids[[j]]))
      if(overlap > 0) {
        cat("⚠ Wave", i, "vs Wave", j, ":", overlap, "shared respondents\n")
        overlaps_found <- TRUE
      }
    }
  }
  
  # Summary validation
  total_observations <- sum(sapply(waves_list, nrow))
  unique_respondents <- length(unique(unlist(all_ids)))
  
  cat("Total observations across all waves:", total_observations, "\n")
  cat("Unique respondents across all waves:", unique_respondents, "\n")
  
  if(!overlaps_found && total_observations == unique_respondents) {
    cat("✓ SUCCESS: Perfect uniqueness - no respondent appears in multiple waves!\n")
  } else if(overlaps_found) {
    cat("⚠ WARNING: Respondent overlap detected between waves\n")
  } else {
    cat("⚠ WARNING: Unexpected respondent count mismatch\n")
  }
  
  return(summary_df)
}

# Enhanced validation function for demographic stratification
validate_stratification <- function(original_data, waves_list) {
  
  cat("\n=== STRATIFICATION VALIDATION ===\n\n")
  
  # Get original proportions across all 5 weighting variables
  original_props <- original_data %>%
    summarise(
      pct_female = round(mean(gender == "female", na.rm = TRUE) * 100, 1),
      pct_young = round(mean(age %in% c("18_TO_24", "25_TO_34"), na.rm = TRUE) * 100, 1),
      pct_older = round(mean(age %in% c("65_TO_74", "75_PLUS"), na.rm = TRUE) * 100, 1),
      pct_white = round(mean(ethnicity == "white", na.rm = TRUE) * 100, 1),
      pct_degree = round(mean(education == "high", na.rm = TRUE) * 100, 1),
      n_regions = n_distinct(region)
    )
  
  cat("Original Dataset Demographics (5 Weighting Variables):\n")
  cat("- Female:", original_props$pct_female, "%\n")
  cat("- Young adults (18-34):", original_props$pct_young, "%\n") 
  cat("- Older adults (65+):", original_props$pct_older, "%\n")
  cat("- White ethnicity:", original_props$pct_white, "%\n")
  cat("- High education:", original_props$pct_degree, "%\n")
  cat("- Regions represented:", original_props$n_regions, "\n\n")
  
  # Check each wave
  cat("Wave-by-Wave Demographic Comparison:\n")
  
  wave_validation <- map_dfr(names(waves_list), function(wave_name) {
    wave_data <- waves_list[[wave_name]]
    
    wave_props <- wave_data %>%
      summarise(
        wave = wave_name,
        n = nrow(wave_data),
        pct_female = round(mean(gender == "female", na.rm = TRUE) * 100, 1),
        pct_young = round(mean(age %in% c("18_TO_24", "25_TO_34"), na.rm = TRUE) * 100, 1),
        pct_older = round(mean(age %in% c("65_TO_74", "75_PLUS"), na.rm = TRUE) * 100, 1),
        pct_white = round(mean(ethnicity == "white", na.rm = TRUE) * 100, 1),
        pct_degree = round(mean(education == "high", na.rm = TRUE) * 100, 1),
        n_regions = n_distinct(region)
      ) %>%
      mutate(
        female_diff = pct_female - original_props$pct_female,
        young_diff = pct_young - original_props$pct_young,
        older_diff = pct_older - original_props$pct_older,
        white_diff = pct_white - original_props$pct_white,
        degree_diff = pct_degree - original_props$pct_degree
      )
    
    return(wave_props)
  })
  
  print(wave_validation)
  
  # Summary of differences across all 5 weighting variables
  max_diffs <- wave_validation %>%
    summarise(
      max_female_diff = max(abs(female_diff)),
      max_young_diff = max(abs(young_diff)), 
      max_older_diff = max(abs(older_diff)),
      max_white_diff = max(abs(white_diff)),
      max_degree_diff = max(abs(degree_diff))
    )
  
  cat("\nMaximum demographic deviations from original (all 5 weighting variables):\n")
  cat("- Female %: ±", max_diffs$max_female_diff, " percentage points\n")
  cat("- Young adults %: ±", max_diffs$max_young_diff, " percentage points\n")
  cat("- Older adults %: ±", max_diffs$max_older_diff, " percentage points\n")
  cat("- White ethnicity %: ±", max_diffs$max_white_diff, " percentage points\n")
  cat("- High education %: ±", max_diffs$max_degree_diff, " percentage points\n")
  
  # Check if all variables are within acceptable limits
  all_vars_excellent <- all(c(max_diffs$max_female_diff, max_diffs$max_young_diff, 
                              max_diffs$max_older_diff, max_diffs$max_white_diff, 
                              max_diffs$max_degree_diff) < 2)
  
  all_vars_good <- all(c(max_diffs$max_female_diff, max_diffs$max_young_diff, 
                         max_diffs$max_older_diff, max_diffs$max_white_diff, 
                         max_diffs$max_degree_diff) < 5)
  
  if(all_vars_excellent) {
    cat("\n✓ EXCELLENT: All waves maintain demographic proportions within 2 percentage points across all 5 weighting variables\n")
  } else if(all_vars_good) {
    cat("\n✓ GOOD: All waves maintain demographic proportions within 5 percentage points across all 5 weighting variables\n")
  } else {
    cat("\n⚠ WARNING: Some waves have significant demographic deviations in one or more weighting variables\n")
  }
  
  return(wave_validation)
}

# Main execution function
generate_mock_survey_waves <- function(save_files = TRUE) {
  
  cat("=== STRATIFIED MOCK SURVEY WAVE GENERATOR ===\n")
  cat("Generating 4 waves with maintained demographic proportions\n")
  cat("Stratification variables: age, gender, region, ethnicity, education\n\n")
  
  # Create the stratified waves
  mock_waves <- create_mock_waves(uk_data, n_waves = 4)
  
  # Generate summary with demographic validation
  summary <- summarize_mock_waves(mock_waves)
  validation <- validate_stratification(uk_data, mock_waves)
  
  # Save files if requested
  if (save_files) {
    cat("\nSaving mock wave files...\n")
    combined_data <- save_mock_waves(mock_waves)
    cat("\nAll files saved successfully!\n")
  }
  
  # Return comprehensive results
  return(list(
    waves = mock_waves,
    summary = summary,
    validation = validation,
    combined = if(save_files) bind_rows(mock_waves) else NULL
  ))
}

# Usage
generate_mock_survey_waves()
