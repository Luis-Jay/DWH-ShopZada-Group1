# ROAS (Return on Ad Spend) Measures for Power BI Dashboard

## Overview
This guide shows how to create ROAS measures and visuals in your Power BI campaign performance dashboard.

## ROAS Formula
**ROAS = Campaign Revenue ÷ Campaign Ad Spend**

Example: If you spend ₱10,000 on ads and generate ₱25,000 in revenue, ROAS = 2.5x

---

## Power BI Measures

### 1. Basic ROAS Measure
```dax
Campaign ROAS = FORMAT(
    DIVIDE(
        SUM('view_campaign_effectiveness'[total_revenue]),
        SUM('view_campaign_effectiveness'[campaign_cost])
    ),
    "0.00x"
)
```

### 2. Campaign-Specific ROAS
```dax
Campaign ROAS by Name =
FORMAT(
    DIVIDE(
        SUM('view_campaign_effectiveness'[total_revenue]),
        SUM('view_campaign_effectiveness'[campaign_cost])
    ),
    "0.00x"
)
```

### 3. ROAS Performance Rating
```dax
ROAS Rating =
SWITCH(
    TRUE(),
    [Campaign ROAS by Name] >= 3, "Excellent (3x+)",
    [Campaign ROAS by Name] >= 2, "Good (2-3x)",
    [Campaign ROAS by Name] >= 1, "Break-even (1-2x)",
    [Campaign ROAS by Name] < 1, "Poor (<1x)",
    "No Data"
)
```

### 4. Campaign Profit Measure
```dax
Campaign Profit =
FORMAT(
    SUM('view_campaign_effectiveness'[total_revenue]) -
    SUM('view_campaign_effectiveness'[campaign_cost]),
    "₱#,##0"
)
```

### 5. ROAS Trend Over Time
```dax
Monthly ROAS Trend =
FORMAT(
    DIVIDE(
        SUM('view_orders_with_dimensions'[net_amount]),
        AVERAGE('view_campaign_effectiveness'[campaign_cost])
    ),
    "0.00x"
)
```

---

## Dashboard Visuals

### Visual 1: ROAS KPI Card
- **Type:** KPI Card (built-in)
- **Value:** `Campaign ROAS`
- **Target:** `3.00` (300% target)
- **Format:** Custom format with "x" suffix

### Visual 2: ROAS by Campaign Bar Chart
- **Type:** Clustered Bar Chart
- **Y-axis:** `campaign_name` (from view_campaign_effectiveness)
- **X-axis:** `Campaign ROAS by Name` measure
- **Sort:** Descending by ROAS value
- **Conditional formatting:**
  - Green: ROAS ≥ 3.0
  - Yellow: ROAS 2.0-2.9
  - Red: ROAS < 2.0

### Visual 3: Campaign Profitability Matrix
- **Type:** Table
- **Columns:**
  - `campaign_name`
  - `Campaign Profit`
  - `ROAS Rating`
  - `total_revenue` (formatted as currency)
  - `campaign_cost` (formatted as currency)

### Visual 4: ROAS vs Revenue Scatter Plot
- **Type:** Scatter Chart
- **X-axis:** `campaign_cost` (bubble size)
- **Y-axis:** `Campaign ROAS by Name`
- **Details:** `campaign_name`
- **Size:** `total_revenue`

### Visual 5: Monthly ROAS Trend
- **Type:** Line Chart
- **X-axis:** `order_date` (by month)
- **Y-axis:** `Monthly ROAS Trend`
- **Legend:** `campaign_name`

---

## Sample Dashboard Layout

```
🎯 CAMPAIGN ROAS DASHBOARD

📊 Overall Metrics
├── 💰 Total Campaign Revenue: ₱1.2M
├── 💸 Total Campaign Spend: ₱1.3M
├── 📈 Average ROAS: 2.34x
└── 🎯 Target ROAS: 3.00x

📈 ROAS Performance by Campaign
┌─────────────────────────────────────┐
│ Campaign Name     │ ROAS   │ Profit │
├───────────────────┼────────┼────────┤
│ me neither        │ 3.45x  │ ₱156K  │ 🟢
│ stick a fork...   │ 2.89x  │ ₱123K  │ 🟡
│ you must be...    │ 2.12x  │ ₱98K   │ 🟡
│ how do I get...   │ 1.87x  │ ₱67K   │ 🔴
└─────────────────────────────────────┘

📊 ROAS Trend Over Time
[Line chart showing monthly ROAS for each campaign]
```

---

## Implementation Steps

### Step 1: Run the SQL Script
Execute `scripts/add_roas_to_warehouse.sql` in your PostgreSQL database to add ROAS functionality.

### Step 2: Refresh Power BI Data
- Go to Power BI Desktop
- Click "Refresh" to load new ROAS data
- Verify new columns appear in `view_campaign_effectiveness`

### Step 3: Create Measures
- Go to "Modeling" tab
- Click "New Measure" for each ROAS calculation
- Copy the DAX formulas above

### Step 4: Build Visuals
- Add visuals to Page 2 of your dashboard
- Configure fields as specified above
- Apply conditional formatting

### Step 5: Add Slicers
- Campaign name slicer
- Date range slicer
- ROAS performance filter slicer

---

## ROAS Benchmarks

| ROAS Range | Performance | Action |
|------------|-------------|--------|
| < 1.0x | Loss-making | Cut campaign budget |
| 1.0x - 2.0x | Break-even | Monitor performance |
| 2.0x - 3.0x | Profitable | Scale up budget |
| > 3.0x | High ROI | Maximize investment |

---

## Troubleshooting

### Issue: ROAS Shows "Infinity" or "NaN"
**Cause:** Campaign cost is zero or null
**Fix:** Ensure all campaigns have cost data in the database

### Issue: ROAS Values Too High/Low
**Cause:** Incorrect cost data
**Fix:** Verify campaign_cost values in dim_campaign table

### Issue: Measures Not Appearing
**Cause:** Data not refreshed
**Fix:** Click "Refresh" in Power BI and check data source

---

## Advanced ROAS Analysis

### 1. ROAS by Channel (if available)
```dax
ROAS by Channel =
FORMAT(
    DIVIDE(
        SUM('view_campaign_effectiveness'[total_revenue]),
        SUM('view_campaign_effectiveness'[campaign_cost])
    ),
    "0.00x"
)
```

### 2. Customer Acquisition Cost
```dax
CAC (Customer Acquisition Cost) =
DIVIDE(
    SUM('view_campaign_effectiveness'[campaign_cost]),
    SUM('view_campaign_effectiveness'[campaigns_availed])
)
```

### 3. Customer Lifetime Value vs CAC
```dax
CLV to CAC Ratio =
DIVIDE(
    [Average Customer Lifetime Value],
    [CAC (Customer Acquisition Cost)]
)
```

---

## Next Steps

1. **Run the SQL script** to add ROAS to your warehouse
2. **Refresh Power BI** data source
3. **Create the measures** listed above
4. **Build the dashboard visuals**
5. **Set up performance monitoring** and alerts

**Your campaign dashboard now includes comprehensive ROAS analysis!** 📊💰🎯
