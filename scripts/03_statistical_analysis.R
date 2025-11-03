# Statistical Analysis for Pneumonia Antibiotics Study
# This script performs inferential statistics and modeling

library(tidyverse)
library(agricolae)
library(nnet)
library(geepack)
library(MASS)

statistical_analysis <- function(data) {
  
  # Use complete cases for analysis
  analysis_data <- data$complete_data
  
  cat("Starting statistical analysis with", nrow(analysis_data), "complete cases.\n")
  
  # 1. Pairwise comparisons for continuous variables
  continuous_vars <- c("T2", "CRP2", "WBC2", "N2", "CR2", 
                       "T3", "CRP3", "WBC3", "N3", "CR3", 
                       "cost_10k", "days")
  
  cat("\n1. Pairwise comparisons for continuous variables...\n")
  
  pairwise_results <- data.frame()
  
  for (var in continuous_vars) {
    # ANOVA with post-hoc SNK test
    anova_model <- aov(as.formula(paste(var, "~ treatment_group")), data = analysis_data)
    snk_test <- SNK.test(anova_model, trt = "treatment_group", group = FALSE)
    
    # Extract p-values
    p_values <- snk_test$comparison$pvalue
    comparisons <- rownames(snk_test$comparison)
    
    # Store results
    for (i in seq_along(comparisons)) {
      pairwise_results <- rbind(pairwise_results, data.frame(
        variable = var,
        comparison = comparisons[i],
        p_value = p_values[i]
      ))
    }
  }
  
  # Apply FDR correction
  pairwise_results$p_fdr <- p.adjust(pairwise_results$p_value, method = "fdr")
  
  cat("Continuous variable comparisons completed.\n")
  
  # 2. Categorical variable comparisons
  categorical_vars <- c("effect1", "effect2")
  
  cat("\n2. Categorical variable comparisons...\n")
  
  categorical_results <- list()
  
  for (var in categorical_vars) {
    # Create all possible group pairs
    groups <- unique(analysis_data$treatment_group)
    group_pairs <- combn(groups, 2, simplify = FALSE)
    
    var_results <- list()
    
    for (pair in group_pairs) {
      group1 <- pair[1]
      group2 <- pair[2]
      
      # Subset data for this pair
      subset_data <- analysis_data %>% 
        filter(treatment_group %in% c(group1, group2)) %>% 
        select(all_of(var), treatment_group)
      
      # Create contingency table
      contingency_table <- table(subset_data[[var]], subset_data$treatment_group)
      
      # Choose appropriate test
      if (sum(contingency_table) > 20 && all(contingency_table >= 5)) {
        test_result <- chisq.test(contingency_table)
        test_method <- "Chi-square"
      } else {
        test_result <- fisher.test(contingency_table)
        test_method <- "Fisher exact"
      }
      
      # Store results
      comparison_name <- paste(group1, "vs", group2)
      var_results[[comparison_name]] <- list(
        p_value = test_result$p.value,
        method = test_method
      )
    }
    
    categorical_results[[var]] <- var_results
  }
  
  cat("Categorical variable comparisons completed.\n")
  
  # 3. Regression analyses
  cat("\n3. Running regression analyses...\n")
  
  # Continuous outcomes
  continuous_outcomes <- c("T3", "CRP3", "WBC3", "N3", "CR3", "cost_10k", "days")
  regression_results <- data.frame()
  
  for (outcome in continuous_outcomes) {
    # Model with adjustment for covariates
    formula <- as.formula(paste(outcome, "~ treatment_group + age + sex + CRP1 + CR1 + N1"))
    model <- lm(formula, data = analysis_data)
    
    model_summary <- summary(model)
    
    # Extract coefficients for treatment groups (excluding reference)
    treatment_coefs <- model_summary$coefficients[grep("treatment_group", rownames(model_summary$coefficients)), ]
    
    for (i in 1:nrow(treatment_coefs)) {
      coef_name <- rownames(treatment_coefs)[i]
      beta <- treatment_coefs[i, "Estimate"]
      se <- treatment_coefs[i, "Std. Error"]
      p_value <- treatment_coefs[i, "Pr(>|t|)"]
      ci_lower <- beta - 1.96 * se
      ci_upper <- beta + 1.96 * se
      
      regression_results <- rbind(regression_results, data.frame(
        outcome = outcome,
        predictor = coef_name,
        beta = beta,
        se = se,
        ci_lower = ci_lower,
        ci_upper = ci_upper,
        p_value = p_value
      ))
    }
  }
  
  cat("Regression analyses completed.\n")
  
  # 4. Multinomial outcomes
  cat("\n4. Analyzing multinomial outcomes...\n")
  
  multinomial_vars <- c("effect1", "effect2")
  multinomial_results <- data.frame()
  
  for (var in multinomial_vars) {
    # Set reference level
    analysis_data$treatment_group <- relevel(analysis_data$treatment_group, ref = "Group_A")
    
    # Multinomial model
    formula <- as.formula(paste(var, "~ treatment_group"))
    model <- multinom(formula, data = analysis_data)
    
    # Extract ORs and CIs
    or_values <- exp(coef(model))
    ci_values <- exp(confint(model))
    
    # Format results
    # Note: This is simplified - you may need to adjust based on your specific needs
    for (i in 1:nrow(or_values)) {
      for (j in 1:ncol(or_values)) {
        multinomial_results <- rbind(multinomial_results, data.frame(
          outcome = var,
          treatment_comparison = paste(rownames(or_values)[i], "vs", colnames(or_values)[j]),
          OR = or_values[i, j],
          CI_lower = ci_values[i, j, 1],
          CI_upper = ci_values[i, j, 2]
        ))
      }
    }
  }
  
  cat("Multinomial analyses completed.\n")
  
  # 5. Return all results
  return(list(
    pairwise_continuous = pairwise_results,
    categorical_comparisons = categorical_results,
    regression_results = regression_results,
    multinomial_results = multinomial_results
  ))
}

# Run statistical analysis
if (exists("pneumonia_data")) {
  statistical_results <- statistical_analysis(pneumonia_data)
  cat("Statistical analysis completed successfully.\n")
  
  # Save results
  saveRDS(statistical_results, "output/results/statistical_analysis_results.rds")
  write_csv(statistical_results$pairwise_continuous, "output/tables/pairwise_comparisons.csv")
  write_csv(statistical_results$regression_results, "output/tables/regression_results.csv")
}