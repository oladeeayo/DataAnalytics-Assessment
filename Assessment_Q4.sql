-- Estimate Customer Lifetime Value (CLV) based on transaction volume and tenure

SELECT
    u.id AS customer_id,
    
    -- Combine first and last name to get full name
    CONCAT(u.first_name, ' ', u.last_name) AS name,

    -- Calculate tenure in months since account creation, minimum 1 to avoid division by zero
    GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, NOW()), 1) AS tenure_months,

    -- Total confirmed transactions (converted from kobo to naira)
    SUM(sa.confirmed_amount) / 100.0 AS total_transactions_naira,

    -- Estimate CLV using the simplified formula:
    -- CLV = (total_transaction_value / tenure_in_months) * 12 * profit_per_transaction (0.1% or 0.001)
    ROUND(
        ((SUM(sa.confirmed_amount) / 100.0) / GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, NOW()), 1)) 
        * 12 * 0.001,
        2
    ) AS estimated_clv

FROM users_customuser u
JOIN savings_savingsaccount sa ON sa.owner_id = u.id
WHERE sa.transaction_date IS NOT NULL  -- Consider only users with transactions

GROUP BY u.id, u.first_name, u.last_name, u.date_joined
ORDER BY estimated_clv DESC;  -- Show most valuable users first
