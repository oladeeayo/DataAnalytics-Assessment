-- Identify active savings and investment plans that have had no inflow transactions in the last 365 days

WITH latest_transactions AS (
    -- Step 1: Get the most recent transaction date for each active plan
    SELECT 
        p.id AS plan_id,
        p.owner_id,
        
        -- Classify the plan type as 'savings' or 'investment'
        CASE 
            WHEN p.is_regular_savings = 1 THEN 'savings'
            WHEN p.is_a_fund = 1 THEN 'investment'
            ELSE NULL
        END AS type,

        -- Get the latest transaction date for the plan
        MAX(sa.transaction_date) AS last_transaction_date
    FROM plans_plan p
    LEFT JOIN savings_savingsaccount sa ON p.id = sa.plan_id
    WHERE 
        -- Consider only savings or investment plans
        (p.is_regular_savings = 1 OR p.is_a_fund = 1)
        
        -- Only active plans (not deleted or archived)
        AND p.is_deleted = 0
        AND p.is_archived = 0
    GROUP BY p.id, p.owner_id, type
),

inactive_accounts AS (
    -- Step 2: Filter out plans with no transactions in the last 365 days
    SELECT 
        lt.plan_id,
        lt.owner_id,
        lt.type,
        lt.last_transaction_date,
        DATEDIFF(NOW(), lt.last_transaction_date) AS inactivity_days  -- Days since last transaction
    FROM latest_transactions lt
    WHERE 
        lt.last_transaction_date IS NOT NULL
        AND DATEDIFF(NOW(), lt.last_transaction_date) > 365
)

-- Final output: List of inactive plans sorted by how long they’ve been inactive
SELECT *
FROM inactive_accounts
ORDER BY inactivity_days DESC;
