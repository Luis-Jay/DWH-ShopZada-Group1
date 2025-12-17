/*
*  ShopZada KPI Card Visual
*
*  Custom Power BI visual for displaying KPI metrics with comparison values
*  and trend indicators.
*/
"use strict";

import powerbi from "powerbi-visuals-api";
import { FormattingSettingsService } from "powerbi-visuals-utils-formattingmodel";
import "./../style/visual.less";

import VisualConstructorOptions = powerbi.extensibility.visual.VisualConstructorOptions;
import VisualUpdateOptions = powerbi.extensibility.visual.VisualUpdateOptions;
import IVisual = powerbi.extensibility.visual.IVisual;
import DataView = powerbi.DataView;
import DataViewCategorical = powerbi.DataViewCategorical;
import DataViewValueColumns = powerbi.DataViewValueColumns;
import DataViewValueColumn = powerbi.DataViewValueColumn;
import DataViewCategoryColumn = powerbi.DataViewCategoryColumn;

import { VisualFormattingSettingsModel } from "./settings";

interface KPIData {
    label: string;
    value: number;
    comparisonValue?: number;
    formattedValue: string;
    formattedComparison: string;
    difference: number;
    percentageChange: number;
    trendDirection: 'up' | 'down' | 'neutral';
}

export class Visual implements IVisual {
    private target: HTMLElement;
    private kpiContainer: HTMLElement;
    private formattingSettings: VisualFormattingSettingsModel;
    private formattingSettingsService: FormattingSettingsService;

    constructor(options: VisualConstructorOptions) {
        this.formattingSettingsService = new FormattingSettingsService();
        this.target = options.element;

        // Create main KPI container
        this.kpiContainer = document.createElement("div");
        this.kpiContainer.className = "kpi-container";
        this.target.appendChild(this.kpiContainer);
    }

    public update(options: VisualUpdateOptions) {
        this.formattingSettings = this.formattingSettingsService.populateFormattingSettingsModel(VisualFormattingSettingsModel, options.dataViews[0]);

        // Clear previous content
        while (this.kpiContainer.firstChild) {
            this.kpiContainer.removeChild(this.kpiContainer.firstChild);
        }

        if (!options.dataViews || !options.dataViews[0]) {
            this.renderNoDataMessage();
            return;
        }

        const dataView = options.dataViews[0];
        const kpiData = this.parseData(dataView);

        if (kpiData) {
            this.renderKPICard(kpiData, options.viewport);
        } else {
            this.renderNoDataMessage();
        }
    }

    private parseData(dataView: DataView): KPIData | null {
        const categorical = dataView.categorical;
        if (!categorical || !categorical.values || categorical.values.length === 0) {
            return null;
        }

        const kpiValueColumn = categorical.values.find(col =>
            col.source.roles && col.source.roles.kpiValue
        );

        const comparisonValueColumn = categorical.values.find(col =>
            col.source.roles && col.source.roles.comparisonValue
        );

        const labelColumn = categorical.categories && categorical.categories.find(cat =>
            cat.source.roles && cat.source.roles.kpiLabel
        );

        if (!kpiValueColumn || kpiValueColumn.values.length === 0) {
            return null;
        }

        // Get the first (or only) value
        const value = kpiValueColumn.values[0] as number;
        const comparisonValue = comparisonValueColumn ? comparisonValueColumn.values[0] as number : undefined;
        const label = labelColumn ? labelColumn.values[0] as string :
                   (this.formattingSettings.kpiCard.labelText.value || "KPI Value");

        // Calculate differences
        let difference = 0;
        let percentageChange = 0;
        let trendDirection: 'up' | 'down' | 'neutral' = 'neutral';

        if (comparisonValue !== undefined && comparisonValue !== 0) {
            difference = value - comparisonValue;
            percentageChange = (difference / Math.abs(comparisonValue)) * 100;
            trendDirection = difference > 0 ? 'up' : difference < 0 ? 'down' : 'neutral';
        }

        return {
            label: label,
            value: value,
            comparisonValue: comparisonValue,
            formattedValue: this.formatValue(value),
            formattedComparison: comparisonValue !== undefined ? this.formatValue(comparisonValue) : "",
            difference: difference,
            percentageChange: percentageChange,
            trendDirection: trendDirection
        };
    }

    private formatValue(value: number): string {
        const format = this.formattingSettings.kpiCard.valueFormat.value.value;

        switch (format) {
            case "currency":
                return new Intl.NumberFormat('en-US', {
                    style: 'currency',
                    currency: 'USD',
                    minimumFractionDigits: 0,
                    maximumFractionDigits: 0
                }).format(value);

            case "percentage":
                return new Intl.NumberFormat('en-US', {
                    style: 'percent',
                    minimumFractionDigits: 1,
                    maximumFractionDigits: 1
                }).format(value / 100);

            default: // number
                return new Intl.NumberFormat('en-US', {
                    minimumFractionDigits: 0,
                    maximumFractionDigits: 2
                }).format(value);
        }
    }

