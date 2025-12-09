# ShopZada Data Warehouse - Power BI Dashboard

## Overview
This guide provides step-by-step instructions for creating a comprehensive Power BI dashboard using the ShopZada data warehouse presentation layer.

## Prerequisites
- Power BI Desktop (latest version)
- Access to PostgreSQL database (`shopzada_dwh`)
- Database connection credentials

## 1. Data Connection Setup

### Connect to PostgreSQL Database
1. Open Power BI Desktop
2. Click **Get Data** → **PostgreSQL database**
3. Enter connection details:
   ```
   Server: localhost (or your PostgreSQL host)
   Database: shopzada_dwh
   ```
4. Choose **DirectQuery** or **Import** mode (Import recommended for dashboard performance)
5. Select the following tables from the `presentation` schema:
   - `view_customer_segments`
   - `view_merchant_performance`
   - `view_campaign_effectiveness`
   - `mat_agg_daily_sales`

## 2. Data Modeling

### Create Relationships
1. **Date Relationships**: Connect date fields across tables
2. **Dimension Tables**: If needed, import key dimension tables:
   - `warehouse.dim_customer`
   - `warehouse.dim_merchant`
   - `warehouse.dim_campaign`
   - `warehouse.dim_date`

### Key Measures (DAX Formulas)

```dax
// Revenue Metrics
Total Revenue = SUM('mat_agg_daily_sales'[daily_revenue])
Average Order Value = AVERAGE('mat_agg_daily_sales'[avg_order_value])
Revenue Growth % = DIVIDE([Total Revenue] - CALCULATE([Total Revenue], DATEADD('dim_date'[full_date], -1, MONTH)), CALCULATE([Total Revenue], DATEADD('dim_date'[full_date], -1, MONTH)))

// Customer Metrics
Total Customers = SUM('view_customer_segments'[customer_count])
Customer Satisfaction Rate = AVERAGE('view_merchant_performance'[on_time_delivery_rate])

// Merchant Metrics
Total Merchants = DISTINCTCOUNT('view_merchant_performance'[merchant_name])
Average Merchant Revenue = AVERAGE('view_merchant_performance'[total_revenue])

// Campaign Metrics
Campaign Conversion Rate = AVERAGE('view_campaign_effectiveness'[avail_rate])
Total Campaign Revenue = SUM('view_campaign_effectiveness'[total_revenue])

// Operational Metrics
On-Time Delivery Rate = AVERAGE('view_merchant_performance'[on_time_delivery_rate])
Total Orders = SUM('mat_agg_daily_sales'[daily_orders])
Average Processing Time = AVERAGE('mat_agg_daily_sales'[daily_discounts]) // Placeholder - adjust based on your data
```

## 3. Dashboard Pages Design

### Page 1: Executive Overview
**Layout:**
- **Top Row (KPIs):**
  - Total Revenue (card)
  - Total Orders (card)
  - Total Customers (card)
  - Average Order Value (card)

- **Middle Row:**
  - Revenue Trend Line Chart (by date)
  - Customer Segmentation Pie Chart

- **Bottom Row:**
  - Top 5 Merchants by Revenue (bar chart)
  - Monthly Performance Trend

**Visualizations:**
1. **Revenue Trend**: Line chart with `full_date` on X-axis, `daily_revenue` on Y-axis
2. **Customer Segments**: Pie chart using `view_customer_segments`
3. **Top Merchants**: Bar chart sorted by `total_revenue`

### Page 2: Customer Analytics
**Layout:**
- **Customer Segmentation Analysis**
- **Revenue by Customer Type**
- **Customer Journey Metrics**

**Visualizations:**
1. **Customer Segmentation**: Stacked bar chart showing revenue and order count by job level
2. **Customer Distribution**: Treemap showing customer count by segment
3. **Revenue Concentration**: Pareto chart (80/20 analysis)

### Page 3: Merchant Performance
**Layout:**
- **Merchant Overview Dashboard**
- **Performance Metrics**
- **Geographic Analysis**

**Visualizations:**
1. **Merchant Revenue Ranking**: Horizontal bar chart
2. **Delivery Performance**: Gauge charts for on-time delivery rates
3. **Merchant Comparison**: Scatter plot (revenue vs. delivery rate)

### Page 4: Campaign Analysis
**Layout:**
- **Campaign Effectiveness Dashboard**
- **ROI Analysis**
- **Campaign Performance Trends**

**Visualizations:**
1. **Campaign Performance**: Table/matrix showing conversion rates and revenue
2. **Campaign Trends**: Line chart showing campaign performance over time
3. **ROI Analysis**: Waterfall chart showing campaign costs vs. revenue

### Page 5: Operational Metrics
**Layout:**
- **Daily Operations Dashboard**
- **Performance Monitoring**
- **Quality Metrics**

**Visualizations:**
1. **Daily Sales Trend**: Area chart
2. **Processing Time Analysis**: Histogram/box plot
3. **Quality Metrics**: KPI indicators for delivery performance

## 4. Advanced Features

### Drill-through Functionality
- Enable drill-through from summary views to detailed merchant/customer pages
- Create drill-through pages for detailed analysis

### Custom Tooltips
```dax
Tooltip Revenue = FORMAT([Total Revenue], "Currency")
Tooltip Growth = FORMAT([Revenue Growth %], "Percent")
```

### Conditional Formatting
- Apply data bars, color scales, and icon sets
- Use conditional formatting for performance indicators

### Slicers and Filters
- Date range slicer
- Merchant category filter
- Customer segment filter
- Campaign type filter

## 5. Publishing and Sharing

### Power BI Service
1. **Publish to Power BI Service**
   - Save .pbix file
   - Publish to your workspace

2. **Configure Scheduled Refresh**
   - Set up gateway for PostgreSQL connection
   - Schedule automatic data refresh

3. **Share Dashboard**
   - Share with stakeholders
   - Set up row-level security if needed

## 6. Performance Optimization

### Power BI Best Practices
- Use Import mode for better performance
- Minimize columns loaded
- Use summarized tables where possible
- Avoid complex calculated columns

### Data Refresh Strategy
- Schedule refreshes during off-peak hours
- Monitor refresh performance
- Set up alerts for refresh failures

## 7. Maintenance and Monitoring

### Dashboard Monitoring
- Track usage analytics in Power BI Service
- Monitor data refresh status
- Set up alerts for data quality issues

### Version Control
- Save .pbix files in version control
- Document changes and updates
- Maintain backup copies

## Key Presentation Layer Views Used

1. **`view_customer_segments`**: Customer analysis by job level
2. **`view_merchant_performance`**: Merchant revenue and delivery metrics
3. **`view_campaign_effectiveness`**: Campaign conversion and revenue analysis
4. **`mat_agg_daily_sales`**: Daily aggregated sales data

## Connection Details Summary

```
Host: localhost
Port: 5432
Database: shopzada_dwh
Schema: presentation
Tables: view_customer_segments, view_merchant_performance,
        view_campaign_effectiveness, mat_agg_daily_sales
```

This dashboard will provide comprehensive insights into ShopZada's business performance across customers, merchants, campaigns, and operations.
