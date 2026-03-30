({
doInit : function(component) {
     console.log("doInit fired once");
component.set("v.selectedPropertyId", null);
    component.set("v.selectedUnitId", null);
    component.set("v.unitOptions", []);
     
    var pageRef = component.get("v.pageReference");
if (pageRef && pageRef.state) {
    component.set("v.returnTo", pageRef.state.c__returnTo);
}
    var pageRef = component.get("v.pageReference");

    if (pageRef && pageRef.state) {
        var propertyId = pageRef.state.c__projectId;
        var unitId = pageRef.state.c__propertyUnitId;

        component.set("v.selectedPropertyId", propertyId);
        component.set(
    "v.selectedUnitId",
    component.get("v.selectedUnitId")
);
    }
    // 🔥🔥🔥 DIRECT UNIT PRICE SET (NO CALCULATION)
// 🔥🔥🔥 FIRST LOAD – DIRECT PRICE PREVIEW (NO CALCULATION DEPENDENCY)
if (!component.get("v.recordId")) {

var priceAction = component.get("c.getUnitOriginalPrice");
priceAction.setParams({
    propertyUnitId: unitId
});

priceAction.setCallback(this, function(resp) {
    if (resp.getState() === "SUCCESS") {

        var unitPrice = resp.getReturnValue() || 0;

        // Fixed values
        var adminFee = 3500;
        var sellingPrice = unitPrice;
        var x4Dld = sellingPrice * 0.04;
        var totalAmount = sellingPrice + adminFee + x4Dld;

        // ⚠️ Wait until lightning:inputField renders
        window.setTimeout(
            $A.getCallback(function () {

                var unitPriceCmp   = component.find("unitPrice1");
                var adminFeeCmp    = component.find("adminFee1");
                var dldCmp         = component.find("x4Dld1");
                var totalCmp       = component.find("totalAmount1");
                var sellingCmp     = component.find("sellingPrice1");

                if (unitPriceCmp) {
                    unitPriceCmp.set("v.value", unitPrice);
                }
                if (adminFeeCmp) {
                    adminFeeCmp.set("v.value", adminFee);
                }
                if (dldCmp) {
                    dldCmp.set("v.value", x4Dld);
                }
                if (totalCmp) {
                    totalCmp.set("v.value", totalAmount);
                }
                if (sellingCmp) {
                    sellingCmp.set("v.value", sellingPrice);
                }

            }),
            300
        );
    }
});
$A.enqueueAction(priceAction);
}
    // ✅ EXISTING LOGIC (unchanged)
    const today = new Date().toISOString().split('T')[0];
    component.set("v.todayDate", today);

    // 🔥 Profile logic
    var action = component.get("c.getUserProfileName");
    action.setCallback(this, function(response) {
        if (response.getState() === "SUCCESS") {
            var profileName = response.getReturnValue();
            component.set("v.userProfileName", profileName);

            var normalizedProfile = profileName.replace(/\s+/g, ' ').trim();

            if (normalizedProfile === "Sales Admin Manager Profile") {
                component.set("v.hidePaymentAndLegal", true);
            }
            if (normalizedProfile === "Sales Admin Manager Profile") {
    component.set("v.isSalesAdminManager", true);
}

           if (
                    normalizedProfile === "Finance Profile" ||
                    normalizedProfile === "System Administrator"
                ) {
                    component.set("v.showCloseDate", true);
                }
            
          if (!component.get("v.recordId")) {
                window.setTimeout(
                    $A.getCallback(function () {
                        var stageCmp = component.find("stageField");
                        if (stageCmp) {
                            stageCmp.set("v.value", "EOI Linking");
                        }
                    }),
                    300
                );
            }


        }
    });
    $A.enqueueAction(action);

    /* ============================================================
       🔥 PROPERTY DROPDOWN LOAD (UNCHANGED)
       ============================================================ */
    var actionProperty = component.get("c.getAllProperties");
    actionProperty.setCallback(this, function(response) {
        if (response.getState() === "SUCCESS") {
            var options = [];
            response.getReturnValue().forEach(p => {
                options.push({ label: p.Name, value: p.Id });
            });
            component.set("v.propertyOptions", options);
        }
    });
    $A.enqueueAction(actionProperty);
    
    
   // 🔥 If coming from Book Unit, auto-load units
var pageRef = component.get("v.pageReference");
var unitId = pageRef && pageRef.state
    ? pageRef.state.c__propertyUnitId
    : null;

if (component.get("v.selectedPropertyId") && unitId) {

    var actionUnits = component.get("c.getUnitsByProperty");
    actionUnits.setParams({
        propertyId: component.get("v.selectedPropertyId")
    });

    actionUnits.setCallback(this, function(res) {
        if (res.getState() === "SUCCESS") {

            var options = [];
            res.getReturnValue().forEach(u => {
                options.push({
                    label: u.Name,
                    value: u.Id
                });
            });

            // ✅ 1. Units dropdown set
            component.set("v.unitOptions", options);

            // ✅ 2. Selected unit set (IMPORTANT)
            component.set("v.selectedUnitId", unitId);

            // ✅ 3. Unit price auto-populate (SAME as onchange)
            window.setTimeout(
                $A.getCallback(function () {
                    helper.calculatePreview(component);
                }),
                0
            );
        }
    });

    $A.enqueueAction(actionUnits);
}

    /* ============================================================
       🔥 EDIT MODE SUPPORT (PROPERTY + UNIT) (UNCHANGED)
       ============================================================ */
    var recordId = component.get("v.recordId");

    if (recordId) 
    {

        // 🔹 Load Opportunity record
        var actionRec = component.get("c.getOpportunityRecord");
        actionRec.setParams({ recordId: recordId });

        actionRec.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var rec = response.getReturnValue();

                // 🔥 UAE Residence - Edit mode support
if (rec.UAE_Residence__c === true) {
    component.set("v.showEmiratesUploader", true);
} else {
    component.set("v.showEmiratesUploader", false);
}
                 if (rec.Mode_of_Payment__c) {
                        component.set("v.showMOPReference", true);
                    } else {
                        component.set("v.showMOPReference", false);
                    }

                if (rec.Project_Name__c) {
                    component.set("v.selectedPropertyId", rec.Project_Name__c);

                    var actionUnits = component.get("c.getUnitsByProperty");
                    actionUnits.setParams({ propertyId: rec.Project_Name__c });

                    actionUnits.setCallback(this, function(res2) {
                        if (res2.getState() === "SUCCESS") {
                            var options = [];
                            res2.getReturnValue().forEach(u => {
                                options.push({ label: u.Name, value: u.Id });
                            });
                            component.set("v.unitOptions", options);
                            component.set("v.selectedUnitId", rec.Customer_Unit_Name__c);
                        // 🔥 ADD THIS FOR EDIT MODE PRICE CALCULATION
                            window.setTimeout(
                                $A.getCallback(function () {
                                    helper.calculatePreview(component);
                                }),
                                0
                            );
                        }
                    });
                    $A.enqueueAction(actionUnits);
                }
        
                         if (rec.Sales_Type__c === "Indirect") {
                    component.set("v.showAgencyFields", true);
                }
                else {
                    component.set("v.showAgencyFields", false);
                }
                    }
                });
                $A.enqueueAction(actionRec);

        /* ============================================================
           🔥 EXISTING FILE LOAD (UNCHANGED)
           ============================================================ */
        var fileAction = component.get("c.getLinkedFiles");
        fileAction.setParams({ recordId: recordId });

        fileAction.setCallback(this, function(res) {
            if (res.getState() === "SUCCESS") {
                var files = res.getReturnValue();

                files.forEach(f => {
                    var title = f.ContentDocument.Title;

                    if (title.includes("Passport")) {
                        component.set("v.passportFileName", title);
                    }
                    if (title.includes("Sales Offer")) {
                        component.set("v.salesOfferFileName", title);
                    }
                    if (title.includes("POP")) {
                        component.set("v.popFileName", title);
                    }
                });
            }
        });
        $A.enqueueAction(fileAction);

        /* ============================================================
           🔥🔥🔥 NEW ADDITION (DO NOT REMOVE ABOVE CODE)
           🔥 LOAD FILE NAME + DOC ID USING DESCRIPTION
           ============================================================ */
        var fileAction2 = component.get("c.getFilesWithDescription");
        fileAction2.setParams({ recordId: recordId });

        fileAction2.setCallback(this, function(res) {
            if (res.getState() === "SUCCESS") {
                var files = res.getReturnValue();

                files.forEach(function(f) {
                    if (f.Description === "Salesbooking - Passport") {
                        component.set("v.passportFileName", f.Title);
                        component.set("v.passportDocId", f.ContentDocumentId);
                    }
                    if (f.Description === "Salesbooking - Approved Sales Offer") {
                        component.set("v.salesOfferFileName", f.Title);
                        component.set("v.salesOfferDocId", f.ContentDocumentId);
                    }
                    if (f.Description === "Salesbooking - POP") {
                        component.set("v.popFileName", f.Title);
                        component.set("v.popDocId", f.ContentDocumentId);
                    }
                });
            }
        });
        $A.enqueueAction(fileAction2);
        /* ================= END NEW ADDITION ================= */
        
    }
    
       window.addEventListener("message", $A.getCallback(function(event) {
        if (event.data && event.data.type === "UIAPI" && event.data.payload) {
            var response = event.data.payload;
            
            // Check agar create action hai aur Account object hai
            if (response.entityApiName === "Account" && response.id) {
                var newAccountId = response.id;
                
                // Form mein auto-select karne ke liye
                var accField = component.find("accountField");
                if (accField) {
                    accField.set("v.value", newAccountId);
                }
            }
        }
    }), false);
    
    window.addEventListener(
    "message",
    $A.getCallback(function (event) {

        if (!event.data || !event.data.payload) {
            return;
        }

        var payload = event.data.payload;

        // 🔥 Only Account CREATE
        if (
            payload.entityApiName === "Account" &&
            payload.id
        ) {
            var newAccountId = payload.id;

            console.log("✅ New Account Created:", newAccountId);

            // store in variable
            component.set("v.newAccountId", newAccountId);

            // auto select in lookup
            var accField = component.find("accountField");
            if (accField) {
                accField.set("v.value", newAccountId);
            }
        }
    }),
    false
);

},