    private renderKPICard(kpiData: KPIData, viewport: powerbi.IViewport) {
        // Apply background styling
        this.kpiContainer.style.backgroundColor = this.formattingSettings.kpiCard.backgroundColor.value.value;
        this.kpiContainer.style.width = `${viewport.width}px`;
        this.kpiContainer.style.height = `${viewport.height}px`;
        this.kpiContainer.style.display = "flex";
        this.kpiContainer.style.flexDirection = "column";
        this.kpiContainer.style.justifyContent = "center";
        this.kpiContainer.style.alignItems = "center";
        this.kpiContainer.style.padding = "20px";
        this.kpiContainer.style.boxSizing = "border-box";

        // Label
        if (this.formattingSettings.kpiCard.showLabel.value) {
            const labelElement = document.createElement("div");
            labelElement.className = "kpi-label";
            labelElement.textContent = kpiData.label;
            labelElement.style.fontFamily = this.formattingSettings.kpiCard.fontFamily.value;
            labelElement.style.fontSize = "14px";
            labelElement.style.color = "#666";
            labelElement.style.marginBottom = "10px";
            labelElement.style.textAlign = "center";
            this.kpiContainer.appendChild(labelElement);
        }

        // Main KPI Value
        const valueElement = document.createElement("div");
        valueElement.className = "kpi-value";
        valueElement.textContent = kpiData.formattedValue;
        valueElement.style.fontFamily = this.formattingSettings.kpiCard.fontFamily.value;
        valueElement.style.fontSize = `${this.formattingSettings.kpiCard.fontSize.value}px`;
        valueElement.style.fontWeight = "bold";
        valueElement.style.color = "#333";
        valueElement.style.textAlign = "center";
        valueElement.style.marginBottom = "10px";
        this.kpiContainer.appendChild(valueElement);

        // Comparison Section
        if (this.formattingSettings.kpiCard.showComparison.value && kpiData.comparisonValue !== undefined) {
            const comparisonContainer = document.createElement("div");
            comparisonContainer.className = "kpi-comparison";
            comparisonContainer.style.display = "flex";
            comparisonContainer.style.alignItems = "center";
            comparisonContainer.style.justifyContent = "center";
            comparisonContainer.style.gap = "10px";

            // Trend indicator
            const trendElement = document.createElement("div");
            trendElement.className = "kpi-trend";
            trendElement.style.fontSize = "18px";
            trendElement.style.fontWeight = "bold";

            // Set trend color and symbol
            const trendColor = this.getTrendColor(kpiData.trendDirection);
            trendElement.style.color = trendColor;

            if (kpiData.trendDirection === 'up') {
                trendElement.textContent = "▲";
            } else if (kpiData.trendDirection === 'down') {
                trendElement.textContent = "▼";
            } else {
                trendElement.textContent = "▶";
            }

            comparisonContainer.appendChild(trendElement);

            // Comparison value
            const comparisonElement = document.createElement("div");
            comparisonElement.className = "kpi-comparison-value";
            comparisonElement.style.fontFamily = this.formattingSettings.kpiCard.fontFamily.value;
            comparisonElement.style.fontSize = "14px";
            comparisonElement.style.color = trendColor;

            const comparisonType = this.formattingSettings.kpiCard.comparisonType.value.value;
            if (comparisonType === "percentage") {
                const sign = kpiData.percentageChange >= 0 ? "+" : "";
                comparisonElement.textContent = `${sign}${kpiData.percentageChange.toFixed(1)}%`;
            } else {
                const sign = kpiData.difference >= 0 ? "+" : "";
                comparisonElement.textContent = `${sign}${this.formatValue(kpiData.difference)}`;
            }

            comparisonContainer.appendChild(comparisonElement);
            this.kpiContainer.appendChild(comparisonContainer);
        }
    }

    private getTrendColor(direction: 'up' | 'down' | 'neutral'): string {
        switch (direction) {
            case 'up':
                return this.formattingSettings.kpiCard.positiveColor.value.value;
            case 'down':
                return this.formattingSettings.kpiCard.negativeColor.value.value;
            default:
                return this.formattingSettings.kpiCard.neutralColor.value.value;
        }
    }

    private renderNoDataMessage() {
        // Clear previous content
        while (this.kpiContainer.firstChild) {
            this.kpiContainer.removeChild(this.kpiContainer.firstChild);
        }

        this.kpiContainer.style.display = "flex";
        this.kpiContainer.style.alignItems = "center";
        this.kpiContainer.style.justifyContent = "center";
        this.kpiContainer.style.backgroundColor = "#f5f5f5";
        this.kpiContainer.style.border = "2px dashed #ccc";
        this.kpiContainer.style.borderRadius = "5px";

        const messageElement = document.createElement("div");
        messageElement.textContent = "Please add KPI Value to display data";
        messageElement.style.color = "#666";
        messageElement.style.fontSize = "14px";
        messageElement.style.textAlign = "center";

        this.kpiContainer.appendChild(messageElement);
    }

    /**
     * Returns properties pane formatting model content hierarchies, properties and latest formatting values, Then populate properties pane.
     * This method is called once every time we open properties pane or when the user edit any format property.
     */
    public getFormattingModel(): powerbi.visuals.FormattingModel {
        return this.formattingSettingsService.buildFormattingModel(this.formattingSettings);
    }
}
