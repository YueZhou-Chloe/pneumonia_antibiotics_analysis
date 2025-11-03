# Descriptive Analysis for Pneumonia Antibiotics Study
# This script generates descriptive statistics and Table 1

library(tidyverse)
library(tableone)
library(clipr)

descriptive_analysis <- function(data) {
  
  # Define analysis variables
  demographic_vars <- c("sex", "age", "diagnosis_group")
  baseline_labs <- c("T1", "CRP1", "WBC1", "N1", "CR1")
  followup_labs <- c("T2", "CRP2", "WBC2", "N2", "CR2", 
                     "T3", "CRP3", "WBC3", "N3", "CR3")
  outcome_vars <- c("cost_10k", "days", "effect1", "effect2")
  
  all_vars <- c(demographic_vars, baseline_labs, followup_labs, outcome_vars)
  
  # Create Table 1 - Mean (SD)
  cat("Creating Table 1 - Mean (SD)...\n")
  table1_mean <- CreateTableOne(
    vars = all_vars, 
    strata = "treatment_group", 
    data = data,
    factorVars = c("sex", "diagnosis_group", "effect1", "effect2"),
    includeNA = FALSE, 
    addOverall = TRUE
  )
  
  # Print and export table
  table1_mean_df <- print(table1_mean, noSpaces = TRUE, showAllLevels = TRUE) %>% 
    as.data.frame()
  
  # Create Table 1 - Median (IQR) for non-normal variables
  cat("Creating Table 1 - Median (IQR)...\n")
  non_normal_vars <- c("age", baseline_labs, followup_labs, "cost_10k", "days")
  
  table1_median <- CreateTableOne(
    vars = all_vars, 
    strata = "treatment_group", 
    data = data,
    factorVars = c("sex", "diagnosis_group", "effect1", "effect2"),
    includeNA = FALSE, 
    addOverall = TRUE
  )
  
  table1_median_df <- print(
    table1_median, 
    noSpaces = TRUE, 
    showAllLevels = TRUE,
    nonnormal = non_normal_vars
  ) %>% as.data.frame()
  
  # Export tables
  write_clip(table1_mean_df, sep = "\t")
  cat("Table 1 (Mean) copied to clipboard.\n")
  
  write_clip(table1_median_df, sep = "\t") 
  cat("Table 1 (Median) copied to clipboard.\n")
  
  # Basic dataset characteristics
  cat("\nDataset Characteristics:\n")
  cat("Total patients:", nrow(data), "\n")
  cat("Treatment group distribution:\n")
  print(table(data$treatment_group))
  
  return(list(
    table1_mean = table1_mean_df,
    table1_median = table1_median_df
  ))
}

# Run analysis if data exists
if (exists("pneumonia_data")) {
  descriptive_results <- descriptive_analysis(pneumonia_data$full_data)
}