
USE LOANDEFAULTRISKANALYSIS;
GO


-- ============================================================
-- LOAN DEFAULT RISK ANALYSIS
-- SQL SERVER (SSMS)
-- ============================================================
SELECT * FROM LDR;


-- ============================================================
-- 1. OVERALL LOAN PORTFOLIO ANALYSIS
-- ============================================================

-- 1.1 Total Loans

SELECT
    COUNT(Loan_ID) AS TOTAL_LOANS
FROM LDR;


-- 1.2 Total Loan Amount

SELECT
    SUM(Loan_Amount) AS TOTAL_LOAN_AMOUNT
FROM LDR;


-- 1.3 Total Outstanding Loan Amount

SELECT
    SUM(Outstanding_Balance) AS TOTAL_OUTSTANDING_LOAN_AMOUNT
FROM LDR;


-- 1.4 Average Loan Amount

SELECT
    AVG(Loan_Amount) AS AVG_LOAN_AMOUNT
FROM LDR;


-- 1.5 Average Interest Rate

SELECT
    AVG(Interest_Rate) AS AVG_INTEREST_RATE
FROM LDR;


-- 1.6 Average Age

SELECT
    AVG(CAST(Age AS DECIMAL(10,2))) AS AVG_AGE
FROM LDR;


-- 1.7 Average Annual Income

SELECT
    AVG(CAST(Annual_Income AS DECIMAL(15,2))) AS AVG_ANNUAL_INCOME
FROM LDR;


-- 1.8 Average Credit Score

SELECT
    AVG(CAST(Credit_Score AS DECIMAL(10,2))) AS AVG_CREDIT_SCORE
FROM LDR;


-- 1.9 Count of Every Loan Purpose

SELECT
    Loan_Purpose,
    COUNT(Loan_Purpose) AS TOTAL_LOAN_PURPOSE_COUNT
FROM LDR
GROUP BY Loan_Purpose;


-- 1.10 Loan Term Months Distribution

SELECT
    Loan_Term_Months,
    COUNT(*) AS TOTAL_LOANS,

    ROUND(
        CAST(COUNT(*) AS FLOAT) * 100 /
        SUM(COUNT(*)) OVER(),
        2
    ) AS PERCENTAGE_SHARE

FROM LDR
GROUP BY Loan_Term_Months
ORDER BY Loan_Term_Months ASC;


-- 1.11 How Many Customers Have Multiple or Single Loans?

WITH CustomerLoanCounts AS
(
    SELECT
        Customer_ID,
        COUNT(Loan_ID) AS TOTAL_LOANS
    FROM LDR
    GROUP BY Customer_ID
)

SELECT
    CASE
        WHEN TOTAL_LOANS = 1 THEN 'SINGLE LOAN'
        WHEN TOTAL_LOANS > 1 THEN 'MULTIPLE LOANS'
    END AS LOAN_CATEGORY,

    COUNT(*) AS TOTAL_CUSTOMERS,

    ROUND(
        CAST(COUNT(*) AS FLOAT) * 100 /
        SUM(COUNT(*)) OVER(),
        2
    ) AS PERCENTAGE_SHARE

FROM CustomerLoanCounts

GROUP BY
    CASE
        WHEN TOTAL_LOANS = 1 THEN 'SINGLE LOAN'
        WHEN TOTAL_LOANS > 1 THEN 'MULTIPLE LOANS'
    END;


-- ============================================================
-- 2. CREDIT RISK ANALYSIS
-- ============================================================


-- 2.1 How Many Loans Defaulted?

SELECT
    COUNT(Loan_Status) AS DEFAULTED_LOANS_COUNT
FROM LDR
WHERE Loan_Status = 'Default';


-- 2.2 What Percentage of Loans Defaulted?

SELECT
    COUNT(CASE
        WHEN Loan_Status = 'Default' THEN 1
    END) AS DEFAULTED_LOANS_COUNT,

    COUNT(CASE
        WHEN Loan_Status IN ('Repaid', 'Default') THEN 1
    END) AS ELIGIBLE_LOANS,

    CAST(
        100.0 *
        COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) /
        COUNT(CASE WHEN Loan_Status IN ('Repaid', 'Default') THEN 1 END)
        AS DECIMAL(5,2)
    ) AS DEFAULT_RATE

FROM LDR;


-- 2.3 How Much Outstanding Defaulted Loan Amount?

SELECT
    SUM(Outstanding_Balance) AS DEFAULTED_LOAN_OUTSTANDING_AMOUNT
