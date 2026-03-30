({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");

        // ALWAYS USE URLENCODE — VERY IMPORTANT
        var vfPageUrl = '/apex/EOIGenerationForm?id=' + encodeURIComponent(recordId);

        // Set attribute instead of iframe element access
        component.set("v.vfUrl", vfPageUrl);
    }
})