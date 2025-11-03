# Analysis Methods Documentation

## Study Design

-   **Type**: Retrospective cohort study
-   **Population**: Patients with non-severe community-acquired pneumonia
-   **Intervention**: Five different antibiotic treatment regimens
-   **Outcomes**: Clinical efficacy, laboratory parameters, cost

## Statistical Methods

### Descriptive Statistics

-   Continuous variables: Mean (SD) and Median (IQR)
-   Categorical variables: Frequency (percentage)
-   Group comparisons using TableOne package

### Inferential Statistics

-   **Continuous variables**: ANOVA with post-hoc SNK test
-   **Categorical variables**: Chi-square or Fisher's exact test
-   **Multiple comparisons**: False Discovery Rate (FDR) correction

### Regression Models

-   **Linear regression**: For continuous outcomes (laboratory parameters, cost, duration)
-   **Multinomial regression**: For categorical outcomes with \>2 levels
-   **Generalized Estimating Equations (GEE)**: For longitudinal data

### Covariate Adjustment

Models adjusted for: - Age - Sex\
- Baseline laboratory values (CRP1, CR1, N1)

## Variable Definitions

### Treatment Groups

-   Group A: Moxifloxacin
-   Group B: Cefoperazone-Sulbactam
-   Group C: Levofloxacin\
-   Group D: Piperacillin-Tazobactam
-   Group E: Ceftazidime

### Outcome Variables

-   **Primary**: Clinical efficacy (effect1)
-   **Secondary**:
    -   Microbiological efficacy (effect2)
    -   Laboratory parameters (CRP, WBC, neutrophils, creatinine)
    -   Treatment duration (days)
    -   Hospitalization cost (cost_10k)

### Time Points

-   T1/CRP1/WBC1/etc.: Admission
-   T2/CRP2/WBC2/etc.: Day 3 of treatment\
-   T3/CRP3/WBC3/etc.: Discharge
