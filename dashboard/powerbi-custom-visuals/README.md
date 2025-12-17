# ShopZada Power BI Custom Visuals

This directory contains custom Power BI visuals created specifically for the ShopZada analytics dashboard.

## Available Custom Visuals

### 1. ShopZada KPI Card
**Location:** `shopzada-kpi-card/shopzadakpicard/`

An enhanced KPI card visual with the following features:
- **Main KPI Value Display** with customizable formatting (Number, Currency, Percentage)
- **Comparison Values** with trend indicators (▲ up, ▼ down, ▶ neutral)
- **Difference/Percentage Change** display
- **Color-coded Trends** (green for positive, red for negative, gray for neutral)
- **Customizable Styling** (fonts, colors, backgrounds)
- **Responsive Layout** that adapts to visual size

#### Data Roles:
- **KPI Value** (required): The main metric to display
- **Comparison Value** (optional): Value to compare against for trend calculation
- **KPI Label** (optional): Text label for the KPI

#### Formatting Options:
- Show/hide label
- Custom label text
- Value format selection
- Show/hide comparison
- Comparison type (difference or percentage)
- Custom colors for positive/negative/neutral trends
- Font family and size
- Background color

## Building the Visual

### Prerequisites
1. Install Power BI Visuals Tools globally:
```bash
npm install -g powerbi-visuals-tools
```

2. Navigate to the visual directory:
```bash
cd dashboard/powerbi-custom-visuals/shopzada-kpi-card/shopzadakpicard
```

3. Install dependencies:
```bash
npm install
```

4. Build the visual:
```bash
pbiviz package
```

This will create a `.pbiviz` file in the `dist/` folder.

## Installing in Power BI

### Method 1: Direct Import (Development)
1. Open Power BI Desktop
2. Go to **File > Options and Settings > Options**
3. Select **PREVIEW FEATURES**
4. Check **Custom visuals developer mode**
5. Click **OK** and restart Power BI
6. In Power BI Desktop, go to **Visualizations pane**
7. Click **... > Import a visual from a file**
8. Select the `.pbiviz` file from `dist/` folder

### Method 2: Power BI Service Upload
1. Go to Power BI Service (app.powerbi.com)
2. Navigate to your workspace
3. Click **Settings (gear icon) > Manage personal storage**
4. Upload the `.pbiviz` file
5. The visual will be available in your organization's visual gallery

## Usage in Reports

### Basic Setup
1. Add the "ShopZada KPI Card" visual to your report
2. Drag a measure to the **KPI Value** field
3. (Optional) Drag a comparison measure to **Comparison Value**
4. (Optional) Drag a dimension to **KPI Label**

### Example Usage for ShopZada Dashboard

#### Revenue KPI
- **KPI Value**: `Total Revenue` from `view_dashboard_summary`
- **Comparison Value**: Previous period revenue
- **KPI Label**: "Total Revenue"

#### Customer Growth KPI
- **KPI Value**: `Total Customers` from `view_dashboard_summary`
- **Comparison Value**: Previous period customers
- **KPI Label**: "Active Customers"

#### On-Time Delivery KPI
- **KPI Value**: `On-Time Delivery Rate` (as decimal)
- **Value Format**: Percentage
- **Comparison Value**: Target rate (e.g., 0.95 for 95%)
- **KPI Label**: "Delivery Performance"

## Customization

### Formatting Pane Options
- **KPI Card Settings**:
  - Toggle label visibility
  - Set custom label text
  - Choose value format
  - Configure comparison display
  - Set trend colors
  - Adjust fonts and background

### Advanced Styling
The visual supports:
- Custom color schemes
- Font selection
- Responsive sizing
- Professional KPI card layouts

## Troubleshooting

### Build Issues
- Ensure Node.js and npm are installed
- Clear node_modules: `rm -rf node_modules && npm install`
- Check for TypeScript errors: `npm run build`

### Power BI Import Issues
- Ensure the `.pbiviz` file is not corrupted
- Check Power BI Desktop version compatibility
- Try importing in developer mode first

### Data Issues
- Verify data types match the visual requirements
- Check that KPI Value contains numeric data
- Ensure Comparison Value is also numeric if used

## Development

### Project Structure
```
shopzadakpicard/
├── src/
│   ├── visual.ts      # Main visual logic
│   └── settings.ts    # Formatting settings
├── capabilities.json  # Data role definitions
├── pbiviz.json        # Visual metadata
├── package.json       # Dependencies
└── tsconfig.json      # TypeScript config
```

### Modifying the Visual
1. Edit `src/visual.ts` for logic changes
2. Edit `src/settings.ts` for formatting options
3. Update `capabilities.json` for data roles
4. Run `pbiviz package` to build

### Testing
- Use Power BI Desktop developer mode for testing
- Test with various data scenarios
- Verify formatting options work correctly

## Integration with ShopZada Data

This custom visual is designed to work seamlessly with the ShopZada data warehouse views:

- `presentation.view_dashboard_summary` - Pre-aggregated KPIs
- `presentation.view_orders_with_dimensions` - Detailed order data
- `presentation.mat_agg_daily_sales` - Daily sales metrics

The visual automatically formats values appropriately for the ShopZada business context (revenue, orders, customers, etc.).

## Support

For issues or enhancements:
1. Check the build logs for errors
2. Verify data compatibility
3. Review the formatting settings
4. Test with sample data first

This custom KPI card provides a professional, branded way to display ShopZada's key business metrics with trend analysis and visual appeal.
