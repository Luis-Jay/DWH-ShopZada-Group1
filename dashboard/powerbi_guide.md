# ShopZada Power BI Dashboard Guide

## Overview
This guide helps you create a comprehensive Power BI dashboard for ShopZada's data warehouse using the optimized views we've prepared.

## Data Sources

### Primary Views for Power BI:
1. **`presentation.view_orders_with_dimensions`** - Main transactional data with all dimensions joined
2. **`presentation.view_dashboard_summary`** - Aggregated metrics for KPIs and summary charts
3. **`presentation.mat_agg_daily_sales`** - Daily sales aggregations for time series
4. **`presentation.view_customer_segments`** - Customer segmentation analysis
5. **`presentation.view_merchant_performance`** - Merchant performance metrics
6. **`presentation.view_campaign_effectiveness`** - Campaign ROI and effectiveness

## Power BI Setup Steps

### 1. Connect to PostgreSQL
```
Server: localhost (or your PostgreSQL host)
Database: shopzada_dwh
Username: shopzada
Password: shopzada123
```

### 2. Import Data
- Select the presentation schema
- Import the views listed above
- **Important:** Use DirectQuery mode for real-time data or Import mode for scheduled refreshes

### 3. Dashboard Layout Design

#### Page 1: Executive Summary
```
┌─────────────────────────────────────────────────┐
│           SHOPZADA EXECUTIVE DASHBOARD          │
│                                                 │
│  [KPI Cards - Revenue, Orders, Customers]       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │
│  │ $1.2M Total │ │ 15.2K Orders│ │ 8.9K Cust. │ │
│  │ Revenue     │ │             │ │            │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ │
│                                                 │
│  [Revenue Trend Line Chart - Monthly]           │
│  ┌─────────────────────────────────────────────┐ │
│  │ ███████████████████████████████████████████ │ │
│  └─────────────────────────────────────────────┘ │
│                                                 │
│  [Top 5 Merchants & Customer Segments]          │
│  ┌─────────────────────┐ ┌─────────────────────┐ │
│  │ Merchant Revenue    │ │ Customer Segments    │ │
│  │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │ │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │ │
│  └─────────────────────┘ └─────────────────────┘ │
└─────────────────────────────────────────────────┘
```

#### Page 2: Sales Analytics
```
┌─────────────────────────────────────────────────┐
│              SALES PERFORMANCE                  │
│                                                 │
│  [Time Slicers - Date Range, Month, Quarter]    │
│                                                 │
│  [Revenue by Product Category]                  │
│  ┌─────────────────────────────────────────────┐ │
│  │ Product A: 35%   ████████████████████       │ │
│  │ Product B: 28%   ███████████████████         │ │
│  │ Product C: 20%   █████████████               │ │
│  └─────────────────────────────────────────────┘ │
│                                                 │
│  [Daily Sales Trend]                            │
│  ┌─────────────────────────────────────────────┐ │
│  │ 📈📈📈📈📈📈📈📈📈📈📈📈📈📈📈📈📈📈📈📈 │ │
│  └─────────────────────────────────────────────┘ │
│                                                 │
│  [Geographic Sales Map - if location data]      │
└─────────────────────────────────────────────────┘
```

#### Page 3: Customer Insights
```
┌─────────────────────────────────────────────────┐
│             CUSTOMER ANALYTICS                  │
│                                                 │
│  [Customer Segmentation by Job Level]           │
│  ┌─────────────────────────────────────────────┐ │
│  │ Executive: 45%   █████████████████████████  │ │
│  │ Manager: 30%     ███████████████████        │ │
│  │ Staff: 25%       ███████████████            │ │
│  └─────────────────────────────────────────────┘ │
│                                                 │
│  [Customer Lifetime Value vs Frequency]         │
│  ┌─────────────────────────────────────────────┐ │
│  │ Scatter Plot: High Value Customers          │ │
│  └─────────────────────────────────────────────┘ │
│                                                 │
│  [Churn Analysis - if available]                │
└─────────────────────────────────────────────────┘
```

