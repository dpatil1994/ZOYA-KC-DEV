public class ReceiptApprovalHandler {

    public static void makeCommentMandatory(List<Receipt__c> newList,Map<Id, Receipt__c> oldMap) {
        Set<Id> receiptIds = new Set<Id>();

        for (Receipt__c r : newList) {
            receiptIds.add(r.Id); }

        if (receiptIds.isEmpty()) return;

        List<ProcessInstance> piList = [
            SELECT Id,   TargetObjectId, (SELECT Id, StepStatus, Comments FROM Steps)
            FROM ProcessInstance WHERE TargetObjectId IN :receiptIds];

        Map<Id, Boolean> hasCommentMap = new Map<Id, Boolean>();

        for (ProcessInstance pi : piList) {
            for (ProcessInstanceStep step : pi.Steps) {
                if (
                    (step.StepStatus == 'Rejected') && String.isNotBlank(step.Comments)
                ) {
                    hasCommentMap.put(pi.TargetObjectId, true);
                    break;
                }
            }
        }

        for (Receipt__c r : newList) {
            if (!hasCommentMap.containsKey(r.Id)) {
                r.addError('Comment is mandatory while Rejecting the receipt.');
            }
        }
    }
}