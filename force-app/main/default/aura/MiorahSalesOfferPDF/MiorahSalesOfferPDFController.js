({
    openPDF : function(component, event, helper) {

        var recordId = component.get("v.recordId");

        var vfUrl = '/apex/miorahSalesOffer?id=' + recordId;

        window.open(vfUrl, '_blank');
    }
})