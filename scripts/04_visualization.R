# Visualization Script for Pneumonia Antibiotics Study
# This script creates all figures and plots

library(tidyverse)
library(ggplot2)
library(ggpubr)
library(cowplot)
library(corrplot)

create_visualizations <- function(data) {
  
  analysis_data <- data$complete_data
  
  cat("Creating visualizations...\n")
  
  # 1. Laboratory parameter trends over time
  cat("1. Creating laboratory parameter trend plots...\n")
  
  # CRP trends
  crp_long <- analysis_data %>%
    select(number, treatment_group, CRP1, CRP2, CRP3) %>%
    pivot_longer(
      cols = starts_with("CRP"),
      names_to = "time_point",
      values_to = "crp_value",
      names_prefix = "CRP"
    ) %>%
    mutate(
      time_point = factor(time_point, 
                          levels = c(1, 2, 3),
                          labels = c("Admission", "Day 3", "Discharge")),
      treatment_group = recode(treatment_group,
                               "Group_A" = "Moxifloxacin",
                               "Group_B" = "Cefoperazone-Sulbactam", 
                               "Group_C" = "Levofloxacin",
                               "Group_D" = "Piperacillin-Tazobactam",
                               "Group_E" = "Ceftazidime")
    )
  
  p_crp_trend <- ggplot(crp_long, 
                        aes(x = time_point, y = crp_value, 
                            group = interaction(number, treatment_group), 
                            color = treatment_group)) + 
    stat_summary(
      aes(group = treatment_group, color = treatment_group), 
      fun = median, 
      geom = "line", 
      size = 1.2, 
      alpha = 0.8
    ) +
    labs(
      title = "CRP Trends by Treatment Group",
      x = "Time Point",
      y = "CRP (mg/L)",
      color = "Antibiotic Group"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold"),
      legend.position = "right"
    )
  
  # 2. Boxplots for laboratory parameters
  cat("2. Creating boxplots...\n")
  
  p_crp_box <- ggboxplot(crp_long, 
                         x = "time_point", 
                         y = "crp_value", 
                         color = "treatment_group",
                         palette = "jco") +
    labs(
      x = "",
      y = "CRP (mg/L)",
      color = "Antibiotic Group"
    ) +
    theme(
      axis.text = element_text(size = 10),
      legend.title = element_text(size = 11)
    )
  
  # Add statistical comparisons
  my_comparisons <- list( 
    c("Admission", "Day 3"), 
    c("Admission", "Discharge"), 
    c("Day 3", "Discharge")
  )
  
  p_crp_box_stats <- p_crp_box + 
    stat_compare_means(
      comparisons = my_comparisons,
      method = "wilcox.test",
      label = "p.signif",
      size = 3
    )
  
  # 3. Create similar plots for other parameters
  # Temperature trends
  temp_long <- analysis_data %>%
    select(number, treatment_group, T1, T2, T3) %>%
    pivot_longer(
      cols = starts_with("T"),
      names_to = "time_point",
      values_to = "temp_value",
      names_prefix = "T"
    ) %>%
    mutate(
      time_point = factor(time_point, 
                          levels = c(1, 2, 3),
                          labels = c("Admission", "Day 3", "Discharge")),
      treatment_group = recode(treatment_group,
                               "Group_A" = "Moxifloxacin",
                               "Group_B" = "Cefoperazone-Sulbactam", 
                               "Group_C" = "Levofloxacin",
                               "Group_D" = "Piperacillin-Tazobactam",
                               "Group_E" = "Ceftazidime")
    )
  
  p_temp_trend <- ggplot(temp_long, 
                         aes(x = time_point, y = temp_value, 
                             group = treatment_group, 
                             color = treatment_group)) + 
    stat_summary(
      aes(group = treatment_group, color = treatment_group), 
      fun = mean, 
      geom = "line", 
      size = 1.2
    ) +
    labs(
      title = "Temperature Trends by Treatment Group",
      x = "Time Point",
      y = "Temperature (°C)",
      color = "Antibiotic Group"
    ) +
    theme_minimal()
  
  # 4. Cost comparison
  p_cost <- ggboxplot(analysis_data, 
                      x = "treatment_group", 
                      y = "cost_10k",
                      fill = "treatment_group",
                      palette = "Set2") +
    labs(
      title = "Treatment Cost Comparison",
      x = "Treatment Group",
      y = "Cost (10,000 Yuan)"
    ) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  # 5. Correlation matrix
  cat("3. Creating correlation matrix...\n")
  
  # Select numeric variables for correlation
  numeric_vars <- analysis_data %>%
    select(age, T1, CRP1, WBC1, N1, CR1, 
           T2, CRP2, WBC2, N2, CR2,
           T3, CRP3, WBC3, N3, CR3,
           cost_10k, days) %>%
    select(where(is.numeric))
  
  # Calculate correlations
  correlation_matrix <- cor(numeric_vars, use = "pairwise.complete.obs", method = "spearman")
  
  # Create correlation plot
  png("output/figures/correlation_matrix.png", width = 10, height = 8, units = "in", res = 300)
  corrplot(correlation_matrix, 
           method = "color",
           type = "upper",
           order = "hclust",
           tl.cex = 0.8,
           tl.col = "black",
           addCoef.col = "black",
           number.cex = 0.6)
  dev.off()
  
  # 6. Treatment group distribution
  p_treatment_dist <- analysis_data %>%
    count(treatment_group) %>%
    ggplot(aes(x = reorder(treatment_group, n), y = n, fill = treatment_group)) +
    geom_col() +
    coord_flip() +
    labs(
      title = "Patient Distribution by Treatment Group",
      x = "Treatment Group",
      y = "Number of Patients"
    ) +
    theme_minimal() +
    theme(legend.position = "none")
  
  # 7. Combine key plots
  cat("4. Combining plots...\n")
  
  # Trend plots combined
  trend_plots <- ggarrange(p_crp_trend, p_temp_trend, 
                           ncol = 2, nrow = 1,
                           common.legend = TRUE,
                           legend = "right")
  
  # Save individual plots
  ggsave("output/figures/crp_trends.png", p_crp_trend, width = 10, height = 6, dpi = 300)
  ggsave("output/figures/temperature_trends.png", p_temp_trend, width = 10, height = 6, dpi = 300)
  ggsave("output/figures/cost_comparison.png", p_cost, width = 8, height = 6, dpi = 300)
  ggsave("output/figures/treatment_distribution.png", p_treatment_dist, width = 8, height = 6, dpi = 300)
  ggsave("output/figures/combined_trends.png", trend_plots, width = 12, height = 6, dpi = 300)
  
  cat("Visualizations completed and saved to output/figures/\n")
  
  return(list(
    crp_trend = p_crp_trend,
    temp_trend = p_temp_trend,
    cost_plot = p_cost,
    treatment_dist = p_treatment_dist,
    combined_trends = trend_plots
  ))
}

# Create visualizations
if (exists("pneumonia_data")) {
  visualization_results <- create_visualizations(pneumonia_data)
}