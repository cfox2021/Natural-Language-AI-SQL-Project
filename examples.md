# Test Questions and Results

Both prompting strategies ran the same eight test questions with `gpt-4o-mini`. The current response files are in `results/`. All 16 generated SQL queries executed without SQL errors. Some returned rows did not match the intended meaning of the question, so the assessment below checks both execution and query logic.

| # | Question | Zero-shot result | Single-domain double-shot result | Assessment |
|---|---|---|---|---|
| 1 | Which customers have placed the most completed orders? | Maya Chen, 3 completed orders. | Maya Chen, 3 completed orders. | Both correctly identified Maya as the top customer. |
| 2 | Which menu items have sold the most by quantity? | Margherita Pizza, Spicy Chicken Sandwich, Garden Salad, and Iced Tea at 3 each. | Same four items at 3 each. | Both included Riley's cancelled order. Among completed orders, Margherita Pizza, Garden Salad, and Iced Tea lead with 3 each; Spicy Chicken Sandwich has 2 and Lemonade has 1. |
| 3 | How many customers prefer each payment method? | Card 3, cash 1, gift card 1, mobile wallet 1. | Card 3, cash 1, gift card 1, mobile wallet 2. | Zero-shot was correct. The double-shot query omitted `is_preferred = 1`, counting Maya's saved but nonpreferred Apple Pay. |
| 4 | Which customers do not have a phone number that can receive SMS? | Jordan Reed, Avery Patel, and Sam Brooks. | Same three customers. | Both correct. |
| 5 | What items are in Maya Chen's Friday Pizza Night favorite order? | One Margherita Pizza and two Iced Teas. | Same items and quantities. | Both correct. |
| 6 | Which customers have ordered Chocolate Cake, and on what dates? | Maya Chen, 2026-09-18; Sam Brooks, 2026-09-27. | Same customers and dates. | Both correct. |
| 7 | How much has each customer spent on completed orders? | Correct totals for customer IDs 1–5, but omitted Riley Morgan. | Correct named totals for Maya, Jordan, Avery, Theo, and Sam, but omitted Riley Morgan. | The inner joins exclude customers with no completed orders. Riley should appear with $0.00. Zero-shot also gave IDs instead of names. |
| 8 | Customers who prefer Google Pay or Apple Pay | Maya Chen and Sam Brooks. | Maya Chen and Sam Brooks. | Both queries matched wallet providers but omitted `pm.is_preferred = 1`. Only Sam Brooks should match: Maya's preferred method is Visa. |

## Corrected SQL

For question 2, count items only from completed orders:

```sql
SELECT mi.item_name, SUM(oi.quantity) AS total_sold
FROM customer_order co
JOIN order_item oi ON co.order_id = oi.order_id
JOIN menu_item mi ON oi.menu_item_id = mi.menu_item_id
WHERE co.order_status = 'completed'
GROUP BY mi.menu_item_id, mi.item_name
ORDER BY total_sold DESC;
```

For question 7, begin with all customers and use left joins so customers without completed orders remain in the result:

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

Expected totals: Maya Chen $53.00, Avery Patel $24.50, Sam Brooks $21.00, Jordan Reed $20.00, Theo Ramirez $16.50, and Riley Morgan $0.00.

For question 8, filter for payment methods marked as preferred:

```sql
SELECT DISTINCT c.first_name || ' ' || c.last_name AS customer_name
FROM customer c
JOIN payment_method pm ON c.customer_id = pm.customer_id
WHERE pm.is_preferred = 1
  AND pm.provider IN ('Google Pay', 'Apple Pay')
ORDER BY customer_name;
```

This returns Sam Brooks. Maya has Apple Pay saved, but her preferred method is Visa.

## Comparison

Both strategies answered the completed-order leader, SMS, favorite-order, and Chocolate Cake questions correctly. Both made the same mistakes on sales totals and the student-authored payment question. Zero-shot correctly filtered preferred payment types in question 3; single-domain double-shot did not. Both spending queries returned the five customers with completed orders but omitted Riley. These results show why returned rows must be checked against the question even when SQL executes successfully.