onPageRefChange : function(component, event, helper) {

    component.set("v.selectedPropertyId", null);
    component.set("v.selectedUnitId", null);
    component.set("v.unitOptions", []);

    var pageRef = component.get("v.pageReference");

    if (pageRef && pageRef.state) {

        var propertyId = pageRef.state.c__projectId;
        var unitId = pageRef.state.c__propertyUnitId;

        if (propertyId) {
            component.set("v.selectedPropertyId", propertyId);

            var actionUnits = component.get("c.getUnitsByProperty");
            actionUnits.setParams({ propertyId });

            actionUnits.setCallback(this, function(res) {
                if (res.getState() === "SUCCESS") {

                    var options = res.getReturnValue().map(u => ({
                        label: u.Name,
                        value: u.Id
                    }));

                    component.set("v.unitOptions", options);
                    component.set("v.selectedUnitId", unitId);

                    // 🔥🔥🔥 WAIT FOR COMBOBOX TO RENDER
                    window.setTimeout(
                        $A.getCallback(function () {
                            helper.calculatePreview(component);
                        }),
                        0
                    );
                }
            });

            $A.enqueueAction(actionUnits);
        }
    }

},
    // 🔁 EXISTING FUNCTIONS (unchanged)
    recalculatePreview : function(component, event, helper) {
        helper.calculatePreview(component);
    },

    recalculatePaymentPreview : function(component, event, helper) {
        helper.calculatePaymentPreview(component);
    },

    // 🔥 MOST IMPORTANT
   handleSubmit : function(component, event, helper) {
    event.preventDefault(); // stop default submit
    console.log("🔥 handleSubmit fired");

    // 🔁 Reset ALL errors
    component.set("v.passportError", "");
    component.set("v.salesOfferError", "");
    component.set("v.popError", "");
    component.set("v.hasFormErrors", false);
    component.set("v.formErrorMessage", "");

    var hasError = false;

    /* ============================
       🔴 FILE VALIDATION (EXISTING)
       ============================ */
    var passport = component.get("v.passportFileName");
    var salesOffer = component.get("v.salesOfferFileName");
    var pop = component.get("v.popFileName");

    if (!passport) {
        component.set("v.passportError", "Passport is required to upload.");
        hasError = true;
    }
    if (!salesOffer) {
        component.set("v.salesOfferError", "Approved Sales Offer is required to upload.");
        hasError = true;
    }
    if (!pop) {
        component.set("v.popError", "POP is required to upload.");
        hasError = true;
    }

    
    /* ============================
       🔴 PROPERTY & UNIT VALIDATION
       ============================ */
    if (!component.get("v.selectedPropertyId")) {
        component.set("v.propertyError", "Please select a Property.");
        hasError = true;
    }

    if (!component.get("v.selectedUnitId")) {
        component.set("v.unitError", "Please select a Property Unit.");
        hasError = true;
    }


    /* ============================
       🔴 POP AMOUNT VALIDATION
       ============================ */
   var fields = event.getParam("fields");
    var popAmount = fields.POP_Amount__c;

    if (!popAmount || popAmount < 20000) {
        component.set(
            "v.popAmountError",
            "POP Amount must be at least 20,000."
        );
        hasError = true;
    }

   
    /* ============================
       🚫 STOP SUBMIT IF ANY ERROR
       ============================ */
    if (hasError) {
        component.set("v.hasFormErrors", true);
        component.set(
            "v.formErrorMessage",
            "Please fill out the required fields before saving."
        );

        // Scroll to top so error is visible
        window.scrollTo({ top: 0, behavior: "smooth" });
        return;
    }

    /* ============================
       ✅ EXISTING SUBMIT LOGIC
       ============================ */

    // Default Stage ONLY for CREATE
    if (!component.get("v.recordId") && !fields.StageName) {
        fields.StageName = "EOI Linking";
    }

    // Required Name (temporary)
    fields.Name = "Zoya Developments";

    // Close Date = Today
    const today = new Date();
    fields.CloseDate = today.toISOString().split('T')[0];

    // Property & Unit mapping
    fields.Project_Name__c = component.get("v.selectedPropertyId");
    fields.Customer_Unit_Name__c = component.get("v.selectedUnitId");

    console.log("🔥 Submitting record...");
    component.find("recordForm").submit(fields);
},

    handleModeOfPaymentChange: function(component, event, helper) {
    var mopValue = event.getSource().get("v.value");
    var showRef = (mopValue && mopValue !== '');  // Koi bhi value select ho
    component.set("v.showMOPReference", showRef);
    console.log("MOP changed:", mopValue, "Show ref:", showRef);
},
addJointBuyer: function(component, event, helper) {
    var currentCount = component.get("v.jointBuyerCount");
    var newCount = currentCount + 1;
    
    component.set("v.jointBuyerCount", newCount);
    component.set("v.showJointBuyers", true);
    
    console.log("➕ Added Joint Buyer #", newCount);
},
    
