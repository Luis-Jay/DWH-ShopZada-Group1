-- Staging tables mirror source data exactly
CREATE TABLE IF NOT EXISTS staging.business_products (
    product_id INT,
    product_name VARCHAR(255),
    product_type VARCHAR(100),
    price DECIMAL(10,2),
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.customer_management (
    user_id INT,
    name VARCHAR(255),
    job_title VARCHAR(100),
    job_level VARCHAR(50),
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.enterprise_orders (
    order_id INT,
    merchant_id INT,
    staff_id INT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.marketing_transactions (
    transaction_date DATE,
    campaign_id INT,
    order_id INT,
    estimated_arrival DATE,
    availed BOOLEAN,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS staging.marketing_campaigns (
    campaign_id INT,
    campaign_name VARCHAR(255),
    campaign_description TEXT,
    discount VARCHAR(50),
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add staging table for operations department
CREATE TABLE IF NOT EXISTS staging.operations_fulfillment (
    order_id INT,
    delivery_status VARCHAR(50),
    logistics_provider VARCHAR(100),
    warehouse VARCHAR(100),
    processing_time INT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);