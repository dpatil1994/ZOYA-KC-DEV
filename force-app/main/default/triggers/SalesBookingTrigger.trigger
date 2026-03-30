trigger SalesBookingTrigger on Opportunity (after insert) {

    if (Trigger.isAfter && Trigger.isInsert) {

        TriggerHandler__c setting = TriggerHandler__c.getInstance('SalesBookingTrigger');

        if(setting != null && setting.Active__c){
            SalesBookingInstallmentHandler.generateInstallments(Trigger.new);
        }
    }
}