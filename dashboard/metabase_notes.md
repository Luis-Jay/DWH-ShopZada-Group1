# ShopZada Analytics Dashboard - Metabase Setup

## Overview
This document provides step-by-step instructions for setting up the ShopZada analytics dashboard using Metabase. The dashboard includes three primary cards that answer key business questions about campaign performance, customer segmentation, and sales trends.

## Prerequisites
- Docker Compose infrastructure running (including Metabase service)
- PostgreSQL database populated with transformed data
- Metabase accessible at http://localhost:3000

## Getting Started with Metabase

### Check if Metabase is Running
1. Verify Docker containers are running:
   ```bash
   docker ps | grep metabase
   ```

2. If Metabase isn't running, start it:
   ```bash
   docker-compose up -d metabase
   ```

3. Wait 1-2 minutes for Metabase to fully initialize

### First-Time Setup
1. Open http://localhost:3000 in your browser
2. You'll be prompted to create an admin account:
   - **Email**: admin@shopzada.com
   - **Password**: admin123
   - **Company/Organization**: ShopZada
   - **Department**: Data Team (optional)

3. Click "Next" and complete the setup wizard

## Database Connection Setup

### Step 1: Access Metabase
1. Open your browser and navigate to http://localhost:3000
2. On first access, you'll be prompted to create an admin account
3. Use these credentials (or customize as needed):
   - Email: admin@shopzada.com
   - Password: admin123
   - Organization: ShopZada

### Step 2: Connect to PostgreSQL Database
1. Click "Add your data" or go to Admin Panel → Databases
2. Select "PostgreSQL" as the database type
3. Enter connection details:
   ```
   Host: postgres
   Port: 5432
   Database name: shopzada_dwh
   Username: shopzada
   Password: shopzada123
   ```
4. Test the connection and save

### Step 3: Verify Data Access
1. Go to "Browse Data" in the main navigation
2. You should see the following schemas:
   - `staging` (raw data)
   - `warehouse` (star schema dimensions and facts)
   - `presentation` (views and aggregations)

## Quick Start Dashboard Creation

### Step-by-Step Dashboard Setup
1. **Create New Dashboard**: Click "New" → "Dashboard" → Name it "ShopZada Analytics"
2. **Add First Card - Campaign Performance**:
   - Click "Add a question" → "Native query"
   - Copy the campaign effectiveness query (using presentation view)
   - Save question as "Campaign Performance"
   - Visualize as bar chart
3. **Add Second Card - Customer Segments**:
   - Add another question with customer segments query
   - Visualize as pie chart
4. **Add Third Card - Sales Trends**:
   - Add question with sales trends query
   - Visualize as line chart
5. **Arrange Dashboard**: Drag cards into desired layout

## Dashboard Cards Setup

### Card 1: Campaign Performance Leaderboard

**Purpose**: Identify top-performing marketing campaigns for budget allocation

**Visualization Type**: Bar Chart

**SQL Query** (using presentation view):
```sql
SELECT
    campaign_name,
    total_orders,
    total_revenue,
    avail_rate
FROM presentation.view_campaign_effectiveness
ORDER BY total_revenue DESC
LIMIT 10;
```

**Alternative SQL Query** (direct warehouse query):
```sql
SELECT
    c.campaign_name,
    COUNT(DISTINCT fcp.order_id) as total_orders,
    SUM(fs.gross_amount) as total_revenue,
    ROUND(AVG(fs.gross_amount), 2) as avg_order_value,
    ROUND(100.0 * SUM(CASE WHEN fcp.availed THEN 1 ELSE 0 END) / COUNT(*), 2) as avail_rate
FROM warehouse.fact_campaign_performance fcp
JOIN warehouse.dim_campaign c ON fcp.campaign_key = c.campaign_key
LEFT JOIN warehouse.fact_orders fs ON fcp.order_id::VARCHAR = fs.order_id
WHERE c.is_current = true
GROUP BY c.campaign_name
ORDER BY total_revenue DESC
LIMIT 10;
```

**Chart Configuration**:
- X-axis: campaign_name
- Y-axis: total_revenue
- Additional metrics: Display as data labels (total_orders, avail_rate)
- Color: Use gradient based on total_revenue

### Card 2: Customer Segment Revenue Analysis

**Purpose**: Understand customer segmentation for targeted marketing

**Visualization Type**: Pie Chart

**SQL Query** (using presentation view - recommended):
```sql
SELECT
    job_level,
    customer_count,
    total_orders,
    total_revenue,
    avg_order_value,
    revenue_percentage
FROM presentation.view_customer_segments
ORDER BY total_revenue DESC;
```

