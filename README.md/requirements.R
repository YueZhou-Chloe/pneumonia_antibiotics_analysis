# Required R packages for Pneumonia Antibiotics Analysis Project
# Install missing packages by running: source("requirements.R")

required_packages <- c(
  "tidyverse",      # Data manipulation and visualization
  "haven",          # Import data files
  "tableone",       # Create table one
  "epiDisplay",     # Epidemiological displays
  "nnet",           # Multinomial regression
  "MASS",           # Statistical functions
  "rms",            # Regression modeling
  "gtsummary",      # Summary tables
  "mice",           # Multiple imputation
  "agricolae",      # Agricultural statistical analysis
  "corrplot",       # Correlation plots
  "geepack",        # Generalized estimating equations
  "ggpubr",         # ggplot2 extensions
  "cowplot",        # Plot arrangements
  "clipr",          # Clipboard operations
  "readxl"          # Excel file reading
)

# Check and install missing packages
new_packages <- required_packages[!required_packages %in% installed.packages()[,"Package"]]

if(length(new_packages)) {
  install.packages(new_packages)
}

cat("All required packages are installed.\n")