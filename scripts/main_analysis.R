# Main Analysis Script - Pneumonia Antibiotics Study
# This is the main script that runs the complete analysis pipeline

cat("=========================================\n")
cat("Pneumonia Antibiotics Treatment Analysis\n")
cat("=========================================\n\n")

# Record start time
start_time <- Sys.time()
cat("Analysis started at:", as.character(start_time), "\n\n")

# Load required packages
cat("1. Loading required packages...\n")
source("requirements.R")
cat("✓ Packages loaded successfully\n\n")

# Create output directories if they don't exist
cat("2. Setting up output directories...\n")
dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("output/results", recursive = TRUE, showWarnings = FALSE)
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
cat("✓ Output directories created\n\n")

# Run analysis scripts in order
tryCatch({
  cat("3. Loading and cleaning data...\n")
  source("scripts/01_data_cleaning.R")
  cat("✓ Data cleaning completed\n\n")
  
  cat("4. Running descriptive analysis...\n")
  source("scripts/02_descriptive_analysis.R")
  cat("✓ Descriptive analysis completed\n\n")
  
  cat("5. Performing statistical analysis...\n")
  source("scripts/03_statistical_analysis.R")
  cat("✓ Statistical analysis completed\n\n")
  
  cat("6. Generating visualizations...\n")
  source("scripts/04_visualization.R")
  cat("✓ Visualizations completed\n\n")
  
  # Save processed data
  cat("7. Saving processed data...\n")
  saveRDS(pneumonia_data, "data/processed/pneumonia_analysis_data.rds")
  cat("✓ Processed data saved\n\n")
  
  # Analysis summary
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units = "mins"), 1)
  
  cat("=========================================\n")
  cat("ANALYSIS COMPLETED SUCCESSFULLY!\n")
  cat("Duration:", duration, "minutes\n")
  cat("Results saved in output/ directory\n")
  cat("=========================================\n")
  
}, error = function(e) {
  cat("❌ ERROR in analysis:\n")
  cat(e$message, "\n")
  cat("Analysis stopped due to errors.\n")
})