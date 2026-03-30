@IsTest
public class AgencyFileAttachControllerTest {

    @IsTest
    static void testAttachFiles_Corporate() {

        // ---------- Get Record Type ----------
        Id corporateRT = Schema.SObjectType.Agency_Onboarding__c
            .getRecordTypeInfosByDeveloperName()
            .get('Corporate')
            .getRecordTypeId();

        // ---------- Create Agency ----------
        Agency_Onboarding__c agency = new Agency_Onboarding__c(
         //   Name = 'Test Corporate Agency',
            RecordTypeId = corporateRT,
            Company_Email__c = 'corp@test.com'
        );
        insert agency;

        // ---------- Create File ----------
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Content'),
            Guest_Record_fileupload__c = 'corp@test.com'
        );
        insert cv;

        Test.startTest();
        AgencyFileAttachController.attachFiles(agency.Id);
        Test.stopTest();
    }

    @IsTest
    static void testAttachFiles_Individual() {

        // ---------- Get Record Type ----------
        Id individualRT = Schema.SObjectType.Agency_Onboarding__c
            .getRecordTypeInfosByDeveloperName()
            .get('Individual')
            .getRecordTypeId();

        // ---------- Create Agency ----------
        Agency_Onboarding__c agency = new Agency_Onboarding__c(
          //  Name = 'Test Individual Agency',
            RecordTypeId = individualRT,
            Email__c = 'ind@test.com'
        );
        insert agency;

        // ---------- Create File ----------
        ContentVersion cv = new ContentVersion(
            Title = 'Test File 2',
            PathOnClient = 'Test2.pdf',
            VersionData = Blob.valueOf('Test Content 2'),
            Guest_Record_fileupload__c = 'ind@test.com'
        );
        insert cv;

        Test.startTest();
        AgencyFileAttachController.attachFiles(agency.Id);
        Test.stopTest();
    }
}