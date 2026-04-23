# Feature Engineering Notes

These notes provide a comprehensive framework and practical examples for conducting Feature Engineering in data science pipelines, critical for improving model performance during interviews.

## 1. Introduction to Feature Engineering

Feature engineering is the process of using domain knowledge to extract new variables from raw data that make machine learning algorithms work better. It is often considered the most important factor in determining the success of a predictive model.

### Key Objectives:
- Improve model accuracy and predictive power.
- Help models converge faster.
- Reduce model complexity by selecting the best features.
- Make the data compatible with specific ML algorithms.

---

## 2. Handling Missing Data (Imputation)

Missing data is common. How you handle it is an important engineered feature.

### 2.1 Numerical Imputation
- **Mean/Median/Mode Imputation:** Fast, but can distort the variance.
- **Advanced Imputation:** KNN Imputer or iterative imputation based on other variables.

```python
from sklearn.impute import SimpleImputer
import pandas as pd
import numpy as np

# Example DataFrame
df = pd.DataFrame({'age': [25, 30, np.nan, 35, 40]})

# Median Imputation
imputer = SimpleImputer(strategy='median')
df['age_imputed'] = imputer.fit_transform(df[['age']])
```

### 2.2 Categorical Imputation
- **Mode Imputation:** Replace NaN with the most frequent category.
- **Missing Indicator:** Create a new binary feature indicating if the value was missing.

```python
# Create a missing indicator before imputing
df['age_is_missing'] = df['age'].isnull().astype(int)
```

---

## 3. Encoding Categorical Variables

Machine learning models require numerical input. Categorical variables must be transformed.

### 3.1 Nominal Data (No inherent order)
- **One-Hot Encoding (OHE):** Creates binary columns for each category. Best for low-cardinality features. Use `drop_first=True` for linear models to avoid the dummy variable trap.

```python
# One-Hot Encoding example
df_encoded = pd.get_dummies(df, columns=['department'], drop_first=True)
```

- **Target Encoding (Mean Encoding):** Replaces categories with the mean target value for that category. Good for high-cardinality nominal features, but prone to data leakage (needs cross-validation).

### 3.2 Ordinal Data (Inherent order)
- **Label / Ordinal Encoding:** Map categories to ordered integers (e.g., Low -> 1, Medium -> 2, High -> 3).

```python
# Ordinal encoding mapping
education_map = {'High School': 1, 'Bachelors': 2, 'Masters': 3, 'PhD': 4}
df['education_encoded'] = df['education'].map(education_map)
```

---

## 4. Feature Scaling (Normalization and Standardization)

Scaling is essential for algorithms sensitive to the magnitude of features (e.g., KNN, SVM, Neural Networks, regularized regression). Tree-based models are usually invariant to scaling.

### 4.1 Standardization (Z-score scaling)
Scales features to have a mean of 0 and a standard deviation of 1. Handles outliers slightly better than Min-Max.

```python
from sklearn.preprocessing import StandardScaler

scaler = StandardScaler()
df['salary_standardized'] = scaler.fit_transform(df[['salary']])
```

### 4.2 Normalization (Min-Max Scaling)
Scales features to a fixed range, usually [0, 1].

```python
from sklearn.preprocessing import MinMaxScaler

minmax = MinMaxScaler()
df['age_normalized'] = minmax.fit_transform(df[['age']])
```

---

## 5. Feature Transformation

Changing the distribution of a variable or transforming non-linear relationships into linear ones.

### 5.1 Log Transformation
Used to reduce right-skewness and stabilize variance. Important when targets or features span several orders of magnitude (e.g., income, population).

```python
# Log transform (using log1p to handle zeros safely)
df['salary_log'] = np.log1p(df['salary'])
```

### 5.2 Power Transformations (Box-Cox, Yeo-Johnson)
Parametric transformations intended to map data to a normal distribution.

---

## 6. Feature Creation / Extraction

Creating completely new features based on domain logic or interactions between existing features.

### 6.1 Creating Interaction Features
Combining two or more features using arithmetic operations.

```python
# Example: Creating a 'total spending' or 'profit margin' feature
df['profit_margin'] = (df['revenue'] - df['cost']) / df['revenue']

# Example: Polynomial interactions
df['area'] = df['length'] * df['width']
```

### 6.2 Binning / Discretization
Converting continuous numerical variables into discrete categorical bins. Useful if the relationship with the target is non-linear or steps-based.

```python
# Binning ages into groups
bins = [0, 18, 35, 60, 100]
labels = ['Child', 'Young Adult', 'Adult', 'Senior']
df['age_group'] = pd.cut(df['age'], bins=bins, labels=labels)
```

### 6.3 Date and Time Features
Extracting components from datetime objects.

```python
# Extracting useful time features
df['date'] = pd.to_datetime(df['date'])
df['year'] = df['date'].dt.year
df['month'] = df['date'].dt.month
df['day_of_week'] = df['date'].dt.dayofweek
df['is_weekend'] = df['date'].dt.dayofweek >= 5
```

---

## 7. Feature Selection and Dimensionality Reduction

Reducing the number of input variables to reduce model complexity, prevent overfitting, and improve training time.

### 7.1 Filter Methods
Statistical tests evaluating the correlation/dependence with the target variable (e.g., ANOVA, Chi-Square, Mutual Information).

### 7.2 Wrapper Methods
Search subsets of features using a predictive model (e.g., Recursive Feature Elimination - RFE).

### 7.3 Embedded Methods
Algorithms that perform feature selection during their training process (e.g., L1 Regularization/Lasso regression, Feature Importances from Random Forests/XGBoost).

### 7.4 Dimensionality Reduction Algorithms
Algorithms like PCA (Principal Component Analysis) that create a new, smaller set of uncorrelated features (components) that capture the maximum variance of the original data.

---

## 8. Interview Best Practices for Feature Engineering

1. **Don't Leak the Target:** Always ensure your feature engineering avoids data leakage. For target encoding or imputing with means, fit your parameters *only* on the training data, then transform both train and test sets.
2. **Explain the "Why":** Never create features blindly. Be prepared to justify *why* you believe an interaction term or a logarithm transform makes logical or statistical sense.
3. **Know Model Requirements:** Demonstrate your knowledge by mentioning *which* algorithms need scaling (KNN, SVM) and *which* don't (Random Forest, XGBoost), or *which* need One-Hot Encoding (Logistic Regression) versus native categorical handling (LightGBM).
4. **Be Cautious with OHE Cardinality:** During an interview, recognize that One-Hot Encoding a variable with 10,000 unique values will explode the dimensionality and lead to the curse of dimensionality. Mention target encoding, hashing, or grouping rare categories as alternatives.
