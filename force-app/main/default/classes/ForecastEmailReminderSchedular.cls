/******
    Name             : ForecastEmailReminderSchedular
    Description      : This is the Schedular class that helps to schedule the ForecstEmailReminderHandler.
*****/

global class ForecastEmailReminderSchedular implements Schedulable {
    global void execute(SchedulableContext ctx) {
        ForecastEmailReminderHandler.sendMailToGroupMember();
    }
}