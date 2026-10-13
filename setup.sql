PRAGMA foreign_keys = ON;

CREATE TABLE customer (
    customer_id INTEGER PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    joined_date TEXT NOT NULL
);

CREATE TABLE contact_info (
    contact_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    contact_type TEXT NOT NULL CHECK (contact_type IN ('phone', 'email')),
    contact_value TEXT NOT NULL,
    is_primary INTEGER NOT NULL DEFAULT 0 CHECK (is_primary IN (0, 1)),
    sms_opt_in INTEGER NOT NULL DEFAULT 0 CHECK (sms_opt_in IN (0, 1)),
    email_opt_in INTEGER NOT NULL DEFAULT 0 CHECK (email_opt_in IN (0, 1)),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    UNIQUE (contact_type, contact_value)
);

CREATE TABLE payment_method (
    payment_method_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    method_type TEXT NOT NULL CHECK (method_type IN ('card', 'cash', 'gift card', 'mobile wallet')),
    provider TEXT,
    last_four TEXT,
    is_preferred INTEGER NOT NULL DEFAULT 0 CHECK (is_preferred IN (0, 1)),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CHECK (last_four IS NULL OR length(last_four) = 4)
);

CREATE TABLE menu_item (
    menu_item_id INTEGER PRIMARY KEY,
    item_name TEXT NOT NULL UNIQUE,
    category TEXT NOT NULL,
    current_price REAL NOT NULL CHECK (current_price >= 0),
    is_available INTEGER NOT NULL DEFAULT 1 CHECK (is_available IN (0, 1))
);

CREATE TABLE customer_order (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    payment_method_id INTEGER,
    order_date TEXT NOT NULL,
    order_type TEXT NOT NULL CHECK (order_type IN ('dine-in', 'takeout', 'delivery')),
    order_status TEXT NOT NULL CHECK (order_status IN ('completed', 'cancelled', 'in progress')),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (payment_method_id) REFERENCES payment_method(payment_method_id)
);

CREATE TABLE order_item (
    order_id INTEGER NOT NULL,
    menu_item_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price_at_order REAL NOT NULL CHECK (price_at_order >= 0),
    PRIMARY KEY (order_id, menu_item_id),
    FOREIGN KEY (order_id) REFERENCES customer_order(order_id),
    FOREIGN KEY (menu_item_id) REFERENCES menu_item(menu_item_id)
);

CREATE TABLE favorite_order (
    favorite_order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    nickname TEXT NOT NULL,
    created_date TEXT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    UNIQUE (customer_id, nickname)
);

CREATE TABLE favorite_order_item (
    favorite_order_id INTEGER NOT NULL,
    menu_item_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (favorite_order_id, menu_item_id),
    FOREIGN KEY (favorite_order_id) REFERENCES favorite_order(favorite_order_id),
    FOREIGN KEY (menu_item_id) REFERENCES menu_item(menu_item_id)
);

CREATE INDEX idx_contact_customer ON contact_info(customer_id);
CREATE INDEX idx_payment_customer ON payment_method(customer_id);
CREATE INDEX idx_orders_customer_date ON customer_order(customer_id, order_date);
CREATE INDEX idx_order_item_menu ON order_item(menu_item_id);
