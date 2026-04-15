# Exploratory Data Analysis (EDA) and Visualization Notes

These notes provide a comprehensive framework and practical examples for conducting Exploratory Data Analysis (EDA) and creating impactful visualizations in data science interviews.

## 1. Introduction to EDA

Exploratory Data Analysis (EDA) is the first and arguably the most crucial step in the data science lifecycle. It involves analyzing and summarizing datasets to uncover patterns, detect anomalies, test hypotheses, and check assumptions using statistical summaries and graphical representations.

### Key Objectives of EDA:
- Maximize insights into a dataset.
- Uncover underlying structures and relationships.
- Extract important variables.
- Detect outliers and anomalies.
- Test underlying assumptions.

---

## 2. Univariate Analysis

Univariate analysis explores one variable at a time to understand its distribution and central tendency.

### 2.1 Numerical Variables
For continuous or discrete numerical data, the focus is on standard statistical measures and distribution shape.

**Descriptive Statistics:**
```python
import pandas as pd
import numpy as np

# Assuming 'df' is the DataFrame and 'salary' is a numerical column
print(df['salary'].describe())

# Measures of shape
print("Skewness:", df['salary'].skew()) # >0 Right skew, <0 Left skew
print("Kurtosis:", df['salary'].kurt()) # >3 Leptokurtic (peaked), <3 Platykurtic (flat)
```

**Common Visualizations:**
- **Histograms:** Display the frequency distribution.
- **Boxplots:** Highlight quartiles, median, and outliers.
- **KDE (Kernel Density Estimation):** Smooth line showing the probability density function.

```python
import seaborn as sns
import matplotlib.pyplot as plt

plt.figure(figsize=(12, 5))

# Histogram with KDE
plt.subplot(1, 2, 1)
sns.histplot(df['salary'], bins=30, kde=True, color='blue')
plt.title('Distribution of Salary')

# Boxplot
plt.subplot(1, 2, 2)
sns.boxplot(x=df['salary'], color='lightgreen')
plt.title('Boxplot of Salary')

plt.tight_layout()
plt.show()
```

### 2.2 Categorical Variables
For categorical data, the focus is on frequencies and proportions.

**Analysis:**
```python
# Absolute frequencies
print(df['department'].value_counts())

# Relative frequencies (proportions)
print(df['department'].value_counts(normalize=True) * 100)
```

**Common Visualizations:**
- **Bar Charts:** Show counts of each category.
- **Pie Charts:** Show parts of a whole (use sparingly, bar charts are generally preferred).

```python
# Count plot (Bar chart)
plt.figure(figsize=(8, 5))
sns.countplot(y='department', data=df, order=df['department'].value_counts().index)
plt.title('Employee Count by Department')
plt.show()
```

---

## 3. Bivariate and Multivariate Analysis

This analysis explores the relationship between two or more variables. This is where most actionable insights usually reside.

### 3.1 Numerical vs. Numerical
**Objective:** Find correlations and linear/non-linear relationships.

- **Scatter Plots:** The primary tool for two continuous variables.
- **Hexbin Plots or 2D Histograms:** Better than scatter plots when the dataset is very large (overplotting).

```python
plt.figure(figsize=(8, 5))
sns.scatterplot(x='years_experience', y='salary', data=df, hue='department')
plt.title('Salary vs. Experience')
plt.show()
```

### 3.2 Categorical vs. Numerical
**Objective:** Compare numerical distributions across different categories.

- **Grouped Boxplots or Violin Plots:** Show the distribution of a numerical variable for each category level.
- **Bar Plots with Error Bars:** Show the mean and confidence intervals.

```python
plt.figure(figsize=(10, 6))
# Boxplot
sns.boxplot(x='department', y='salary', data=df)
# Add Swarmplot to see individual data points (on top of boxplot)
sns.swarmplot(x='department', y='salary', data=df, color=".25", alpha=0.6)
plt.title('Salary Distribution Across Departments')
plt.xticks(rotation=45)
plt.show()
```

### 3.3 Categorical vs. Categorical
**Objective:** Look for associations between two categorical variables.

- **Cross-tabulation (Crosstab):** Calculate frequencies of combinations of categories.
- **Stacked or Grouped Bar Charts:** Visualize the crosstab.

```python
# Creating a crosstab
crosstab_result = pd.crosstab(df['department'], df['job_satisfaction_level'])

# Plotting a stacked bar chart
crosstab_result.plot(kind='bar', stacked=True, figsize=(10, 6), colormap='viridis')
plt.title('Job Satisfaction by Department')
plt.ylabel('Count')
plt.show()
```

---

## 4. Correlation Analysis

Understanding the strength and direction of the linear relationship between numerical variables.

```python
# Calculate correlation matrix (Pearson by default, Spearman for non-normal)
corr_matrix = df.corr()

# Visualize with a Heatmap
plt.figure(figsize=(10, 8))
sns.heatmap(corr_matrix, annot=True, cmap='RdBu_r', center=0, vmin=-1, vmax=1, fmt='.2f')
plt.title('Correlation Heatmap')
plt.show()
```
*Interview Tip:* Remember that correlation does not imply causation. High correlation only indicates that variables move together.

---

## 5. Modern and Advanced Visualizations

For a strong impression during interviews, utilize plots that show multiple dimensions gracefully.

### 5.1 Pairplot
Creates a grid of scatterplots for numeric variables and histograms/KDEs along the diagonal. Excellent for quick high-level overview.
```python
# Pick specific numeric columns to avoid overwhelming the plot
cols_of_interest = ['salary', 'years_experience', 'age', 'performance_score']
sns.pairplot(df[cols_of_interest], corner=True, diag_kind='kde')
plt.show()
```

### 5.2 FacetGrid / Relplot
Allows plotting multiple graphs based on the levels of categorical variables.
```python
# Salary vs Experience, split by Department across columns
sns.relplot(x='years_experience', y='salary', data=df, 
            col='department', col_wrap=3, kind='scatter')
plt.show()
```

---

## 6. Interview Best Practices for EDA

1. **Start with the Goal:** Always state *why* you are doing EDA. Make it clear you are looking to understand distributions to choose the right models or find business insights.
2. **Handle Warnings First:** Before heavy visualization, ensure you've noted missing values or inconsistent formats (Data Cleaning).
3. **Be Selective:** Don't plot every variable against every other variable mechanically. Pick combinations driven by hypotheses or domain knowledge.
4. **Format Your Charts:** A data scientist's chart should always be readable without explanation.
   - Use `plt.title()` for clear titles.
   - Use `plt.xlabel()` and `plt.ylabel()` (avoid defaulting to obscure column names).
   - Ensure legends are visible and `plt.tight_layout()` is used to prevent overlapping labels.
5. **Draw Conclusions:** Visualizations are useless without interpretations. In an interview, verbalize what the chart tells you (e.g., "The boxplot shows a long right tail, indicating high-salary outliers which might need log transformation").