#### Page 4: Operational Metrics
```
┌─────────────────────────────────────────────────┐
│           OPERATIONAL DASHBOARD                 │
│                                                 │
│  [Delivery Performance KPIs]                    │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │
│  │ 94.2% On-   │ │ 24hrs Avg   │ │ 2.1% Late   │ │
│  │ Time        │ │ Delivery    │ │ Deliveries  │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ │
│                                                 │
│  [Merchant Performance Matrix]                  │
│  ┌─────────────────────────────────────────────┐ │
│  │ Merchant │ Orders │ Revenue │ On-Time %     │ │
│  │──────────│────────│─────────│────────────   │ │
│  │ ShopA    │ 1,234  │ $45K    │ 96.5%        │ │
│  │ ShopB    │ 987    │ $32K    │ 92.1%        │ │
│  └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

#### Page 5: Campaign Analytics
```
┌─────────────────────────────────────────────────┐
│            CAMPAIGN PERFORMANCE                 │
│                                                 │
│  [Campaign ROI Dashboard]                       │
│  ┌─────────────────────────────────────────────┐ │
│  │ Campaign │ Orders │ Revenue │ Avail Rate %  │ │
│  │──────────│────────│─────────│─────────────  │ │
│  │ Summer   │ 2,341  │ $89K    │ 23.4%        │ │
│  │ Holiday  │ 1,892  │ $67K    │ 31.2%        │ │
│  └─────────────────────────────────────────────┘ │
│                                                 │
│  [Campaign Trend Analysis]                      │
│  ┌─────────────────────────────────────────────┐ │
│  │ 📊📊📊📊📊📊📊📊📊📊📊📊📊📊📊📊📊📊📊📊 │ │
│  └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

## Key DAX Measures to Create

### Revenue Metrics
```dax
Total Revenue = SUM('view_orders_with_dimensions'[net_amount])

Monthly Revenue =
CALCULATE(
    [Total Revenue],
    DATESMTD('dim_date'[full_date])
)

Revenue Growth % =
VAR CurrentRevenue = [Total Revenue]
VAR PreviousRevenue =
    CALCULATE(
        [Total Revenue],
        DATEADD('dim_date'[full_date], -1, MONTH)
    )
RETURN
    DIVIDE(CurrentRevenue - PreviousRevenue, PreviousRevenue)
```

### Customer Metrics
```dax
Total Customers = DISTINCTCOUNT('view_orders_with_dimensions'[customer_id])

New Customers =
CALCULATE(
    [Total Customers],
    FILTER(
        'view_orders_with_dimensions',
        'view_orders_with_dimensions'[order_date] >= DATE(2024, 1, 1)
    )
)

Customer Lifetime Value =
DIVIDE(
    [Total Revenue],
    [Total Customers]
)
```

### Operational Metrics
```dax
On-Time Delivery Rate =
VAR OnTimeOrders =
    CALCULATE(
        COUNT('view_orders_with_dimensions'[order_id]),
        'view_orders_with_dimensions'[on_time_delivery] = TRUE
    )
VAR TotalOrders = COUNT('view_orders_with_dimensions'[order_id])
RETURN
    DIVIDE(OnTimeOrders, TotalOrders)

Average Order Value = AVERAGE('view_orders_with_dimensions'[net_amount])
```

## Data Refresh Strategy

### For Development:
- Use **Import Mode** for faster performance
- Schedule refreshes every 4-6 hours

### For Production:
- Consider **DirectQuery** for real-time dashboards
- Or **Import Mode** with automated refreshes via Power BI Gateway

## Best Practices

1. **Use hierarchies** for date dimensions (Year > Quarter > Month > Date)
2. **Create measure tables** for KPIs and calculations
3. **Implement row-level security** for different user roles
4. **Use themes** for consistent branding
5. **Add drill-through pages** for detailed analysis
6. **Optimize with aggregations** for large datasets

## Performance Tips

- Use the aggregated views (`view_dashboard_summary`) for KPI cards
- Use the detailed view (`view_orders_with_dimensions`) for drill-down analysis
- Create summarized tables for large datasets
- Use Power BI aggregations feature for automatic optimization

## Sample Report Structure
```
📊 ShopZada Analytics Report.pbix
├── 📄 Executive Summary
├── 📄 Sales Performance
├── 📄 Customer Insights
├── 📄 Operations Dashboard
└── 📄 Campaign Analytics
```

This dashboard will give you comprehensive insights into ShopZada's business performance across all key metrics!
