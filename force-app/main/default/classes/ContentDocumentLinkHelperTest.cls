@IsTest
public class ContentDocumentLinkHelperTest {

    @IsTest
    static void testNormalScenario() {

        // 🔹 Create Agency__c record
        Agency__c testAgency = new Agency__c(Name = 'Test Agency');
        insert testAgency;

        // 🔹 Create ContentVersion records
        List<ContentVersion> versions = new List<ContentVersion>{
            new ContentVersion(
                Title = 'TestFile1',
                PathOnClient = 'TestFile1.txt',
                VersionData = Blob.valueOf('Test Data 1')
            ),
            new ContentVersion(
                Title = 'TestFile2',
                PathOnClient = 'TestFile2.txt',
                VersionData = Blob.valueOf('Test Data 2')
            )
        };
        insert versions;

        // 🔹 Get ContentDocumentIds
        versions = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN :versions
        ];

        List<Id> contentDocumentIds = new List<Id>();
        for(ContentVersion cv : versions) {
            System.assertNotEquals(null, cv.ContentDocumentId);
            contentDocumentIds.add(cv.ContentDocumentId);
        }


        ContentDocumentLinkHelper.LinkInput input = new ContentDocumentLinkHelper.LinkInput();
        input.agencyId = testAgency.Id;  
        input.contentDocumentIds = contentDocumentIds;

        List<ContentDocumentLinkHelper.LinkInput> inputs =
            new List<ContentDocumentLinkHelper.LinkInput>{ input };

        // 🔹 Execute Method
        Test.startTest();
        ContentDocumentLinkHelper.linkFilesToAgency(inputs); 
        Test.stopTest();

        // 🔹 Verify Links
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId, LinkedEntityId, ShareType, Visibility
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :testAgency.Id
        ];

        System.assertEquals(2, links.size(), 'Two links should be created');

        for(ContentDocumentLink link : links) {
            System.assertEquals('V', link.ShareType);
            System.assertEquals('AllUsers', link.Visibility);
            System.assert(contentDocumentIds.contains(link.ContentDocumentId));
        }
    }
}