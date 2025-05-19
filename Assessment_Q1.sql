-- Identify users with at least one funded savings plan AND one funded investment plan

WITH savings_data AS (
    -- Get savings plan count and total deposits per user (for regular savings only)
    SELECT 
        sa.owner_id,
        COUNT(DISTINCT sa.plan_id) AS savings_count,
        SUM(sa.confirmed_amount) AS savings_total
    FROM savings_savingsaccount sa
    JOIN plans_plan p ON sa.plan_id = p.id
    WHERE p.is_regular_savings = 1              -- Only savings plans
      AND sa.confirmed_amount > 0               -- Only funded transactions
    GROUP BY sa.owner_id
),
investment_data AS (
    -- Get investment plan count and total deposits per user (for fund investments only)
    SELECT 
        sa.owner_id,
        COUNT(DISTINCT sa.plan_id) AS investment_count,
        SUM(sa.confirmed_amount) AS investment_total
    FROM savings_savingsaccount sa
    JOIN plans_plan p ON sa.plan_id = p.id
    WHERE p.is_a_fund = 1                        -- Only investment plans
      AND sa.confirmed_amount > 0               -- Only funded transactions
    GROUP BY sa.owner_id
)

-- Combine users who have both savings and investment data
SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,     -- Combine first and last name
    sd.savings_count,
    idata.investment_count,
    
    -- Convert from kobo to naira (1 naira = 100 kobo)
    ROUND((COALESCE(sd.savings_total, 0) + COALESCE(idata.investment_total, 0)) / 100.0, 2) AS total_deposits_naira

FROM users_customuser u
JOIN savings_data sd ON u.id = sd.owner_id
JOIN investment_data idata ON u.id = idata.owner_id
ORDER BY total_deposits_naira DESC;