FROM LDR
WHERE Loan_Status = 'Default';


-- 2.4 How Much Money Is at Risk?

SELECT
    SUM(Outstanding_Balance) AS TOTAL_MONEY_AT_RISK
FROM LDR
WHERE Loan_Status IN ('Default', 'Active');


-- 2.5 Default Rate by Income Group
-- (This query also answers: Which Income Groups Are Riskier?)
-- Expected: LOW 17.92 | MEDIUM 16.80 | HIGH 9.52

SELECT
    CASE
        WHEN Annual_Income BETWEEN 200000 AND 800000
            THEN 'LOW INCOME'

        WHEN Annual_Income > 800000 AND Annual_Income <= 1400000
            THEN 'MEDIUM INCOME'

        ELSE 'HIGH INCOME'
    END AS INCOME_GROUP,

    COUNT(CASE
        WHEN Loan_Status = 'Default' THEN 1
    END) AS DEFAULTED_LOANS,

    COUNT(CASE
        WHEN Loan_Status IN ('Default', 'Repaid') THEN 1
    END) AS ELIGIBLE_LOANS,

    CAST(
        COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) * 100.0 /
        NULLIF(
            COUNT(CASE WHEN Loan_Status IN ('Default', 'Repaid') THEN 1 END),
            0
        )
        AS DECIMAL(10,2)
    ) AS DEFAULT_RATE

FROM LDR
WHERE Loan_Status IN ('Default', 'Repaid')

GROUP BY
    CASE
        WHEN Annual_Income BETWEEN 200000 AND 800000
            THEN 'LOW INCOME'

        WHEN Annual_Income > 800000 AND Annual_Income <= 1400000
            THEN 'MEDIUM INCOME'

        ELSE 'HIGH INCOME'
    END;


-- 2.6 Default Rate by Loan Purpose

SELECT
    Loan_Purpose,

    COUNT(CASE
        WHEN Loan_Status = 'Default' THEN 1
    END) AS DEFAULTED_LOANS,

    COUNT(*) AS ELIGIBLE_LOANS,

    CAST(
        COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) * 100.0 /
        NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS DEFAULT_RATE

FROM LDR
WHERE Loan_Status IN ('Default', 'Repaid')

GROUP BY Loan_Purpose
ORDER BY DEFAULT_RATE DESC;


-- 2.7 Default Rate by Credit Score Group

SELECT
    CASE
        WHEN Credit_Score BETWEEN 300 AND 549
            THEN 'POOR'

        WHEN Credit_Score BETWEEN 550 AND 649
            THEN 'FAIR'

        WHEN Credit_Score BETWEEN 650 AND 749
            THEN 'GOOD'

        WHEN Credit_Score BETWEEN 750 AND 850
            THEN 'EXCELLENT'
    END AS CREDIT_SCORE_GROUP,

    COUNT(CASE
        WHEN Loan_Status = 'Default' THEN 1
    END) AS DEFAULTED_LOANS,

    COUNT(*) AS ELIGIBLE_LOANS,

    CAST(
        COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) * 100.0 /
        NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS DEFAULT_RATE

FROM LDR
WHERE Loan_Status IN ('Default', 'Repaid')

GROUP BY
    CASE
        WHEN Credit_Score BETWEEN 300 AND 549
            THEN 'POOR'

        WHEN Credit_Score BETWEEN 550 AND 649
            THEN 'FAIR'

        WHEN Credit_Score BETWEEN 650 AND 749
            THEN 'GOOD'

        WHEN Credit_Score BETWEEN 750 AND 850
            THEN 'EXCELLENT'
    END

ORDER BY DEFAULT_RATE DESC;


-- 2.8 Default Rate by Loan Term

SELECT
    Loan_Term_Months,

    COUNT(CASE
        WHEN Loan_Status = 'Default' THEN 1
    END) AS DEFAULTED_LOANS,

    COUNT(*) AS ELIGIBLE_LOANS,

    CAST(
        COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) * 100.0 /
        NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS DEFAULT_RATE

FROM LDR
WHERE Loan_Status IN ('Default', 'Repaid')

GROUP BY Loan_Term_Months
ORDER BY DEFAULT_RATE DESC;


-- 2.9 Which Customer Groups Have Higher Default Rates?