/* Checkbox logic
    handleMoreThan2Buyers : function(component, event, helper) {
        var isChecked = event.getSource().get("v.value");
        component.set("v.showSecondaryBuyer", isChecked);
    },*/

    // Picklist logic
    handleSalesTypeChange : function(component, event, helper) {
        var salesType = event.getSource().get("v.value");
        component.set(
            "v.showAgencyFields",
            salesType === "Indirect"
        );
    },
    
   handleFileUpload: function(component, event, helper) {
    var uploadedFiles = event.getParam("files");
    var fileName = event.getParam("name"); // "passport", "salesOffer", "pop"
    
    for(var i = 0; i < uploadedFiles.length; i++) {
        var docId = uploadedFiles[i].documentId;
        var docName = uploadedFiles[i].name;
        
        // Store file name by upload type
        if (fileName === "passport") {
            component.set("v.passportFileName", docName);
        } else if (fileName === "salesOffer") {
            component.set("v.salesOfferFileName", docName);
        } else if (fileName === "pop") {
            component.set("v.popFileName", docName);
        }
        
        // Add to main document list
        var documentIds = component.get("v.uploadedDocumentIds");
        documentIds.push(docId);
        component.set("v.uploadedDocumentIds", documentIds);
    }
    
    console.log("📁 " + fileName + " uploaded: " + uploadedFiles[0].name);
},
// File upload handlers - PASTE in controller
handlePassportUpload: function(component, event) {
    var file = event.getParam("files")[0];

    if (!file) return;

    // ✅ File name set
    component.set("v.passportFileName", file.name);
    component.set("v.passportError", "");

    // ✅ Store documentId (EXISTING FLOW SUPPORT)
    var documentIds = component.get("v.uploadedDocumentIds") || [];
    documentIds.push(file.documentId);
    component.set("v.uploadedDocumentIds", documentIds);

    // 🔥 DESCRIPTION SAVE (WORKING LOGIC – SAME AS YOUR CODE)
    var action = component.get("c.updateFileDescription");
    action.setParams({
        contentDocumentIds: [file.documentId],
        descriptionText: "Salesbooking - Passport"
    });
    $A.enqueueAction(action);
},


