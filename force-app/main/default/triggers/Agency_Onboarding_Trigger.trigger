trigger Agency_Onboarding_Trigger on Agency_Onboarding__c (after insert) {

    Set<Id> agencyIds = new Set<Id>();

    for (Agency_Onboarding__c ag : Trigger.new) {
        agencyIds.add(ag.Id);
    }

    if (!agencyIds.isEmpty()) {
        System.enqueueJob(
            new AgencyFileAttachQueueable(new List<Id>(agencyIds))
        );
    }
}