SELECT
    CASE
        WHEN Age BETWEEN 21 AND 30 THEN '21-30'
        WHEN Age BETWEEN 31 AND 40 THEN '31-40'
        WHEN Age BETWEEN 41 AND 50 THEN '41-50'
        WHEN Age BETWEEN 51 AND 65 THEN '51-65'
    END AS AGE_GROUP,

    COUNT(CASE
        WHEN Loan_Status = 'Default' THEN 1
    END) AS DEFAULTED_LOANS,

    COUNT(*) AS ELIGIBLE_LOANS,

    CAST(
        COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) * 100.0 /
        NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS DEFAULT_RATE

FROM LDR
WHERE Loan_Status IN ('Default', 'Repaid')

GROUP BY
    CASE
        WHEN Age BETWEEN 21 AND 30 THEN '21-30'
        WHEN Age BETWEEN 31 AND 40 THEN '31-40'
        WHEN Age BETWEEN 41 AND 50 THEN '41-50'
        WHEN Age BETWEEN 51 AND 65 THEN '51-65'
    END

ORDER BY DEFAULT_RATE DESC;


-- 2.10 Which Loan Types Are Riskier?

SELECT
    Loan_Purpose,

    COUNT(CASE
        WHEN Loan_Status = 'Default' THEN 1
    END) AS DEFAULTED_LOANS,

    COUNT(*) AS ELIGIBLE_LOANS,

    CAST(
        COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) * 100.0 /
        NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS DEFAULT_RATE

FROM LDR
WHERE Loan_Status IN ('Default', 'Repaid')

GROUP BY Loan_Purpose
ORDER BY DEFAULT_RATE DESC;


-- 2.11 Loan Amount vs Annual Income Analysis

WITH Loan_Income_Analysis AS
(
    SELECT
        Loan_ID,
        Loan_Amount,
        Annual_Income,
        Loan_Status,

        CAST(
            Loan_Amount * 100.0 /
            NULLIF(Annual_Income, 0)
            AS DECIMAL(10,2)
        ) AS LTI_PERCENTAGE

    FROM LDR
    WHERE Loan_Status IN ('Repaid', 'Default')
)

SELECT
    CASE
        WHEN LTI_PERCENTAGE <= 25 THEN 'LOW LTI'
        WHEN LTI_PERCENTAGE <= 50 THEN 'MEDIUM LTI'
        WHEN LTI_PERCENTAGE <= 75 THEN 'HIGH LTI'
        ELSE 'VERY HIGH LTI'
    END AS LTI_GROUP,

    COUNT(*) AS TOTAL_LOANS,

    COUNT(CASE
        WHEN Loan_Status = 'Default' THEN 1
    END) AS DEFAULTED_LOANS,

    CAST(
        COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) *
        100.0 / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS DEFAULT_RATE

FROM Loan_Income_Analysis

GROUP BY
    CASE
        WHEN LTI_PERCENTAGE <= 25 THEN 'LOW LTI'
        WHEN LTI_PERCENTAGE <= 50 THEN 'MEDIUM LTI'
        WHEN LTI_PERCENTAGE <= 75 THEN 'HIGH LTI'
        ELSE 'VERY HIGH LTI'
    END

ORDER BY DEFAULT_RATE DESC;


-- 2.12 Customer Risk Segmentation
-- Expected (after fix): HIGH RISK 279 loans / 63 defaults / 22.58 | MEDIUM RISK 196 / 24 / 12.24 | LOW RISK 38 / 0 / 0.00

WITH Customer_Risk AS
(
    SELECT
        Customer_ID,
        Loan_ID,
        Credit_Score,
        Annual_Income,
        Loan_Amount,
        Loan_Status,

        CAST(
            Loan_Amount * 100.0 /
            NULLIF(Annual_Income, 0)
            AS DECIMAL(10,2)
        ) AS LTI_PERCENTAGE

    FROM LDR
    WHERE Loan_Status IN ('Repaid', 'Default')   -- FIX: Active loans are excluded because their final outcome is not known yet
)

