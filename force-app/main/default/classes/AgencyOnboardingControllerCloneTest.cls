/**
* @File Name  :  AgencyOnboardingControllerCloneTest .cls
*@Description : Test class for  AgencyOnboardingControllerClone .
*
* @Author            : KC0126
* @Last Modified By  : Harshita Singh
* @Last Modified On  : December 23, 2025
* @Modification Log  :
*==============================================================================
* Ver | Date         | Author              | Modification
*==============================================================================
*  1.0 | December 15, 2025 |   | Initial Version
*  
**/


@isTest
private class AgencyOnboardingControllerCloneTest {
    @TestSetup
    static void setupTestData() {
        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType 
                                       WHERE SObjectType = 'Agency_Onboarding__c' 
                                       AND IsActive = true 
                                       LIMIT 1];     
        if (!recordTypes.isEmpty()) {
            Agency_Onboarding__c testAgency = new Agency_Onboarding__c(
               // Name = 'Test Agency',
                Agency_Name__c = 'Test Agency LLC',
                RecordTypeId = recordTypes[0].Id,
                Onboarding_Stage__c = 'New',
                Email__c = 'test@agency.com'
            );
            insert testAgency;
        }
    }
    
    @isTest
    static void testGetRecordTypes() {
        Test.startTest();
        List<Map<String, String>> result = AgencyOnboardingControllerClone.getRecordTypes();
        Test.stopTest();
    }

    @isTest
    static void testGetAllPicklistValues() {
        Test.startTest();
        Map<String, List<Map<String, String>>> result = AgencyOnboardingControllerClone.getAllPicklistValues();
        Test.stopTest();
        List<Map<String, String>> accountTypes = result.get('AccountTypeOptions');
        List<Map<String, String>> currencies = result.get('CurrencyOptions');
        List<Map<String, String>> bankBranches = result.get('BankBranchOptions');
        List<Map<String, String>> countries = result.get('CountryOptions');
        List<Map<String, String>> bankNames = result.get('BankNameOptions'); 
    }

    @isTest
    static void testGetPicklistValuesWithRecordType() {
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'Agency_Onboarding__c' AND IsActive = true LIMIT 1];  
        if (recordTypes.isEmpty()) {
            return; 
        }
        Test.startTest();
        Map<String, List<Map<String, String>>> result = AgencyOnboardingControllerClone.getPicklistValues(recordTypes[0].Id);
        Test.stopTest();   
    }
    
    @isTest
    static void testCreateAgencySuccess() {
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'Agency_Onboarding__c' AND IsActive = true LIMIT 1];  
        if (recordTypes.isEmpty()) {
            return;
        }
        Map<String, Object> fieldValues = new Map<String, Object>{
            'Agency_Name__c' => 'New Test Agency',
            'Phone__c' => '9876543210',
            'Email__c' => 'newtest@agency.com',
            'Company_Name__c' => 'New Test Company'
        };
        Test.startTest();
        Id result = AgencyOnboardingControllerClone.createAgency(fieldValues, recordTypes[0].Id);
        Test.stopTest();
       // Agency_Onboarding__c createdRecord = [SELECT Id, Name, Agency_Name__c FROM Agency_Onboarding__c WHERE Id = :result];
    } 
    @isTest
    static void testCreateAgencyWithVariousFieldTypes() {
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'Agency_Onboarding__c' AND IsActive = true LIMIT 1];
        if (recordTypes.isEmpty()) {
            return;
        }
        
        Map<String, Object> fieldValues = new Map<String, Object>{
            'First_Name__c' => 'John',
            'Last_Name__c' => 'Doe',
            'Phone__c' => '5551234567',
            'Email__c' => 'john.doe@test.com'
        };
        Test.startTest();
        Id result = AgencyOnboardingControllerClone.createAgency(fieldValues, recordTypes[0].Id);
        Test.stopTest();
    }
    
    @isTest
    static void testCreateAgencyWithoutAgencyName() {
        List<RecordType> recordTypes = [SELECT Id FROM RecordType  WHERE SObjectType = 'Agency_Onboarding__c' AND IsActive = true LIMIT 1];
        if (recordTypes.isEmpty()) {
            return;
        }
        
        Map<String, Object> fieldValues = new Map<String, Object>{
            'Phone__c' => '9876543210',
            'Email__c' => 'test@agency.com'
        };
        
        Test.startTest();
        Id result = AgencyOnboardingControllerClone.createAgency(fieldValues, recordTypes[0].Id);
        Test.stopTest();
        
       
    }
    
    

    @isTest
    static void testCreateAgencyWithEmptyValues() {
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'Agency_Onboarding__c' AND IsActive = true LIMIT 1];
        if (recordTypes.isEmpty()) {
            return;
        }
        
        Map<String, Object> fieldValues = new Map<String, Object>{
            'Agency_Name__c' => '',
            'Phone__c' => null,
            'Email__c' => '  '
        };
        
        Test.startTest();
        Id result = AgencyOnboardingControllerClone.createAgency(fieldValues, recordTypes[0].Id);
        Test.stopTest();

    }

    @isTest
    static void testCreateAgencyException() {
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'Agency_Onboarding__c' AND IsActive = true LIMIT 1]; 
        if (recordTypes.isEmpty()) {
            return;
        }

        Map<String, Object> fieldValues = new Map<String, Object>{
            'Invalid_Field__c' => 'Test Value'
        };
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            AgencyOnboardingControllerClone.createAgency(fieldValues, recordTypes[0].Id);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
    }

    @isTest
    static void testGetPicklistFieldNames() {
        Test.startTest();
        Map<String, String> result = AgencyOnboardingControllerClone.getPicklistFieldNames();
        Test.stopTest();
    }

    @isTest
    static void testGetAllPicklistValuesWithMetadata() {
        Test.startTest();
        Map<String, Object> result = AgencyOnboardingControllerClone.getAllPicklistValuesWithMetadata();
        Test.stopTest();
    }

    @isTest
    static void testUploadFiles() {
        List<Agency_Onboarding__c> agencies = [SELECT Id FROM Agency_Onboarding__c LIMIT 1];
        if (agencies.isEmpty()) {
            return;
        }
        Id recordId = agencies[0].Id;
        List<Map<String, Object>> filesData = new List<Map<String, Object>>{
            new Map<String, Object>{
                'name' => 'test1.pdf',
                'docType' => 'License',
                'base64Data' => 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSPj4Kc3RyZWFtCkJUCjAgMCBUZAovRjEgMTIgVGYKKFRlc3QgUERGIGZpbGUpClRqCkVUCg==',
                'type' => 'application/pdf'
            },
            new Map<String, Object>{
                'name' => 'test2.jpg',
                'docType' => 'Photo',
                'base64Data' => '/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=',
                'type' => 'image/jpeg'
            }
        };
        
        Test.startTest();
        AgencyOnboardingControllerClone.uploadFiles(recordId, filesData);
        Test.stopTest();
        List<ContentVersion> contentVersions = [SELECT Id, Title FROM ContentVersion WHERE FirstPublishLocationId = :recordId];
    }

    @isTest
    static void testUploadFilesEmpty() {
        List<Agency_Onboarding__c> agencies = [SELECT Id FROM Agency_Onboarding__c LIMIT 1];
        if (agencies.isEmpty()) {
            return;
        }
        
        Test.startTest();
        AgencyOnboardingControllerClone.uploadFiles(agencies[0].Id, new List<Map<String, Object>>());
        AgencyOnboardingControllerClone.uploadFiles(null, null);
        Test.stopTest();
    }

    @isTest
    static void testUploadAttachments() {
        List<Agency_Onboarding__c> agencies = [SELECT Id FROM Agency_Onboarding__c LIMIT 1];
        if (agencies.isEmpty()) {
            return;
        } 
        Id recordId = agencies[0].Id;
        
        List<Map<String, Object>> filesData = new List<Map<String, Object>>{
            new Map<String, Object>{
                'name' => 'test.doc',
                'docType' => 'Contract',
                'base64Data' => 'dGVzdCBkb2N1bWVudCBjb250ZW50',
                'type' => 'application/msword'
            }
        };
        
        Test.startTest();
        AgencyOnboardingControllerClone.uploadAttachments(recordId, filesData);
        Test.stopTest();
        List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :recordId];
    }

    @isTest
    static void testCreateAgencyWithFiles() {
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'Agency_Onboarding__c' AND IsActive = true LIMIT 1];
        if (recordTypes.isEmpty()) {
            return;
        }
        
        Map<String, Object> fieldValues = new Map<String, Object>{
            'Agency_Name__c' => 'Agency with Files',
            'Phone__c' => '1234567890',
            'Email__c' => 'files@agency.com'
        };
        List<Map<String, Object>> filesData = new List<Map<String, Object>>{
            new Map<String, Object>{
                'name' => 'document.pdf',
                'docType' => 'Agreement',
                'base64Data' => 'JVBERi0xLjQKJcOkw7zDtsOfCjIgMCBvYmoKPDwvTGVuZ3RoIDMgMCBSPj4Kc3RyZWFtCkJUCjAgMCBUZAovRjEgMTIgVGYKKFRlc3QpClRqCkVUCg==',
                'type' => 'application/pdf'
            }
        };
        
        Test.startTest();
        Id result = AgencyOnboardingControllerClone.createAgencyWithFiles(fieldValues, recordTypes[0].Id, filesData);
        Test.stopTest();
        List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion WHERE FirstPublishLocationId = :result];
    }

    @isTest
    static void testCreateAgencyWithFilesNoFiles() {
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'Agency_Onboarding__c' AND IsActive = true LIMIT 1];
        if (recordTypes.isEmpty()) {
            return;
        }
        Map<String, Object> fieldValues = new Map<String, Object>{
            'Agency_Name__c' => 'Agency without Files',
            'Phone__c' => '0987654321'
        };
        Test.startTest();
      //  Id result = AgencyOnboardingControllerClone.createAgencyWithFiles(fieldValues, recordTypes[0].Id, null);
        Test.stopTest(); 
    }

    @isTest
    static void testCreateAgencyWithFilesException() {
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'Agency_Onboarding__c' AND IsActive = true LIMIT 1]; 
        if (recordTypes.isEmpty()) {
            return;
        }
        Map<String, Object> fieldValues = new Map<String, Object>{
            'Invalid_Field__c' => 'Value'
        };
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            AgencyOnboardingControllerClone.createAgencyWithFiles(fieldValues, recordTypes[0].Id, new List<Map<String, Object>>());
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
    }

    @isTest
    static void testBulkCreateAgency() {
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'Agency_Onboarding__c' AND IsActive = true LIMIT 1];
        if (recordTypes.isEmpty()) {
            return;
        }
        List<Map<String, Object>> fieldValuesList = new List<Map<String, Object>>{
            new Map<String, Object>{
                'Agency_Name__c' => 'Bulk Agency 1',
                'Phone__c' => '1111111111'
            },
            new Map<String, Object>{
                'Agency_Name__c' => 'Bulk Agency 2',
                'Phone__c' => '2222222222'
            },
            new Map<String, Object>{
                'Agency_Name__c' => 'Bulk Agency 3',
                'Phone__c' => '3333333333'
            }
        };
        
        Test.startTest();
        List<Id> createdIds = new List<Id>();
        for (Map<String, Object> fieldValues : fieldValuesList) {
            Id recordId = AgencyOnboardingControllerClone.createAgency(fieldValues, recordTypes[0].Id);
            createdIds.add(recordId);
        }
        Test.stopTest();   
    }
    @isTest
