# Data Dictionary: Loan Default Risk Analysis (Synthetic Data)

All data is **synthetic**. It does not represent any real bank or customer. All monetary values are in INR.

**Reporting snapshot date:** 2026-10-31. Fields describing the current state (Days_Past_Due, Outstanding_Balance, Loan_Status) are as of this date. Loan_Date and Loan_Term_Months describe the original loan, and EMI_Amount is the contractual instalment.

| # | Column | Description | Intended valid values (clean records) |
|---|--------|-------------|----------------------------------------|
| 1 | Customer_ID | Customer identifier. Repeats when a customer holds several loans. Age, income and credit score are stored per customer, so repeat customers share them. | `CUST10001`-style text |
| 2 | Age | Customer age in years (as at snapshot). | 21-65 |
| 3 | Annual_Income | Customer annual income, INR. | 200,000-2,000,000 |
| 4 | Credit_Score | Customer credit score. | 300-850 |
| 5 | Loan_ID | Loan identifier, intended to be unique. | `LN100001`-style text |
| 6 | Loan_Date | Loan disbursement date. | YYYY-MM-DD, 2021-01-01 to 2026-08-31 |
| 7 | Loan_Amount | Original principal, INR. | 50,000-1,000,000 |
| 8 | Interest_Rate | Annual interest rate, percent (e.g. 12.50 = 12.5%). | 6.00-24.00 |

| 9 | Loan_Purpose | Reason for the loan. | Personal, Education, Medical, Home Improvement, Debt Consolidation |
| 10 | Loan_Term_Months | Contractual tenure in months. | 12, 24, 36, 48, 60 |
| 11 | EMI_Amount | Monthly instalment from the standard reducing-balance formula using Loan_Amount, Interest_Rate and Loan_Term_Months. | > 0 |
| 12 | Payment_Due_Date | The instalment due date the repayment status refers to. **Repaid:** final instalment date. **Active, on time:** most recent instalment due on or before the snapshot. **Active, overdue or Default:** the oldest unpaid instalment due date. | YYYY-MM-DD, after Loan_Date |
| 13 | Days_Past_Due | Days between Payment_Due_Date and the snapshot for an unpaid instalment; 0 if nothing is overdue. | Repaid = 0; Active 0-89; Default 90 or more |
| 14 | Outstanding_Balance | Principal still owed at the snapshot, INR. For Default loans, the principal outstanding at the first missed instalment (the recoverable amount). | Repaid = 0; Active and Default > 0; never above Loan_Amount |
| 15 | Recovery_Amount | Amount recovered after default, INR. Zero for Repaid and Active loans. | 0 to Outstanding_Balance |
| 16 | Loan_Status | Loan state at the snapshot. | Repaid, Active, Default |

## Notes

- **Known vs unknown outcomes:** Repaid and Default are final outcomes; Active is still in progress.
- **Default definition used in generation:** an instalment unpaid for 90 or more days.
- **Dataset size:** 1,000 rows, including intentional duplicates (see the data-quality summary).
- **No extra columns** beyond these 16 are included. Derived groupings (credit-score bands, income bands, delinquency flags) are left for you to build.
