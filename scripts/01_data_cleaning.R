# Data Cleaning Script for Pneumonia Antibiotics Analysis
# This script loads and cleans the raw data

# Load required packages
library(tidyverse)
library(readxl)
library(tableone)

# Function to load and clean data
load_and_clean_data <- function(data_path) {
  # Load data
  data <- readxl::read_xlsx(data_path, sheet = "FINAL")
  
  cat("Original data dimensions:", dim(data), "\n")
  
  # Convert data types
  data$age <- as.numeric(data$age)
  categorical_vars <- c("sex", "diagnosis", "effect1", "effect2", "ways")
  data[categorical_vars] <- lapply(data[categorical_vars], as.factor)
  
  # Recode diagnosis variable with complete cases
  data <- data %>%
    mutate(
      diagnosis_group = case_when(
        diagnosis %in% c(0,1,3,4,5,6,9,10,11,12,13,14,15,19,20,21,26,27,28,29,30,31,32,34,35,36,37,38,39) ~ "Group_1",
        diagnosis %in% c(2,7,8,23,25,34,41,50,53,59,67,73) ~ "Group_2",
        diagnosis %in% c(17,42,43,44,54,58,61,64,68,77) ~ "Group_2",
        diagnosis %in% c(40,46,71) ~ "Group_2",
        diagnosis %in% c(45,47,49,52,63,65,69,76) ~ "Group_2",
        diagnosis %in% c(24,48,55,56,57,60,62,70,72,78) ~ "Group_2",
        diagnosis %in% c(16,66) ~ "Group_2",
        diagnosis %in% c(18,22,51,74) ~ "Group_2",
        TRUE ~ "Other"
      ) %>% as.factor()
    )
  
  # Convert cost to 10,000 yuan units
  data$cost_10k <- data$cost / 10000
  
  # Standardize treatment group names
  data <- data %>%
    mutate(
      treatment_group = case_when(
        ways %in% c("D") ~ "Group_A",
        ways %in% c("A") ~ "Group_D", 
        ways %in% c("B") ~ "Group_B",
        ways %in% c("C") ~ "Group_C",
        ways %in% c("E") ~ "Group_E",
        TRUE ~ as.character(ways)
      ) %>% as.factor()
    )
  
  # Create complete cases dataset
  complete_cases <- data %>%
    filter(!is.na(treatment_group) & !is.na(CRP2) & !is.na(WBC2) & !is.na(N2) & 
             !is.na(CR2) & !is.na(AB2) & !is.na(CR3) & !is.na(CRP3) & 
             !is.na(effect1) & !is.na(CRP1))
  
  cat("Complete cases dimensions:", dim(complete_cases), "\n")
  
  # Data quality check
  cat("\nData Quality Check:\n")
  cat("Missing data percentage:\n")
  missing_summary <- round(sapply(data, function(x) sum(is.na(x))/length(x)) * 100, 2)
  print(missing_summary[missing_summary > 0])
  
  return(list(
    full_data = data,
    complete_data = complete_cases
  ))
}

# Main execution
if (!exists("pneumonia_data")) {
  pneumonia_data <- load_and_clean_data("data/raw/non_severe_cap_data.xlsx")
}

cat("Data cleaning completed successfully.\n")