static void testCheckDuplicate_Individual_EmailExists() {
    // Test setup data already inserts Email__c = test@agency.com
    Test.startTest();
    Map<String, String> result = AgencyOnboardingControllerClone.checkDuplicate(
        true,
        'test@agency.com',
        null
    );
    Test.stopTest();
    
}
@isTest
static void testCheckDuplicate_Individual_EmailNotExists() {
    Test.startTest();
    Map<String, String> result = AgencyOnboardingControllerClone.checkDuplicate(
        true,
        'notfound@agency.com',
        null
    );
    Test.stopTest();    
}

@isTest
static void testCheckDuplicate_BlankInputs() {
    Test.startTest();
    Map<String, String> result = AgencyOnboardingControllerClone.checkDuplicate(
        true,
        '',
        ''
    );
    Test.stopTest();
  
}

    
    @isTest
    static void testUploadFilesErrorScenarios() {
        List<Agency_Onboarding__c> agencies = [SELECT Id FROM Agency_Onboarding__c LIMIT 1];
        if (agencies.isEmpty()) {
            return;
        }
        List<Map<String, Object>> filesData = new List<Map<String, Object>>{
            new Map<String, Object>{
                'name' => 'largefile.pdf',
                'docType' => 'Large Document',
                'base64Data' => '', // Empty base64
                'type' => 'application/pdf'
            }
        };
        
        Test.startTest();
        try {
            AgencyOnboardingControllerClone.uploadFiles(agencies[0].Id, filesData);
        } catch (Exception e) {
        }
        Test.stopTest();
        
    }
}