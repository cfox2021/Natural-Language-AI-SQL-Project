INSERT INTO customer (customer_id, first_name, last_name, joined_date) VALUES
(1, 'Maya', 'Chen', '2025-02-11'),
(2, 'Jordan', 'Reed', '2025-03-05'),
(3, 'Avery', 'Patel', '2025-04-18'),
(4, 'Theo', 'Ramirez', '2025-06-02'),
(5, 'Sam', 'Brooks', '2025-07-21'),
(6, 'Riley', 'Morgan', '2025-09-09');

INSERT INTO contact_info (contact_id, customer_id, contact_type, contact_value, is_primary, sms_opt_in, email_opt_in) VALUES
(1, 1, 'phone', '555-0101', 1, 1, 0),
(2, 1, 'email', 'maya@example.test', 0, 0, 1),
(3, 2, 'phone', '555-0102', 1, 0, 0),
(4, 2, 'email', 'jordan@example.test', 0, 0, 1),
(5, 3, 'email', 'avery@example.test', 1, 0, 1),
(6, 4, 'phone', '555-0104', 1, 1, 0),
(7, 5, 'phone', '555-0105', 1, 0, 0),
(8, 5, 'email', 'sam@example.test', 0, 0, 0),
(9, 6, 'phone', '555-0106', 1, 1, 0);

INSERT INTO payment_method (payment_method_id, customer_id, method_type, provider, last_four, is_preferred) VALUES
(1, 1, 'card', 'Visa', '4242', 1),
(2, 1, 'mobile wallet', 'Apple Pay', NULL, 0),
(3, 2, 'cash', NULL, NULL, 1),
(4, 3, 'card', 'Mastercard', '4444', 1),
(5, 4, 'gift card', NULL, NULL, 1),
(6, 5, 'mobile wallet', 'Google Pay', NULL, 1),
(7, 6, 'card', 'Visa', '1881', 1);

INSERT INTO menu_item (menu_item_id, item_name, category, current_price, is_available) VALUES
(1, 'Margherita Pizza', 'pizza', 14.00, 1),
(2, 'Spicy Chicken Sandwich', 'sandwich', 12.50, 1),
(3, 'Garden Salad', 'salad', 9.00, 1),
(4, 'Tomato Soup', 'soup', 6.50, 1),
(5, 'Crispy Fries', 'side', 4.00, 1),
(6, 'Chocolate Cake', 'dessert', 7.00, 1),
(7, 'Iced Tea', 'drink', 3.00, 1),
(8, 'Lemonade', 'drink', 3.50, 1);

INSERT INTO customer_order (order_id, customer_id, payment_method_id, order_date, order_type, order_status) VALUES
(1, 1, 1, '2026-09-02', 'dine-in', 'completed'),
(2, 1, 1, '2026-09-18', 'takeout', 'completed'),
(3, 2, 3, '2026-09-19', 'dine-in', 'completed'),
(4, 3, 4, '2026-09-22', 'delivery', 'completed'),
(5, 4, 5, '2026-09-25', 'takeout', 'completed'),
(6, 5, 6, '2026-09-27', 'dine-in', 'completed'),
(7, 1, 2, '2026-10-01', 'takeout', 'completed'),
(8, 6, 7, '2026-10-03', 'dine-in', 'cancelled');

INSERT INTO order_item (order_id, menu_item_id, quantity, price_at_order) VALUES
(1, 1, 1, 14.00), (1, 7, 2, 3.00),
(2, 1, 1, 14.00), (2, 6, 1, 7.00),
(3, 2, 1, 12.50), (3, 5, 1, 4.00), (3, 8, 1, 3.50),
(4, 3, 2, 9.00), (4, 4, 1, 6.50),
(5, 2, 1, 12.50), (5, 5, 1, 4.00),
(6, 1, 1, 14.00), (6, 6, 1, 7.00),
(7, 3, 1, 9.00), (7, 7, 1, 3.00),
(8, 2, 1, 12.50), (8, 8, 1, 3.50);

INSERT INTO favorite_order (favorite_order_id, customer_id, nickname, created_date) VALUES
(1, 1, 'Friday Pizza Night', '2025-03-01'),
(2, 2, 'Quick Lunch', '2025-04-12'),
(3, 3, 'Veggie Comfort Meal', '2025-05-20'),
(4, 4, 'Sandwich Combo', '2025-06-15'),
(5, 5, 'Pizza and Cake', '2025-08-01'),
(6, 1, 'Light Lunch', '2025-08-11');

INSERT INTO favorite_order_item (favorite_order_id, menu_item_id, quantity) VALUES
(1, 1, 1), (1, 7, 2),
(2, 2, 1), (2, 5, 1),
(3, 3, 1), (3, 4, 1),
(4, 2, 1), (4, 8, 1),
(5, 1, 1), (5, 6, 1),
(6, 3, 1), (6, 7, 1);
