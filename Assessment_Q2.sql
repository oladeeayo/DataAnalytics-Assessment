-- Analyze customer transaction frequency and categorize them

WITH user_transactions AS (
    -- Step 1: Calculate total transactions and number of active months per user
    SELECT 
        sa.owner_id,
        COUNT(*) AS total_transactions,  -- Total number of transactions per user
        COUNT(DISTINCT DATE_FORMAT(sa.transaction_date, '%Y-%m')) AS active_months  -- Unique transaction months
    FROM savings_savingsaccount sa
    WHERE sa.transaction_date IS NOT NULL
    GROUP BY sa.owner_id
),

user_freq AS (
    -- Step 2: Calculate average transactions per month and assign frequency category
    SELECT 
        ut.owner_id,
        (ut.total_transactions / NULLIF(ut.active_months, 0)) AS avg_txn_per_month,  -- Avoid division by zero
        CASE 
            WHEN (ut.total_transactions / NULLIF(ut.active_months, 0)) >= 10 THEN 'High Frequency'
            WHEN (ut.total_transactions / NULLIF(ut.active_months, 0)) BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM user_transactions ut
),

categorized_summary AS (
    -- Step 3: Group users by frequency category and compute summary statistics
    SELECT 
        frequency_category,
        COUNT(*) AS customer_count,  -- Number of customers in each category
        ROUND(AVG(avg_txn_per_month), 2) AS avg_transactions_per_month  -- Average transactions per month (2 decimal places)
    FROM user_freq
    GROUP BY frequency_category
)

-- Final output: Summary of customers by transaction frequency category
SELECT *
FROM categorized_summary
ORDER BY 
    FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');  -- Custom order for categories
