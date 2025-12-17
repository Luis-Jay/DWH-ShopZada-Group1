/*
 *  Power BI Visualizations
 *
 *  Copyright (c) Microsoft Corporation
 *  All rights reserved.
 *  MIT License
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the ""Software""), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

"use strict";

import { formattingSettings } from "powerbi-visuals-utils-formattingmodel";

import FormattingSettingsCard = formattingSettings.SimpleCard;
import FormattingSettingsSlice = formattingSettings.Slice;
import FormattingSettingsModel = formattingSettings.Model;

/**
 * KPI Card Formatting Card
 */
class KPICardSettings extends FormattingSettingsCard {
    showLabel = new formattingSettings.ToggleSwitch({
        name: "showLabel",
        displayName: "Show Label",
        value: true
    });

    labelText = new formattingSettings.TextInput({
        name: "labelText",
        displayName: "Label Text",
        value: "KPI Value",
        placeholder: "Enter label text"
    });

    valueFormat = new formattingSettings.ItemDropdown({
        name: "valueFormat",
        displayName: "Value Format",
        items: [
            { value: "number", displayName: "Number" },
            { value: "currency", displayName: "Currency" },
            { value: "percentage", displayName: "Percentage" }
        ],
        value: { value: "number", displayName: "Number" }
    });

    showComparison = new formattingSettings.ToggleSwitch({
        name: "showComparison",
        displayName: "Show Comparison",
        value: true
    });

    comparisonType = new formattingSettings.ItemDropdown({
        name: "comparisonType",
        displayName: "Comparison Type",
        items: [
            { value: "difference", displayName: "Difference" },
            { value: "percentage", displayName: "Percentage" }
        ],
        value: { value: "percentage", displayName: "Percentage" }
    });

    positiveColor = new formattingSettings.ColorPicker({
        name: "positiveColor",
        displayName: "Positive Change Color",
        value: { value: "#00B050" } // Green
    });

    negativeColor = new formattingSettings.ColorPicker({
        name: "negativeColor",
        displayName: "Negative Change Color",
        value: { value: "#FF0000" } // Red
    });

    neutralColor = new formattingSettings.ColorPicker({
        name: "neutralColor",
        displayName: "Neutral Color",
        value: { value: "#A6A6A6" } // Gray
    });

    fontFamily = new formattingSettings.FontPicker({
        name: "fontFamily",
        displayName: "Font Family",
        value: "Segoe UI"
    });

    fontSize = new formattingSettings.NumUpDown({
        name: "fontSize",
        displayName: "Font Size",
        value: 24
    });

    backgroundColor = new formattingSettings.ColorPicker({
        name: "backgroundColor",
        displayName: "Background Color",
        value: { value: "#FFFFFF" } // White
    });

    name: string = "kpiCard";
    displayName: string = "KPI Card Settings";
    slices: Array<FormattingSettingsSlice> = [
        this.showLabel,
        this.labelText,
        this.valueFormat,
        this.showComparison,
        this.comparisonType,
        this.positiveColor,
        this.negativeColor,
        this.neutralColor,
        this.fontFamily,
        this.fontSize,
        this.backgroundColor
    ];
}

/**
* visual settings model class
*
*/
export class VisualFormattingSettingsModel extends FormattingSettingsModel {
    // Create formatting settings model formatting cards
    kpiCard = new KPICardSettings();

    cards = [this.kpiCard];
}
