@IsTest
public class ReceiptTriggerTest {

    // Utility method to create a Receipt
    private static Receipt__c createReceipt(String status) {
        Receipt__c r = new Receipt__c(
            Currency__c = 'AED',
            //Amount_in_Currency__c = 100,
            Approval_Status__c = status // 'Draft' or 'Pending'
        );
        insert r;
        return r;
    }

    @IsTest
    static void testReceiptCurrencyHandlerWithoutApproval() {

        // Use status that does NOT trigger approval validation
        Receipt__c rec = createReceipt('Draft');

        // Update amount and currency to test handler
        //rec.Amount_in_Currency__c = 200;
        rec.Currency__c = 'USD';

        Test.startTest();
        update rec;
        Test.stopTest();

        // Verify updates
        Receipt__c updatedRec = [
            SELECT Id, Currency__c
            FROM Receipt__c
            WHERE Id = :rec.Id
        ];

        System.assertEquals('USD', updatedRec.Currency__c);
        //System.assertEquals(200, updatedRec.Amount_in_Currency__c);
    }

    @IsTest
    static void testRejectWithComment() {

        // Create Receipt with Pending status
        Receipt__c rec = createReceipt('Pending');

        // Submit for approval
        Approval.ProcessSubmitRequest submitReq = new Approval.ProcessSubmitRequest();
        submitReq.setObjectId(rec.Id);
        submitReq.setComments('Submitting for approval');
        Approval.process(submitReq);

        // Fetch the work item
        ProcessInstanceWorkitem workItem = [
            SELECT Id
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId = :rec.Id
            LIMIT 1
        ];

        // Reject WITH comment (should pass)
        Approval.ProcessWorkitemRequest rejectReq = new Approval.ProcessWorkitemRequest();
        rejectReq.setWorkitemId(workItem.Id);
        rejectReq.setAction('Reject');
        rejectReq.setComments('Rejected due to validation');

        Test.startTest();
        Approval.process(rejectReq);
        Test.stopTest();

        // Verify record still exists
        Receipt__c updatedRec = [SELECT Id, Approval_Status__c FROM Receipt__c WHERE Id = :rec.Id];
        System.assertNotEquals(null, updatedRec.Id);
    }

    @IsTest
    static void testRejectWithoutCommentFails() {

        // Create Receipt with Pending status
        Receipt__c rec = createReceipt('Pending');

        // Submit for approval
        Approval.ProcessSubmitRequest submitReq = new Approval.ProcessSubmitRequest();
        submitReq.setObjectId(rec.Id);
        submitReq.setComments('Submitting');
        Approval.process(submitReq);

        // Fetch the work item
        ProcessInstanceWorkitem workItem = [
            SELECT Id
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId = :rec.Id
            LIMIT 1
        ];

        // Reject WITHOUT comment (should fail)
        Approval.ProcessWorkitemRequest rejectReq = new Approval.ProcessWorkitemRequest();
        rejectReq.setWorkitemId(workItem.Id);
        rejectReq.setAction('Reject');
        // ❌ No comments

        Test.startTest();
        try {
            Approval.process(rejectReq);
            System.assert(false, 'Exception should have been thrown because comment is missing');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('Comment is mandatory while Rejecting the receipt'),
                'Expected comment validation error not thrown'
            );
        }
        Test.stopTest();
    }
}