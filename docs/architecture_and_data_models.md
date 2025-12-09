
# 1. Architecture & Data Models

## 1.1. High-Level Architecture

For ShopZada's data warehouse, we propose a multi-layered architecture designed to ensure data quality, scalability, and ease of use for analytics. This architecture is composed of three main layers:

*   **Staging Layer:** This is the first stop for raw data from ShopZada's various source systems (e.g., transactional databases, CRM, marketing platforms).
    *   **Purpose:** To hold an exact copy of the source data with minimal transformations. This layer acts as a buffer, decoupling the ingestion process from the downstream transformations. It allows for auditing and historical tracking of data changes. For ShopZada, this means ingesting data from all departments into a centralized location without altering it, preserving the original data integrity.

*   **Warehouse Layer (Integration Layer):** This layer sits at the heart of the data warehouse.
    *   **Purpose:** To integrate, clean, and transform the raw data from the Staging Layer into a structured, subject-oriented format. Here, we apply business rules, perform data quality checks, and model the data using Kimball's dimensional modeling (star schema). The result is a series of integrated fact and dimension tables that represent ShopZada's business processes, such as "Order Fulfillment."

*   **Presentation Layer (Data Marts):** This is the top layer, which serves the end-users and their analytical tools.
    *   **Purpose:** To provide a simplified, aggregated, and user-friendly view of the data stored in the Warehouse Layer. This layer often consists of denormalized tables, analytical views, or materialized views tailored to specific business functions (e.g., marketing, sales, finance). For ShopZada, this would include views like `view_campaign_performance` to make it easy for business users to build reports and dashboards without needing to understand the complexities of the underlying data model.

## 1.2. Data Modeling Methodology

We have chosen **Kimball's dimensional modeling (star schema)** for ShopZada's data warehouse for the following reasons:

*   **Understandability:** Star schemas are intuitive and easy for business users to understand. They consist of a central fact table surrounded by descriptive dimension tables, mirroring the way business users think about their processes.
*   **Performance:** The simple join structure of a star schema allows for faster query performance compared to highly normalized models like 3NF. This is crucial for the interactive analysis and reporting needs of a large-scale e-commerce platform like ShopZada.
*   **Flexibility and Extensibility:** Dimensional models are easily extensible. New dimensions and facts can be added to the schema with minimal impact on existing queries and reports, allowing the data warehouse to evolve with the business.
*   **BI Tool Compatibility:** Most Business Intelligence (BI) and reporting tools are optimized to work with star schemas, making it easier to build and maintain dashboards and reports.

## 1.3. Conceptual & Logical Model: Order Fulfillment

The "Order Fulfillment" business process is central to ShopZada's operations. Here's a breakdown of the conceptual and logical model:

*   **Business Process:** Order Fulfillment
*   **Grain:** The grain of the fact table will be **one row per line item in an order**. This provides the most detailed level of information, allowing for analysis of individual products within an order.
*   **Dimensions:**
    *   **DimDate:** A date dimension containing attributes like `day`, `month`, `year`, `quarter`, `day_of_week`, etc. This will be linked to the order date.
    *   **DimCustomer:** A dimension containing all information about customers, such as `name`, `email`, `address`, and demographic data. It will be designed as a Slowly Changing Dimension (SCD) Type 2 to track changes in customer attributes over time.
    *   **DimProduct:** A dimension containing product details like `product_name`, `category`, `brand`, and `price`.
    *   **DimMerchant:** A dimension with information about the merchants selling products on the platform, including `merchant_name`, `category`, and `location`.
    *   **DimCampaign:** A dimension to track marketing campaigns, with attributes like `campaign_name`, `start_date`, and `end_date`.
*   **Facts:** The `FactOrderLineItems` table will contain the following numeric and additive measures:
    *   `quantity_ordered`: The number of units of a product in a line item.
    *   `price_per_unit`: The price of a single unit of the product.
    *   `total_price`: The total price for the line item (`quantity_ordered` * `price_per_unit`).
    *   `discount_amount`: The discount applied to the line item.
    *   `shipping_cost`: The cost of shipping for the line item.
    *   `tax_amount`: The tax amount for the line item.

This model will enable a wide range of analytical queries, from high-level summaries of sales trends to detailed analysis of product performance and customer behavior.
