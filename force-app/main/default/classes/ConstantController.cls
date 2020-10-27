/*******
        Name                : ConstantController
        Description         : This is controller class that consist the constants values that are used in the whole Org.
*******/

public class ConstantController{
    public static string DEFAULT_PART_PRODUCT = 'Default Part Forecast';
    public static string DEFAULT_CONCORE_PRODUCT = 'Default Concore Forecast';
    public static string DEFAULT_RAWGLASS_PRODUCT = 'Default Raw Glass Forecast';
    
    //OpportunityForecastActions
    public static string RESTORE_COMPLETRD_ERR_MSG = 'This program has been completed prior to the previous or current month. Any completed forecasts will not be reopened.';
    public static string RESTORE_ACTIVE_ERR_MSG = 'This program is active or has no forecast and does not need re-opened.';
}