SELECT
    CASE
        WHEN Credit_Score >= 750
             AND LTI_PERCENTAGE <= 25
            THEN 'LOW RISK'

        WHEN Credit_Score >= 650
             AND LTI_PERCENTAGE <= 50
            THEN 'MEDIUM RISK'

        ELSE 'HIGH RISK'
    END AS RISK_CATEGORY,

    COUNT(*) AS TOTAL_LOANS,

    COUNT(CASE
        WHEN Loan_Status = 'Default' THEN 1
    END) AS DEFAULTED_LOANS,

    CAST(
        COUNT(CASE WHEN Loan_Status = 'Default' THEN 1 END) *
        100.0 / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS DEFAULT_RATE

FROM Customer_Risk

GROUP BY
    CASE
        WHEN Credit_Score >= 750
             AND LTI_PERCENTAGE <= 25
            THEN 'LOW RISK'

        WHEN Credit_Score >= 650
             AND LTI_PERCENTAGE <= 50
            THEN 'MEDIUM RISK'

        ELSE 'HIGH RISK'
    END

ORDER BY DEFAULT_RATE DESC;


-- ============================================================
-- 3. REPAYMENT BEHAVIOUR ANALYSIS
-- ============================================================


-- 3.1 Repaid Loans vs Active Loans vs Defaulted Loans

SELECT
    Loan_Status,

    COUNT(*) AS TOTAL_LOANS,

    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER()
        AS DECIMAL(10,2)
    ) AS LOAN_PERCENTAGE

FROM LDR
GROUP BY Loan_Status
ORDER BY TOTAL_LOANS DESC;


-- 3.2 Recovery Rate
-- Expected (after fix): 87 defaulted loans | recovery 3,988,489.37 | outstanding 15,153,270.20 | recovery rate 26.32

SELECT
    COUNT(*) AS DEFAULTED_LOANS,

    SUM(Recovery_Amount) AS TOTAL_RECOVERY,

    SUM(Outstanding_Balance) AS TOTAL_OUTSTANDING,

    CAST(
        SUM(Recovery_Amount) * 100.0 /
        NULLIF(
            SUM(Outstanding_Balance),   -- FIX: Recovery_Amount is part of Outstanding_Balance, so it must not be added again
            0
        )
        AS DECIMAL(10,2)
    ) AS RECOVERY_RATE

FROM LDR
WHERE Loan_Status = 'Default';


-- 3.3 Repayment Behaviour by Loan Purpose

SELECT
    Loan_Purpose,

    COUNT(*) AS TOTAL_LOANS,

    COUNT(CASE
        WHEN Loan_Status = 'Repaid' THEN 1
    END) AS REPAID_LOANS,

    COUNT(CASE
        WHEN Loan_Status = 'Active' THEN 1
    END) AS ACTIVE_LOANS,

    COUNT(CASE
        WHEN Loan_Status = 'Default' THEN 1
    END) AS DEFAULTED_LOANS,

    SUM(Outstanding_Balance) AS TOTAL_OUTSTANDING,

    SUM(Recovery_Amount) AS TOTAL_RECOVERY

FROM LDR
GROUP BY Loan_Purpose
ORDER BY DEFAULTED_LOANS DESC;


-- 3.4 Outstanding Balance Analysis
-- Expected: Active 472 loans / 61,528,391.41 (80.24%) | Default 87 / 15,153,270.20 (19.76%) | Repaid 426 / 0.00

SELECT
    Loan_Status,

    COUNT(*) AS TOTAL_LOANS,

    SUM(Outstanding_Balance) AS TOTAL_OUTSTANDING,

    CAST(AVG(Outstanding_Balance) AS DECIMAL(12,2)) AS AVG_OUTSTANDING,

    CAST(
        SUM(Outstanding_Balance) * 100.0 /
        NULLIF(SUM(SUM(Outstanding_Balance)) OVER(), 0)
        AS DECIMAL(10,2)
    ) AS OUTSTANDING_SHARE

FROM LDR
GROUP BY Loan_Status
ORDER BY TOTAL_OUTSTANDING DESC;


-- 3.5 Recovery Amount Analysis (Defaulted Loans)
-- Expected: 87 defaults | 63 with recovery | 24 with no recovery | total recovery 3,988,489.37 | avg 45,844.71 | unrecovered 11,164,780.83

SELECT
    COUNT(*) AS DEFAULTED_LOANS,

    COUNT(CASE
        WHEN Recovery_Amount > 0 THEN 1
    END) AS LOANS_WITH_RECOVERY,

    COUNT(CASE
        WHEN Recovery_Amount = 0 THEN 1
    END) AS LOANS_WITH_NO_RECOVERY,

    SUM(Recovery_Amount) AS TOTAL_RECOVERY,

    CAST(AVG(Recovery_Amount) AS DECIMAL(12,2)) AS AVG_RECOVERY_PER_DEFAULTED_LOAN,

    SUM(Outstanding_Balance - Recovery_Amount) AS UNRECOVERED_AMOUNT

FROM LDR
WHERE Loan_Status = 'Default';


