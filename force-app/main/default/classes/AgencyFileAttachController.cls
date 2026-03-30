public without sharing class AgencyFileAttachController {

    @AuraEnabled
    public static void attachFiles(Id agencyId) {

        if (agencyId == null) {
            throw new AuraHandledException('Agency Id is required');
        }

        List<Id> agencyIds = new List<Id>{ agencyId };

        // ================= Record Types =================
        Id corporateRT = Schema.SObjectType.Agency_Onboarding__c
            .getRecordTypeInfosByDeveloperName()
            .get('Corporate')
            .getRecordTypeId();

        Id individualRT = Schema.SObjectType.Agency_Onboarding__c
            .getRecordTypeInfosByDeveloperName()
            .get('Individual')
            .getRecordTypeId();

        // ================= Fetch Agencies =================
        List<Agency_Onboarding__c> agencies = [
            SELECT Id, RecordTypeId, Email__c, Company_Email__c
            FROM Agency_Onboarding__c
            WHERE Id IN :agencyIds
        ];

        if (agencies.isEmpty()) {
            return;
        }

        // ================= Collect Emails =================
        Map<String, Id> emailToAgencyId = new Map<String, Id>();
        Set<String> emailSet = new Set<String>();

        for (Agency_Onboarding__c ag : agencies) {

            String email;

            if (ag.RecordTypeId == corporateRT) {
                email = ag.Company_Email__c;
            } else if (ag.RecordTypeId == individualRT) {
                email = ag.Email__c;
            }

            if (String.isNotBlank(email)) {
                email = email.trim().toLowerCase();
                emailSet.add(email);
                emailToAgencyId.put(email, ag.Id);
            }
        }

        if (emailSet.isEmpty()) {
            return;
        }

        // ================= Fetch Files =================
        List<ContentVersion> cvs = [
            SELECT Id, ContentDocumentId, Guest_Record_fileupload__c
            FROM ContentVersion
            WHERE Guest_Record_fileupload__c IN :emailSet
        ];

        if (cvs.isEmpty()) {
            return;
        }

        // ================= Create Links =================
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        List<ContentVersion> versionsToClear = new List<ContentVersion>();

        for (ContentVersion cv : cvs) {

            if (cv.ContentDocumentId == null ||
                String.isBlank(cv.Guest_Record_fileupload__c)) {
                continue;
            }

            String email = cv.Guest_Record_fileupload__c.trim().toLowerCase();

            if (emailToAgencyId.containsKey(email)) {

                links.add(new ContentDocumentLink(
                    ContentDocumentId = cv.ContentDocumentId,
                    LinkedEntityId    = emailToAgencyId.get(email),
                    ShareType         = 'V',
                    Visibility        = 'AllUsers'
                ));

                versionsToClear.add(new ContentVersion(
                    Id = cv.Id,
                    Guest_Record_fileupload__c = null
                ));
            }
        }

        // ================= DML =================
        if (!links.isEmpty()) {
            Database.insert(links, false);
        }

        if (!versionsToClear.isEmpty()) {
            update versionsToClear;
        }
    }
}