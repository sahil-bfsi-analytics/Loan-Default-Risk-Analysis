# Data-Quality Issue Summary (Intentional, Uncorrected)

The CSV was generated clean and then deliberately corrupted for cleaning practice. 
Nothing has been fixed. 
Issues are spread across different rows, 
so each affected record carries one injected issue. 
Roughly **4.5% of the 1,000 rows** are affected (about 45 rows). 
Exact row locations are not listed, so you can find them yourself.

| # | Issue type | Approx. rows | What to look for |
|---|-----------|-------------:|------------------|
| 1 | Missing values | 8 | Blanks in Annual_Income, 
Credit_Score, 
Age, 

Interest_Rate, 
Loan_Purpose 
and 
Days_Past_Due |





| 2 | Duplicate records | 8 | Exact repeats of whole rows, including a repeated Loan_ID |

| 3 | Invalid credit scores | 4 | Credit_Score outside 300-850 |

| 4 | Incorrect data types | 4 | Numeric fields stored as text, 
e.g. units or symbols attached, thousands separators, a percent sign |



| 5 | Inconsistent Loan_Status | 7 |
 Wrong capitalization, stray whitespace, misspelled or alternate labels |




| 6 | Inconsistent outstanding balances | 4 | Balance contradicting the loan status or exceeding the loan amount |



| 7 | Missing or badly formatted dates | 6 | Blank dates, non-ISO formats, impossible dates, and a due date before the loan date |



| 8 | Unrealistic financial values | 4 | Implausible ages, loan amounts or interest rates, and a recovery that exceeds the recoverable amount |

## Cleaning tips (no answers given)

- Check every column's data type before analysis.
- Standardize categorical fields before grouping.
- Validate numeric columns against the ranges in the data dictionary.
- Cross-check Loan_Status against Outstanding_Balance and Days_Past_Due.
- Cross-check Loan_Date against Payment_Due_Date.
- Decide and document how you handle each issue (remove, impute, correct or flag).

No KPIs, rates or analytical conclusions have been calculated.
