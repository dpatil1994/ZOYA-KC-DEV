public with sharing class OpportunityBookingController {

    /* =================================================
       GET PROPERTY UNITS BASED ON PROPERTY (PARENT)
       ================================================= */
    @AuraEnabled(cacheable=true)
    public static List<Property_Unit__c> getPropertyUnits(Id propertyId) {
        if (propertyId == null) {
            return new List<Property_Unit__c>();
        }

        return [
            SELECT Id, Name
            FROM Property_Unit__c
            WHERE Property__c = :propertyId
            ORDER BY Name
        ];
    }

    /* =================================================
       SAVE OPPORTUNITY (ALL CONDITIONS)
       ================================================= */
    @AuraEnabled
    public static Id saveOpportunity(Opportunity opp, Id propertyUnitId) {

        // Reservation Date = Today (force, cannot be changed)
        opp.CloseDate = Date.today();

        // Insert / Update first (Booking_Number__c auto-generates)
        upsert opp;

        // Copy Booking Number into Developer Name
        if (opp.Booking_Number__c != null) {
            opp.Name = opp.Booking_Number__c;
        }

        // Set Property Unit lookup
        if (propertyUnitId != null) {
            opp.Customer_Unit_Name__c = propertyUnitId;
        }

        update opp;
        return opp.Id;
    }
}