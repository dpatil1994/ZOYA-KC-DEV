public with sharing class PropertyUnitController {

    /* ---------- PROJECT LIST ---------- */
    @AuraEnabled(cacheable=true)
    public static List<Property__c> getProjects() {
        return [
            SELECT Id, Name
            FROM Property__c
            ORDER BY Name
        ];
    }

    /* ---------- INVENTORY ---------- */
   @AuraEnabled
public static List<Property_Unit__c> getInventory(
    Id projectId,
    String floor,
    String unitType,
    String viewType
) {
    String soql =
        'SELECT Id, Name, Level__c, Unit_Type__c, View_Type__c,' +
        ' Original_Price__c,Total_Area_Sq_ft__c,  Property__c, Property__r.Name, Inventory_Status__c ' +
        'FROM Property_Unit__c ' +
        'WHERE Property__c != NULL ' +
        'AND Inventory_Status__c = \'Available\'';

    // 🔥 ONLY THIS LINE UPDATED
    if (String.isNotBlank(projectId))
        soql += ' AND Property__c = :projectId';

    if (String.isNotBlank(floor))
        soql += ' AND Level__c = :floor';

    if (String.isNotBlank(unitType))
        soql += ' AND Unit_Type__c = :unitType';

    if (String.isNotBlank(viewType))
        soql += ' AND View_Type__c = :viewType';

    soql += ' ORDER BY Name';

    return Database.query(soql);
}

    /* ---------- SALES OFFER CREATE ---------- */
   @AuraEnabled
public static Id createSalesOffer(Id unitId, String paymentPlan) {

    // Fetch Property Unit to get Project
    Property_Unit__c unit = [
        SELECT Id, Property__c 
        FROM Property_Unit__c
        WHERE Id = :unitId
        LIMIT 1
    ];

    Sales_Offer__c offer = new Sales_Offer__c();

    // REQUIRED / IMPORTANT FIELDS
    offer.Property_Unit__c = unitId;
    offer.Project__c       = unit.Property__c;
    offer.Payment_Plan__c  = paymentPlan;
    offer.Offer_Status__c  = 'Draft';

    // OPTIONAL (safe defaults)
    offer.OwnerId = UserInfo.getUserId();

    insert offer;
    return offer.Id;
}
}