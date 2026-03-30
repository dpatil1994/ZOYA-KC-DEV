/*public without sharing class AgencyFileAttachHandler {

    public static void attachFiles(List<Agency_Onboarding__c> newAgencies) {

        System.debug('=== START AgencyFileAttachHandler ===');
        System.debug('New Agencies size: ' + newAgencies.size());

        // Step 1: Collect emails
        Map<String, Id> emailToAgencyId = new Map<String, Id>();
        Set<String> emailSet = new Set<String>();

        Id corporateRT = Schema.SObjectType.Agency_Onboarding__c
                .getRecordTypeInfosByDeveloperName()
                .get('Corporate')
                .getRecordTypeId();

        Id individualRT = Schema.SObjectType.Agency_Onboarding__c
                .getRecordTypeInfosByDeveloperName()
                .get('Individual')
                .getRecordTypeId();

        System.debug('Corporate RT Id: ' + corporateRT);
        System.debug('Individual RT Id: ' + individualRT);

        for (Agency_Onboarding__c ag : newAgencies) {

            System.debug('Processing Agency Id: ' + ag.Id);
            System.debug('RecordTypeId: ' + ag.RecordTypeId);

            String email;

            if (ag.RecordTypeId == corporateRT) {
                email = ag.Company_Email__c;
                System.debug('Corporate Email: ' + email);
            }
            else if (ag.RecordTypeId == individualRT) {
                email = ag.Email__c;
                System.debug('Individual Email: ' + email);
            }
            else {
                System.debug('RecordType NOT matched');
            }

            if (String.isNotBlank(email)) {
                email = email.trim().toLowerCase();
                emailSet.add(email);
                emailToAgencyId.put(email, ag.Id);
                System.debug('Added email to map: ' + email);
            } else {
                System.debug('Email is NULL / Blank');
            }
        }

        System.debug('Collected Email Set: ' + emailSet);

        if (emailSet.isEmpty()) {
            System.debug('EXIT: No emails found');
            return;
        }

        // Step 2: Find uploaded files
        List<ContentVersion> cvs = [
            SELECT Id, ContentDocumentId, Guest_Record_fileupload__c
            FROM ContentVersion
            WHERE Guest_Record_fileupload__c IN :emailSet
            AND IsLatest = true
        ];

        System.debug('ContentVersions found: ' + cvs.size());

        if (cvs.isEmpty()) {
            System.debug('EXIT: No files found');
            return;
        }

        // Step 3: Create ContentDocumentLinks
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        List<ContentVersion> versionsToClear = new List<ContentVersion>();


        for (ContentVersion cv : cvs) {

            System.debug('Processing ContentVersion Id: ' + cv.Id);
            System.debug('ContentDocumentId: ' + cv.ContentDocumentId);
            System.debug('Guest_Record_fileupload__c: ' + cv.Guest_Record_fileupload__c);

            if (cv.ContentDocumentId == null) {
                System.debug('SKIP: ContentDocumentId is NULL');
                continue;
            }

            if (String.isBlank(cv.Guest_Record_fileupload__c)) {
                System.debug('SKIP: Guest email is blank');
                continue;
            }

            String email = cv.Guest_Record_fileupload__c.trim().toLowerCase();
            System.debug('Normalized File Email: ' + email);

            if (emailToAgencyId.containsKey(email)) {

                System.debug('MATCH FOUND → Agency Id: ' + emailToAgencyId.get(email));

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
            else {
                System.debug('NO MATCH for email: ' + email);
            }
        }

        System.debug('Total ContentDocumentLinks to insert: ' + links.size());

        if (!links.isEmpty()) {
            insert links;
            System.debug('SUCCESS: ContentDocumentLinks inserted');
            
            if (!versionsToClear.isEmpty()) {
                update versionsToClear;
                System.debug('Guest_Record_fileupload__c cleared');
            }
        }
        else {
            System.debug('EXIT: No links to insert');
        }

        System.debug('=== END AgencyFileAttachHandler ===');
    }
    
} */


public without sharing class AgencyFileAttachQueueable implements Queueable {

    private List<Id> agencyIds;

    public AgencyFileAttachQueueable(List<Id> agencyIds) {
        this.agencyIds = agencyIds;
    }

    public void execute(QueueableContext qc) {

        if (agencyIds == null || agencyIds.isEmpty()) {
            return;
        }

        //  Record Types
        Id corporateRT = Schema.SObjectType.Agency_Onboarding__c
            .getRecordTypeInfosByDeveloperName()
            .get('Corporate')
            .getRecordTypeId();

        Id individualRT = Schema.SObjectType.Agency_Onboarding__c
            .getRecordTypeInfosByDeveloperName()
            .get('Individual')
            .getRecordTypeId();

        // Fetch Agencies
        List<Agency_Onboarding__c> agencies = [
            SELECT Id, RecordTypeId, Email__c, Company_Email__c
            FROM Agency_Onboarding__c
            WHERE Id IN :agencyIds
        ];

        if (agencies.isEmpty()) {
            return;
        }

        // Collect Emails
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
        System.debug('emailSet>>'+emailSet);
        // Fetch Files
        List<ContentVersion> cvs = [
            SELECT Id, ContentDocumentId, Guest_Record_fileupload__c
            FROM ContentVersion
            WHERE Guest_Record_fileupload__c IN :emailSet
        ];

        if (cvs.isEmpty()) {
            return;
        }

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

        if (!links.isEmpty()) {
            Database.insert(links, false); 
        }

        if (!versionsToClear.isEmpty()) {
            update versionsToClear;
        }
    }
}