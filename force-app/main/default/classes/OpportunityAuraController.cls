public with sharing class OpportunityAuraController {

    @AuraEnabled
    public static Decimal getUnitOriginalPrice(Id propertyUnitId) {
        if (propertyUnitId == null) return 0;

        Property_Unit__c unitRec = [
            SELECT Original_Price__c
            FROM Property_Unit__c
            WHERE Id = :propertyUnitId
            LIMIT 1
        ];

        return unitRec.Original_Price__c != null
            ? unitRec.Original_Price__c
            : 0;
    }
  @AuraEnabled
public static String linkContentDocuments(Id recordId, List<String> contentDocumentIds) {
    try {
        // Remove duplicates first
        Set<String> uniqueDocIds = new Set<String>();
        for (String docId : contentDocumentIds) {
            if (String.isNotBlank(docId)) {
                uniqueDocIds.add(docId);
            }
        }
        
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (String docId : uniqueDocIds) {
            // Check if link already exists
            List<ContentDocumentLink> existingLinks = [
                SELECT Id FROM ContentDocumentLink 
                WHERE ContentDocumentId = :docId 
                AND LinkedEntityId = :recordId
            ];
            
            if (existingLinks.isEmpty()) {
                links.add(new ContentDocumentLink(
                    ContentDocumentId = docId,
                    LinkedEntityId = recordId,
                    ShareType = 'V'
                ));
            }
        }
        
        if (!links.isEmpty()) {
            insert links;
        }
        
        return 'SUCCESS: ' + links.size() + ' new files linked (Total unique: ' + uniqueDocIds.size() + ')';
    } catch (Exception e) {
        return 'ERROR: ' + e.getMessage();
    }
}
@AuraEnabled(cacheable=true)
public static String getUserProfileName() {
    return [
        SELECT Profile.Name
        FROM User
        WHERE Id = :UserInfo.getUserId()
    ].Profile.Name;
}
@AuraEnabled(cacheable=true)
public static List<Property__c> getAllProperties() {
    return [
        SELECT Id, Name
        FROM Property__c
        ORDER BY Name
    ];
}

@AuraEnabled(cacheable=true)
public static List<Property_Unit__c> getUnitsByProperty(Id propertyId) {

    if (propertyId == null) return new List<Property_Unit__c>();

    return [
        SELECT Id, Name
        FROM Property_Unit__c
        WHERE Property__c = :propertyId
        AND Inventory_Status__c = 'Available'
        ORDER BY Name
    ];
}

@AuraEnabled(cacheable=true)
public static Opportunity getOpportunityRecord(Id recordId) {
    return [
        SELECT Id, Project_Name__c, Customer_Unit_Name__c, Sales_Type__c , Mode_of_Payment__c , UAE_Residence__c
        FROM Opportunity
        WHERE Id = :recordId
        LIMIT 1
    ];
}

@AuraEnabled
public static void updateFileDescription(
    List<Id> contentDocumentIds,
    String descriptionText
) {
    List<ContentVersion> versions = [
        SELECT Id, ContentDocumentId
        FROM ContentVersion
        WHERE ContentDocumentId IN :contentDocumentIds
        AND IsLatest = true
    ];

    for (ContentVersion cv : versions) {
        cv.Description = descriptionText;
    }
    update versions;
}
@AuraEnabled(cacheable=true)
public static List<ContentDocumentLink> getLinkedFiles(Id recordId) {
    return [
        SELECT ContentDocument.Title
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :recordId
    ];
}
@AuraEnabled(cacheable=true)
public static List<ContentVersion> getFilesWithDescription(Id recordId) {

    // 1️⃣ Get ContentDocumentIds first
    List<ContentDocumentLink> links = [
        SELECT ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :recordId
    ];

    if (links.isEmpty()) {
        return new List<ContentVersion>();
    }

    Set<Id> docIds = new Set<Id>();
    for (ContentDocumentLink l : links) {
        docIds.add(l.ContentDocumentId);
    }

    // 2️⃣ Now fetch latest ContentVersions
    return [
        SELECT Id, Title, Description, ContentDocumentId
        FROM ContentVersion
        WHERE ContentDocumentId IN :docIds
        AND IsLatest = true
    ];
}

    @AuraEnabled
public static String createAccountSimple(String accName) {
    try {
        Account acc = new Account(Name = accName);
        insert acc;
        return acc.Id;
    } catch (Exception e) {
        throw new AuraHandledException('Error creating account: ' + e.getMessage());
    }
}
    @AuraEnabled(cacheable=true)
public static Decimal getUnitPriceOnly(Id propertyUnitId) {
    return [
        SELECT Original_Price__c
        FROM Property_Unit__c
        WHERE Id = :propertyUnitId
        LIMIT 1
    ].Original_Price__c;
}
   @AuraEnabled
public static Id getManagerFromUser(Id userId) {
    if (userId == null) return null;

    User u = [
        SELECT ManagerId
        FROM User
        WHERE Id = :userId
        LIMIT 1
    ];

    return u.ManagerId;
}
}