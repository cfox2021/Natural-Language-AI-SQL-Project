# Example Questions and Results

The two current run logs in `results/` contain eight questions each, generated with `gpt-4o-mini`. Fourteen of the sixteen SQL queries executed. Both attempts at question 7 failed because the generated SQL refers to the nonexistent alias `coi`. Several other queries executed but did not match the question's intended meaning; the row checks below identify those cases.

| # | Question | Observed result | Assessment |
|---|---|---|---|
| 1 | Which customers have placed the most completed orders? | Both found Maya Chen with 3 completed orders. The single-domain answer named her; the zero-shot SQL returned customer IDs, and its friendly answer only reported ID 1. | Correct top customer; zero-shot answer is less useful. |
| 2 | Which menu items have sold the most by quantity? | Both listed Margherita Pizza, Spicy Chicken Sandwich, Garden Salad, and Iced Tea at 3 each. They counted Riley's cancelled order, which makes the sandwich appear tied for the lead. | Incorrect: exclude cancelled orders. The completed-order leaders are Margherita Pizza, Garden Salad, and Iced Tea at 3 each. |
| 3 | How many customers prefer each payment method? | Zero-shot returned card 3, cash 1, gift card 1, and mobile wallet 1. Single-domain returned the same counts except mobile wallet 2, because its SQL counted Maya's saved but nonpreferred Apple Pay. | Zero-shot correct; single-domain omitted the preferred-method filter. |
| 4 | Which customers do not have a phone number that can receive SMS? | Both returned Jordan Reed, Avery Patel, and Sam Brooks. | Correct. |
| 5 | What items are in Maya Chen's Friday Pizza Night favorite order? | Both returned one Margherita Pizza and two Iced Teas. | Correct. |
| 6 | Which customers have ordered Chocolate Cake, and on what dates? | Both returned Maya Chen on 2026-09-18 and Sam Brooks on 2026-09-27. | Correct. |
| 7 | How much has each customer spent on completed orders? | Both failed with `no such column: coi.price_at_order`; neither returned rows or a friendly answer. The schema uses `order_item` and the SQL needs a valid alias for it. | SQL execution error. A left-join query should include every customer, including Riley with $0. |
| 8 | Customers who prefer Google Pay or Apple Pay | Both returned Maya Chen and Sam Brooks. Maya has Apple Pay saved, but it is not her preferred method; only Sam Brooks, whose preferred method is Google Pay, should match. | Incorrect: both queries omitted `pm.is_preferred = 1`. |

## Corrected SQL examples

For question 2, count only items in completed orders:

```sql
SELECT mi.item_name, SUM(oi.quantity) AS total_sold
FROM customer_order co
JOIN order_item oi ON co.order_id = oi.order_id
JOIN menu_item mi ON oi.menu_item_id = mi.menu_item_id
WHERE co.order_status = 'completed'
GROUP BY mi.menu_item_id, mi.item_name
ORDER BY total_sold DESC;
```

For question 7, retain all customers and treat customers without completed orders as having spent zero:

```sql
SELECT c.first_name || ' ' || c.last_name AS customer_name,
       COALESCE(SUM(oi.quantity * oi.price_at_order), 0) AS total_spent
FROM customer c
LEFT JOIN customer_order co
       ON c.customer_id = co.customer_id
      AND co.order_status = 'completed'
LEFT JOIN order_item oi ON co.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;
```

This returns Maya Chen $53.00, Avery Patel $24.50, Sam Brooks $21.00, Jordan Reed $20.00, Theo Ramirez $16.50, and Riley Morgan $0.00.

For question 8, “prefer” means the payment row must be marked preferred:

```sql
SELECT DISTINCT c.first_name || ' ' || c.last_name AS customer_name
FROM customer c
JOIN payment_method pm ON c.customer_id = pm.customer_id
WHERE pm.is_preferred = 1
  AND pm.provider IN ('Google Pay', 'Apple Pay')
ORDER BY customer_name;
```

That returns Sam Brooks. Maya's Apple Pay row is saved as an available payment method, but the data marks her Visa as preferred.

## What the comparison showed

The strategies produced the same correct answers for the SMS, favorite-order, and Chocolate Cake questions. Both had the cancelled-order mistake for sales and the preferred-payment mistake for the student-authored question. Zero-shot handled the payment-method count correctly, while single-domain double-shot did not. Both spend queries failed at execution because of a bad alias. These runs show why checking generated SQL and returned rows matters: a query can run successfully and still answer the wrong question, and a plausible prompt can still generate invalid SQL.