handleSalesOfferUpload: function(component, event) {
    var file = event.getParam("files")[0];

    if (!file) return;

    component.set("v.salesOfferFileName", file.name);
    component.set("v.salesOfferError", "");

    var documentIds = component.get("v.uploadedDocumentIds") || [];
    documentIds.push(file.documentId);
    component.set("v.uploadedDocumentIds", documentIds);

    var action = component.get("c.updateFileDescription");
    action.setParams({
        contentDocumentIds: [file.documentId],
        descriptionText: "Salesbooking - Approved Sales Offer"
    });
    $A.enqueueAction(action);
},

handlePopUpload: function(component, event) {
    var file = event.getParam("files")[0];

    if (!file) return;

    component.set("v.popFileName", file.name);
    component.set("v.popError", "");

    var documentIds = component.get("v.uploadedDocumentIds") || [];
    documentIds.push(file.documentId);
    component.set("v.uploadedDocumentIds", documentIds);

    var action = component.get("c.updateFileDescription");
    action.setParams({
        contentDocumentIds: [file.documentId],
        descriptionText: "Salesbooking - POP"
    });
    $A.enqueueAction(action);
},



  handleSuccess : function(component, event, helper) {
    console.log("✅ handleSuccess fired");
    var response = event.getParam("response");
    var recordId = response.id;
    console.log("🆔 RecordId:", recordId);

    var documentIds = component.get("v.uploadedDocumentIds");
    if (documentIds && documentIds.length > 0) {
        helper.linkFilesToRecord(component, recordId, documentIds, function() {
            console.log("✅ Files linked, now closing");
            
            $A.get("e.force:closeQuickAction").fire();
            window.location.href = '/' + recordId;
             window.location.href = '/' + recordId;
            helper.redirectToNewRecord(component, recordId);
        });
    } else {
        // No files, direct close
        $A.get("e.force:closeQuickAction").fire();
        helper.redirectToNewRecord(component, recordId);
    }
},
handlePropertyChange : function(component, event, helper) {

    var propertyId = component.get("v.selectedPropertyId");

    if (!propertyId) {
        component.set("v.unitOptions", []);
        component.set("v.selectedUnitId", null);
        return;
    }

    var action = component.get("c.getUnitsByProperty");
    action.setParams({
        propertyId : propertyId
    });

    action.setCallback(this, function(response) {
        if (response.getState() === "SUCCESS") {

            var units = response.getReturnValue();
            var options = [];

            for (var i = 0; i < units.length; i++) {
                options.push({
                    label: units[i].Name,
                    value: units[i].Id
                });
            }

            component.set("v.unitOptions", options);
            console.log("🏠 Units Loaded:", options.length);
        }
    });

    $A.enqueueAction(action);
},


