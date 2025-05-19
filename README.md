# DataAnalytics-Assessment

# Customer Analytics SQL Project

This project contains four analytical SQL queries designed to address specific business needs related to customer segmentation, retention, and value estimation. The queries were written in MySQL and interact with tables such as `users_customuser`, `plans_plan`, and `savings_savingsaccount`.

---

## 📌 Question 1: High-Value Customers with Multiple Products

**Scenario:**  
Identify customers who have both a funded savings plan and a funded investment plan. This supports cross-selling and customer relationship deepening.

**Approach:**  
- Created two CTEs: one for funded savings plans and one for funded investment plans.
- Joined these datasets on the customer ID to find users who have both.
- Aggregated the total confirmed deposit value (converted from kobo to naira).
- Displayed name as `first_name + last_name`.

**Output Columns:**  
`owner_id`, `name`, `savings_count`, `investment_count`, `total_deposits (Naira)`

**Challenges:**  
- Needed to correctly distinguish between plan types using `is_regular_savings` and `is_a_fund`.
- Ensured deposits were filtered correctly (only positive `confirmed_amount` values).

---

## 📌 Question 2: Transaction Frequency Analysis

**Scenario:**  
Segment users by transaction frequency to enable marketing segmentation (e.g., frequent vs. occasional users).

**Approach:**  
- Counted total transactions and distinct active months for each customer.
- Calculated average transactions per month.
- Categorized into "High Frequency", "Medium Frequency", and "Low Frequency".
- Aggregated customer count and average transaction rate per category.

**Output Columns:**  
`frequency_category`, `customer_count`, `avg_transactions_per_month`

**Challenges:**  
- Ensured `transaction_date` was correctly grouped by month using `DATE_FORMAT`.
- Guarded against divide-by-zero using `NULLIF` and fallback logic.

---

## 📌 Question 3: Account Inactivity Alert

**Scenario:**  
Identify active savings or investment plans with no deposit activity for over one year.

**Approach:**  
- Identified the last transaction date per plan.
- Filtered for active (not deleted or archived) savings and investment plans.
- Calculated `inactivity_days` using `DATEDIFF(NOW(), last_transaction_date)`.
- Filtered for plans where inactivity exceeds 365 days.

**Output Columns:**  
`plan_id`, `owner_id`, `type`, `last_transaction_date`, `inactivity_days`

**Challenges:**  
- Required careful checking of both `is_archived` and `is_deleted` flags.
- Accounted for both savings and investment types correctly via `CASE`.

---

## 📌 Question 4: Customer Lifetime Value (CLV) Estimation

**Scenario:**  
Estimate simplified CLV based on transaction volume and tenure.

**Approach:**  
- Calculated tenure in months since account creation using `TIMESTAMPDIFF`.
- Computed total confirmed transactions (converted from kobo to naira).
- Estimated CLV using:  
  `CLV = (total_transactions / tenure) * 12 * 0.001`  
  where `0.001` represents 0.1% profit per transaction.
- Ordered results by estimated CLV.

**Output Columns:**  
`customer_id`, `name`, `tenure_months`, `total_transactions`, `estimated_clv`

**Challenges:**  
- Avoided divide-by-zero with `GREATEST(..., 1)` for tenure.
- Concatenated `first_name` and `last_name` for proper customer naming.

---

## 🚧 General Challenges

- **Currency Unit Conversion:** All transaction amounts were in kobo, requiring division by 100 to convert to naira.
- **Data Quality:** Ensured transactions were valid by excluding NULL `transaction_date`.
- **MySQL Date Handling:** Used `DATE_FORMAT`, `DATEDIFF`, and `TIMESTAMPDIFF` for monthly and daily computations.

---