-- ============================================================
-- 4. DELINQUENCY ANALYSIS
-- ============================================================


-- 4.1 Delinquency Rate

SELECT
    COUNT(*) AS TOTAL_LOANS,

    COUNT(CASE
        WHEN Days_Past_Due > 0 THEN 1
    END) AS DELINQUENT_LOANS,

    CAST(
        COUNT(CASE WHEN Days_Past_Due > 0 THEN 1 END) *
        100.0 / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS DELINQUENCY_RATE

FROM LDR
WHERE Loan_Status IN ('Active', 'Default');


-- 4.2 Delinquency by Income Group

SELECT
    CASE
        WHEN Annual_Income <= 800000
            THEN 'LOW INCOME'

        WHEN Annual_Income <= 1400000
            THEN 'MEDIUM INCOME'

        ELSE 'HIGH INCOME'
    END AS INCOME_GROUP,

    COUNT(*) AS TOTAL_LOANS,

    COUNT(CASE
        WHEN Days_Past_Due > 0 THEN 1
    END) AS DELINQUENT_LOANS,

    CAST(
        COUNT(CASE WHEN Days_Past_Due > 0 THEN 1 END) *
        100.0 / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS DELINQUENCY_RATE

FROM LDR
WHERE Loan_Status IN ('Active', 'Default')

GROUP BY
    CASE
        WHEN Annual_Income <= 800000
            THEN 'LOW INCOME'

        WHEN Annual_Income <= 1400000
            THEN 'MEDIUM INCOME'

        ELSE 'HIGH INCOME'
    END

ORDER BY DELINQUENCY_RATE DESC;


-- 4.3 Delinquency by Loan Purpose

SELECT
    Loan_Purpose,

    COUNT(*) AS TOTAL_LOANS,

    COUNT(CASE
        WHEN Days_Past_Due > 0 THEN 1
    END) AS DELINQUENT_LOANS,

    CAST(
        COUNT(CASE WHEN Days_Past_Due > 0 THEN 1 END) *
        100.0 / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS DELINQUENCY_RATE

FROM LDR
WHERE Loan_Status IN ('Active', 'Default')

GROUP BY Loan_Purpose
ORDER BY DELINQUENCY_RATE DESC;


-- 4.4 Days Past Due Analysis
-- Expected: 0 days 416 loans | 1-30 18 | 31-60 22 | 61-89 16 | 90+ 87 (all Default)

SELECT
    CASE
        WHEN Days_Past_Due = 0  THEN '0. CURRENT (0 DAYS)'
        WHEN Days_Past_Due <= 30 THEN '1. 1-30 DAYS'
        WHEN Days_Past_Due <= 60 THEN '2. 31-60 DAYS'
        WHEN Days_Past_Due <= 89 THEN '3. 61-89 DAYS'
        ELSE '4. 90+ DAYS (DEFAULT)'
    END AS DPD_BUCKET,

    COUNT(*) AS TOTAL_LOANS,

    SUM(Outstanding_Balance) AS TOTAL_OUTSTANDING

FROM LDR
WHERE Loan_Status IN ('Active', 'Default')

GROUP BY
    CASE
        WHEN Days_Past_Due = 0  THEN '0. CURRENT (0 DAYS)'
        WHEN Days_Past_Due <= 30 THEN '1. 1-30 DAYS'
        WHEN Days_Past_Due <= 60 THEN '2. 31-60 DAYS'
        WHEN Days_Past_Due <= 89 THEN '3. 61-89 DAYS'
        ELSE '4. 90+ DAYS (DEFAULT)'
    END

ORDER BY DPD_BUCKET;


-- 4.5 Overdue Loan Analysis
-- Expected: Active 56 overdue / 8,056,353.96 / avg 43.29 days / max 86 | Default 87 / 15,153,270.20 / avg 761.32 / max 2010

SELECT
    Loan_Status,

    COUNT(*) AS OVERDUE_LOANS,

    SUM(Outstanding_Balance) AS OVERDUE_OUTSTANDING,

    CAST(AVG(CAST(Days_Past_Due AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS AVG_DAYS_PAST_DUE,

    MAX(Days_Past_Due) AS MAX_DAYS_PAST_DUE

FROM LDR
WHERE Loan_Status IN ('Active', 'Default')
  AND Days_Past_Due > 0

GROUP BY Loan_Status
ORDER BY OVERDUE_LOANS DESC;


-- ============================================================
-- END OF LOAN DEFAULT RISK ANALYSIS
-- ============================================================