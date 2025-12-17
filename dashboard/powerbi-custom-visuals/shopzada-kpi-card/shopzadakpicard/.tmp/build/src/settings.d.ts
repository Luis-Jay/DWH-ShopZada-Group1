import { formattingSettings } from "powerbi-visuals-utils-formattingmodel";
import FormattingSettingsCard = formattingSettings.SimpleCard;
import FormattingSettingsSlice = formattingSettings.Slice;
import FormattingSettingsModel = formattingSettings.Model;
/**
 * KPI Card Formatting Card
 */
declare class KPICardSettings extends FormattingSettingsCard {
    showLabel: formattingSettings.ToggleSwitch;
    labelText: formattingSettings.TextInput;
    valueFormat: formattingSettings.ItemDropdown;
    showComparison: formattingSettings.ToggleSwitch;
    comparisonType: formattingSettings.ItemDropdown;
    positiveColor: formattingSettings.ColorPicker;
    negativeColor: formattingSettings.ColorPicker;
    neutralColor: formattingSettings.ColorPicker;
    fontFamily: formattingSettings.FontPicker;
    fontSize: formattingSettings.NumUpDown;
    backgroundColor: formattingSettings.ColorPicker;
    name: string;
    displayName: string;
    slices: Array<FormattingSettingsSlice>;
}
/**
* visual settings model class
*
*/
export declare class VisualFormattingSettingsModel extends FormattingSettingsModel {
    kpiCard: KPICardSettings;
    cards: KPICardSettings[];
}
export {};
