({
    doInit : function(component, event, helper) {

        component.set("v.isLoading", true);

        var action = component.get("c.attachFiles");
        action.setParams({
            agencyId : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {

            component.set("v.isLoading", false);

            var state = response.getState();
            if (state === "SUCCESS") {

                $A.get("e.force:showToast").setParams({
                    title: "Success",
                    message: "File has been attached successfully.",
                    type: "success"
                }).fire();  
                $A.get("e.force:closeQuickAction").fire(); 

            } else {

                var errors = response.getError();
                var msg = (errors && errors[0] && errors[0].message) 
                            ? errors[0].message 
                            : "Unknown error";

                $A.get("e.force:showToast").setParams({
                    title: "Error",
                    message: msg,
                    type: "error"
                }).fire();
                $A.get("e.force:closeQuickAction").fire(); 
            }
        });

        $A.enqueueAction(action);
    }
})