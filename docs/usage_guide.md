# Usage Guide

## Quick Start

1.  Place your data file in `data/raw/non_severe_cap_data.xlsx`
2.  Run the complete analysis: `source("scripts/main_analysis.R")`
3.  Check `output/` folder for results

## Step-by-Step Analysis

### Data Preparation

\`\`\`r \# Install required packages source("requirements.R")

# Load and clean data

source("scripts/01_data_cleaning.R")