handleUnitChange : function(component, event, helper) {

    var unitId = component.get("v.selectedUnitId");

    if (unitId) {
        helper.calculatePreview(component);
    }
},


handleError : function(component, event, helper) {
    console.error("❌ Salesforce validation error", event.getParams());

    component.set("v.hasFormErrors", true);
    component.set(
        "v.formErrorMessage",
        "Please fill out the required fields before saving."
    );

    // 🔝 Optional: scroll to top so user sees error
    window.scrollTo({ top: 0, behavior: "smooth" });
},

handleCreateNewAccount : function(component) {
    component.set("v.showAccountTypeModal", true);
},
    createCompanyBuyer : function(component) {
    component.set("v.showAccountTypeModal", false);

    $A.get("e.force:createRecord").setParams({
        entityApiName: "Account",
        recordTypeId: "012WE00000KzucrYAB",
        navigationLocation: "LOOKUP"
    }).fire();
},
    createIndividualBuyer : function(component) {
    component.set("v.showAccountTypeModal", false);

    $A.get("e.force:createRecord").setParams({
        entityApiName: "Account",
        recordTypeId: "012WE00000L0Hw1YAF",
        navigationLocation: "LOOKUP"
    }).fire();
},


handleUaeResidenceChange : function(component, event) {
    var isChecked = event.getSource().get("v.value");
    component.set("v.showEmiratesUploader", isChecked);
},
    handleEmiratesIdUpload : function(component, event) {
    var file = event.getParam("files")[0];
    if (!file) return;

    component.set("v.emiratesIdFileName", file.name);

    // Save document id
    component.set("v.emiratesIdDocId", file.documentId);

    // Optional: set description
    var action = component.get("c.updateFileDescription");
    action.setParams({
        contentDocumentIds: [file.documentId],
        descriptionText: "Salesbooking - Emirates ID"
    });
    $A.enqueueAction(action);
},

    closeAccountTypeModal : function(component) {
    component.set("v.showAccountTypeModal", false);
},


handleClose : function(component, event, helper) {

    var pageRef = component.get("v.pageReference");
    var returnTo =
        pageRef && pageRef.state ? pageRef.state.c__returnTo : null;

    // 🔥 Inventory se aaya hai
    if (returnTo === 'inventory') {
        // SAME TAB me inventory wapas (safe back)
        window.history.back();
        return;
    }

    // 🔥 List view / normal open
    helper.redirectToList(component);
},

handleSalesExecutiveChange : function(component, event, helper) {

    var execId = event.getSource().get("v.value");
    if (!execId) {
        component.find("salesDirector").set("v.value", null);
        return;
    }

    var action = component.get("c.getManagerFromUser");
    action.setParams({
        userId: execId
    });

    action.setCallback(this, function(response) {
        if (response.getState() === "SUCCESS") {

            var managerId = response.getReturnValue();

            if (managerId) {
                component.find("salesDirector")
                         .set("v.value", managerId);
            }
        }
    });

    $A.enqueueAction(action);
}
})