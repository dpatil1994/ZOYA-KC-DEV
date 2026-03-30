({
    doInit : function(component, event, helper) {

        var recordId = component.get("v.recordId");

        // Visualforce PDF URL
        var url = '/apex/SalesOfferProjectBasedPDF?id=' + recordId;

        // Open PDF in new tab
        window.open(url, '_blank');

        // Close quick action automatically
        $A.get("e.force:closeQuickAction").fire();
    }
})