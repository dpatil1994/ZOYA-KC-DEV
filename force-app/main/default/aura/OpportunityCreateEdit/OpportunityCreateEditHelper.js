({
    calculatePreview : function(component) {
        console.log(
  "UNIT CMP:",
  component.find("propertyUnit"),
  "VALUE:",
  component.find("propertyUnit") && component.find("propertyUnit").get("v.value")
);

        // 1️⃣ Get selected Property Unit Id
       var propertyUnitId = component.get("v.selectedUnitId");
        console.log("Selected Unit Id:", propertyUnitId);
    if (!propertyUnitId) {
        console.log("❌ No unit selected");
        return;
    }

        // 2️⃣ Call Apex to get Original Price
        var action = component.get("c.getUnitOriginalPrice");
        action.setParams({
            propertyUnitId : propertyUnitId
        });

        action.setCallback(this, function(res) {
            if (res.getState() === "SUCCESS") {

                var unitPrice = res.getReturnValue() || 0;

                // 3️⃣ Get Discount %
                var discountCmp = component.find("discount");
                var discount = discountCmp ? discountCmp.get("v.value") || 0 : 0;

                // 4️⃣ Calculate values
                var discountAmount = unitPrice * (discount / 100);
                var sellingPrice  = unitPrice - discountAmount;
                var adminFee      = 3500;
                var x4Dld         = sellingPrice * 0.04;
                var totalAmount   = adminFee + sellingPrice + x4Dld;

                // 5️⃣ Set values DIRECTLY on preview fields
                component.find("unitPrice1").set("v.value", unitPrice);
                component.find("discountAmount1").set("v.value", discountAmount);
                component.find("sellingPrice1").set("v.value", sellingPrice);
                component.find("adminFee1").set("v.value", adminFee);
                component.find("x4Dld1").set("v.value", x4Dld);
                component.find("totalAmount1").set("v.value", totalAmount);
            }
        });

        $A.enqueueAction(action);
    },
    
    
    
    loadRecordData: function(component) {
    var action = component.get("c.getOpportunityRecord");
    action.setParams({ recordId: component.get("v.recordId") });
    action.setCallback(this, function(response) {
        if (response.getState() === "SUCCESS") {
            var record = response.getReturnValue();
            component.set("v.opportunityRecord", record);
            console.log("✅ Record loaded:", record.Id);
        }
    });
    $A.enqueueAction(action);
},
    


    calculatePaymentPreview : function(component) {

    // 1️⃣ Get Down Payment
    var dpCmp = component.find("downPayment");
    var downPayment = dpCmp ? dpCmp.get("v.value") || 0 : 0;

    // 2️⃣ Get Realized Collection
    var rcCmp = component.find("realizedCollection");
    var realizedCollection = rcCmp ? rcCmp.get("v.value") || 0 : 0;

    // 3️⃣ Get Selling Price (already calculated earlier)
    var sellingPriceCmp = component.find("sellingPrice1");
    var sellingPrice = sellingPriceCmp ? sellingPriceCmp.get("v.value") || 0 : 0;

    // 4️⃣ Calculations
    var dpBalance = downPayment - realizedCollection;

    var paidPercentage = 0;
    if (sellingPrice > 0) {
        paidPercentage = (realizedCollection / sellingPrice) * 100;
    }

    // 5️⃣ Set preview fields
    component.find("dpBalancePreview")
        .set("v.value", dpBalance);

    component.find("paidPercentagePreview")
        .set("v.value", paidPercentage);
},
redirectToList : function(component) 
    { 
    component.find("navLink").navigate
({ 
    type : "standard__objectPage", 
                                                                     
  attributes : 
    {
        objectApiName : "Opportunity", actionName : "list" 
    } 
}); },  
    
redirectToNewRecord : function(component, recordId) {

    console.log("➡️ Helper redirectToNewRecord called");
    console.log("➡️ RecordId:", recordId);

    if (!recordId) {
        console.error("❌ redirect aborted – recordId missing");
        return;
    }

    // BEST for Action Override / Modal
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
        recordId: recordId,
        slideDevName: "detail"
    });
    navEvt.fire();
},


linkFilesToRecord: function(component, recordId, documentIds, callback) {
    var action = component.get("c.linkContentDocuments");
    action.setParams({ recordId: recordId, contentDocumentIds: documentIds });
    action.setCallback(this, function(response) {
        var result = response.getReturnValue();
        console.log("🔗 Link result:", result);  
        if (callback) callback(result);
    });
    $A.enqueueAction(action);
},
    // In HELPER.js - call this instead of direct calculatePreview
forceUnitChange: function(component) {
    var unitId = component.get("v.selectedUnitId");
    if (unitId) {
        // Simulate onchange event
        var unitEvent = $A.get("e.c:UnitChangeEvent"); // Custom event OR direct call
        if (unitEvent) {
            unitEvent.setParams({ unitId: unitId });
            unitEvent.fire();
        } else {
            this.calculatePreview(component);
        }
    }
},

        
})