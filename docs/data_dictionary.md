# Data Dictionary

## Demographic Variables

| Variable | Description        | Type    | Values           |
|----------|--------------------|---------|------------------|
| number   | Patient identifier | Numeric | Unique ID        |
| age      | Patient age        | Numeric | Years            |
| sex      | Patient sex        | Factor  | 0=Male, 1=Female |

## Diagnosis Variables

| Variable        | Description             | Type   | Values                  |
|-----------------|-------------------------|--------|-------------------------|
| diagnosis       | Original diagnosis code | Factor | Numeric codes           |
| diagnosis_group | Grouped diagnosis       | Factor | Group_1, Group_2, Other |

## Laboratory Variables

| Variable       | Description            | Type    | Units   |
|----------------|------------------------|---------|---------|
| T1/T2/T3       | Temperature            | Numeric | °C      |
| CRP1/CRP2/CRP3 | C-reactive protein     | Numeric | mg/L    |
| WBC1/WBC2/WBC3 | White blood cell count | Numeric | 10\^9/L |
| N1/N2/N3       | Neutrophil percentage  | Numeric | \%      |
| CR1/CR2/CR3    | Creatinine             | Numeric | μmol/L  |

## Outcome Variables

| Variable | Description              | Type    | Values      |
|----------|--------------------------|---------|-------------|
| effect1  | Clinical efficacy        | Factor  | 0, 1, 2     |
| effect2  | Microbiological efficacy | Factor  | 0, 1, 2     |
| days     | Treatment duration       | Numeric | Days        |
| cost     | Total cost               | Numeric | Yuan        |
| cost_10k | Cost in 10,000 units     | Numeric | 10,000 Yuan |

## Treatment Variable

| Variable        | Description                  | Type   | Values             |
|-----------------|------------------------------|--------|--------------------|
| ways            | Original treatment group     | Factor | A, B, C, D, E      |
| treatment_group | Standardized treatment group | Factor | Group_A to Group_E |
