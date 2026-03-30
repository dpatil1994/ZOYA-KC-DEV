({
    openPDF : function(component, event, helper) {

        var recordId = component.get("v.recordId");

        // Visualforce Page Name
        var vfPageUrl = '/apex/Sales_Offer_PaymentPlan?id=' + recordId;

        // Open PDF in new tab
        window.open(vfPageUrl, '_blank');

        // Close Quick Action popup
        $A.get("e.force:closeQuickAction").fire();
    }
})