**Alternative SQL Query** (direct warehouse query):
```sql
SELECT
    dc.job_level,
    SUM(fo.gross_amount) as total_revenue,
    COUNT(DISTINCT fo.customer_key) as customer_count,
    ROUND(AVG(fo.gross_amount), 2) as avg_order_value,
    ROUND(100.0 * SUM(fo.gross_amount) / SUM(SUM(fo.gross_amount)) OVER (), 2) as revenue_percentage
FROM warehouse.fact_orders fo
JOIN warehouse.dim_customer dc ON fo.customer_key = dc.customer_key
WHERE dc.is_current = true
GROUP BY dc.job_level
ORDER BY total_revenue DESC;
```

**Chart Configuration**:
- Slice values: total_revenue
- Slice labels: job_level + revenue_percentage
- Colors: Use distinct colors for each job_level segment
- Show legend and percentages

### Card 3: Daily Sales Trend Analysis

**Purpose**: Monitor sales performance and identify trends

**Visualization Type**: Line Chart

**SQL Query**:
```sql
SELECT
    DATE_TRUNC('month', full_date) as month,
    SUM(daily_revenue) as monthly_revenue,
    SUM(daily_orders) as monthly_orders,
    ROUND(AVG(avg_order_value), 2) as avg_monthly_order_value
FROM presentation.mat_agg_daily_sales
WHERE full_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', full_date)
ORDER BY month;
```

**Chart Configuration**:
- X-axis: month (formatted as "MMM YYYY")
- Y-axis: monthly_revenue (primary), monthly_orders (secondary)
- Line style: Solid line with markers
- Add trend line for revenue growth

## Dashboard Layout

### Recommended Dashboard Structure
```
┌─────────────────────────────────────────────────────────────┐
│                SHOPZADA SALES ANALYTICS DASHBOARD           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─ Campaign Performance Leaderboard ─────────────────────┐  │
│  │  [Bar Chart - Top 10 campaigns by revenue]             │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌─ Customer Segment Analysis ─┬─ Daily Sales Trends ──────┐  │
│  │  [Pie Chart]                │  [Line Chart]              │  │
│  │                             │                           │  │
│  └─────────────────────────────┴───────────────────────────┘  │
│                                                             │
│  ┌─ Key Metrics Summary ────────────────────────────────────┐  │
│  │  Total Revenue: $XXX,XXX │ Orders: XX,XXX │ Customers: │  │
│  │  XXX,XXX                  │                            │  │
│  └─────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Advanced Dashboard Features

### Filters and Parameters
1. **Date Range Filter**: Add a date filter to all cards
   - Field: `warehouse.dim_date.full_date`
   - Default: Last 30 days

2. **Campaign Filter**: Multi-select dropdown for campaign analysis
   - Field: `warehouse.dim_campaign.campaign_name`

3. **Customer Segment Filter**: Filter by job level
   - Field: `warehouse.dim_customer.job_level`

### Refresh Schedule
- Set dashboard to auto-refresh every 4 hours
- Configure alerts for:
  - Revenue drops > 20% from previous period
  - Campaign performance below threshold

## Business Insights Interpretation

### Campaign Performance Card
- **Revenue Leaders**: Top campaigns by total revenue
- **Engagement Rate**: Campaigns with highest avail_rate
- **ROI Focus**: Compare campaign cost vs. revenue generated

### Customer Segment Card
- **Revenue Distribution**: Which job levels drive most revenue
- **Customer Concentration**: Balance between customer count and revenue
- **Targeting Opportunities**: Segments with high avg_order_value

### Sales Trend Card
- **Growth Patterns**: Monthly revenue trends
- **Seasonal Effects**: Peak and trough periods
- **Order Volume**: Correlation between order count and revenue

## Troubleshooting

### Common Issues

1. **No data displayed**
   - Verify ETL pipeline has completed successfully
   - Check database connection in Metabase
   - Ensure queries use correct schema names

2. **Slow dashboard loading**
   - Add indexes to frequently queried columns
   - Use materialized views for complex aggregations
   - Implement query result caching

3. **Permission errors**
   - Ensure database user has SELECT permissions on all schemas
   - Check if views are accessible

### Performance Optimization
- Use `presentation` schema views instead of direct warehouse queries
- Implement materialized views for complex aggregations
- Add appropriate indexes on date and dimension key columns

## Maintenance

### Regular Tasks
1. **Data Refresh**: Ensure ETL pipeline runs successfully
2. **View Updates**: Refresh materialized views after data loads
3. **Dashboard Review**: Update visualizations based on new business requirements

### Monitoring
- Set up alerts for dashboard failures
- Monitor query performance
- Track user adoption and usage patterns

## Support
For dashboard setup issues or questions:
1. Check Metabase documentation: https://www.metabase.com/docs/
2. Review PostgreSQL logs for data access issues
3. Verify ETL pipeline completion in Airflow

---

*Dashboard last updated: November 2025*
