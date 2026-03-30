/**
* @File Name  :  AgencyOnboardingControllerClone .cls
*@Description : Controller for Agency Onboarding LWC - Gets ALL picklist values
*
* @Author            : KC0126
* @Last Modified By  : Harshita Singh
* @Last Modified On  : December 23, 2025
* @Modification Log  :
*==============================================================================
* Ver | Date         | Author              | Modification
*==============================================================================
*  1.0 | December 8, 2025 |   | Initial Version
*  1.1 | December 9, 2025 |   | Gets ALL picklist values dynamically'

**/
public without sharing class AgencyOnboardingControllerClone {

    // 1. Get Record Types for Agency_Onboarding__c
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getRecordTypes() {
        List<Map<String, String>> recordTypes = new List<Map<String, String>>();
        try {
            for(RecordType rt : [SELECT Id, Name 
                                 FROM RecordType 
                                 WHERE SObjectType='Agency_Onboarding__c' 
                                 AND IsActive=true
                                 ORDER BY Name]) {
                Map<String, String> mapRt = new Map<String, String>();
                mapRt.put('label', rt.Name);
                mapRt.put('value', rt.Id);
                recordTypes.add(mapRt);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching record types: ' + e.getMessage());
        }
        return recordTypes;
    }

    // 2. Get ALL Picklist values for the object (all picklist fields)
@AuraEnabled(cacheable=true)
public static Map<String, List<Map<String, String>>> getAllPicklistValues() {
    Map<String, List<Map<String, String>>> picklistMap = new Map<String, List<Map<String, String>>>();
    try {
        Schema.DescribeSObjectResult objDescribe = Agency_Onboarding__c.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        // Loop through ALL fields and find picklist fields
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            
            // Check if field is a picklist
            if(fieldDescribe.isAccessible() && 
               fieldDescribe.getType() == Schema.DisplayType.Picklist) {
                
                List<Map<String, String>> valuesList = new List<Map<String, String>>();
                List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
                
                // Add all active picklist values
                for(Schema.PicklistEntry entry : picklistEntries) {
                    if(entry.isActive()) {
                        valuesList.add(new Map<String, String>{
                            'label' => entry.getLabel(),
                            'value' => entry.getValue()
                        });
                    }
                }
                
                picklistMap.put(fieldName, valuesList);
            }
        }
        
        // Add custom options
        picklistMap.put('YesNoOptions', new List<Map<String, String>>{
            new Map<String, String>{'label' => 'Yes', 'value' => 'Yes'},
            new Map<String, String>{'label' => 'No', 'value' => 'No'}
        });
        
        // Bank-related custom options
        picklistMap.put('AccountTypeOptions', getAccountTypeOptions());
        picklistMap.put('CurrencyOptions', getCurrencyOptions());
        picklistMap.put('BankBranchOptions', getBankBranchOptions());
        picklistMap.put('CountryOptions', getCountryOptions());
        picklistMap.put('BankNameOptions', getBankNameOptions());
        
    } catch (Exception e) {
        //throw new System.AuraHandledException('Error fetching picklist values: ' + e.getMessage());
    }
    return picklistMap;
}

    // 3. Get Picklist values for specific record type (if needed)
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Map<String, String>>> getPicklistValues(Id recordTypeId) {
        // For now, return all picklists (record type specific picklists are rare)
        return getAllPicklistValues();
    }

    // 4. Create Agency_Onboarding__c record

// 4. Create Agency_Onboarding__c record - FIXED VERSION with type conversion
// 4. Create Agency_Onboarding__c record - COMPLETELY FIXED VERSION
@AuraEnabled
public static Id createAgency(Map<String, Object> fieldValues, Id recordTypeId) {
    try {
        Agency_Onboarding__c agency = new Agency_Onboarding__c();
        
        // Set Record Type
        agency.RecordTypeId = recordTypeId;
        
        // Get ALL field map for validation
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Agency_Onboarding__c.fields.getMap();
        
        // Debug: Log all fields being received
        System.debug('Received fieldValues: ' + JSON.serializePretty(fieldValues));
        System.debug('Total fields in object schema: ' + fieldMap.size());
        
        // Store Agency_Name__c value for Name field
        String agencyNameValue = null;
        
        // FIRST: Set the basic field values with proper type conversion
        for(String key : fieldValues.keySet()) {
            String fieldApiName = key;
            
            // Skip invalid fields - check case-insensitively
            Boolean fieldExists = false;
            String actualFieldName = null;
            
            // Check if field exists (case-insensitive)
            for(String fieldName : fieldMap.keySet()) {
                if(fieldName.equalsIgnoreCase(fieldApiName)) {
                    fieldExists = true;
                    actualFieldName = fieldName; // Use the actual API name from schema
                    break;
                }
            }
            
            if(!fieldExists) {
                System.debug('Skipping invalid field: ' + fieldApiName + ' (not found in schema)');
                continue; // Skip this field
            }
            
            Object value = fieldValues.get(key);
            
            // Handle empty strings
            if(value == null || (value instanceof String && String.isBlank((String)value))) {
                System.debug('Skipping empty value for field: ' + actualFieldName);
                continue;
            }
            
            // Get field type
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(actualFieldName).getDescribe();
            Schema.DisplayType fieldType = fieldDescribe.getType();
            
            System.debug('Processing field: ' + actualFieldName + ', Type: ' + fieldType + ', Value: ' + value);
            
            // Store Agency_Name__c value for Name field - CASE INSENSITIVE CHECK
            if('Agency_Name__c'.equalsIgnoreCase(actualFieldName)) {
                agencyNameValue = (String)value;
                System.debug('Found Agency_Name__c field. Value: ' + agencyNameValue);
            }
            
            // Type conversion based on field type
            if(fieldType == Schema.DisplayType.DATE && value instanceof String) {
                try {
                    String dateString = (String)value;
                    // Remove time part if present (from datetime-local input)
                    if(dateString.contains('T')) {
                        dateString = dateString.split('T')[0];
                    }
                    agency.put(actualFieldName, Date.valueOf(dateString));
                    System.debug('Converted string to date: ' + dateString + ' -> ' + Date.valueOf(dateString));
                } catch (Exception e) {
                    System.debug('Error converting date for field ' + actualFieldName + ': ' + e.getMessage());
                    // Don't set if conversion fails
                }
            }
            else if(fieldType == Schema.DisplayType.DATETIME && value instanceof String) {
                try {
                    String dateTimeString = (String)value;
                    // Ensure proper format
                    dateTimeString = dateTimeString.replace('T', ' ');
                    if(dateTimeString.endsWith('Z')) {
                        dateTimeString = dateTimeString.substring(0, dateTimeString.length() - 1);
                    }
                    agency.put(actualFieldName, DateTime.valueOf(dateTimeString));
                } catch (Exception e) {
                    System.debug('Error converting datetime for field ' + actualFieldName + ': ' + e.getMessage());
                }
            }
            else if(fieldType == Schema.DisplayType.BOOLEAN) {
                if(value instanceof String) {
                    String strVal = (String)value;
                    agency.put(actualFieldName, strVal.equalsIgnoreCase('true') || strVal.equals('1') || strVal.equalsIgnoreCase('yes'));
                } else if(value instanceof Boolean) {
                    agency.put(actualFieldName, value);
                }
            }
            else if((fieldType == Schema.DisplayType.DOUBLE || 
                     fieldType == Schema.DisplayType.INTEGER ||
                     fieldType == Schema.DisplayType.CURRENCY ||
                     fieldType == Schema.DisplayType.PERCENT) && 
                    value instanceof String) {
                try {
                    String numStr = (String)value;
                    // Remove any commas for thousands
                    numStr = numStr.replace(',', '');
                    agency.put(actualFieldName, Decimal.valueOf(numStr));
                } catch (Exception e) {
                    System.debug('Error converting number for field ' + actualFieldName + ': ' + e.getMessage());
                }
            }
            else if(fieldType == Schema.DisplayType.PICKLIST) {
                // For picklist, just set the string value
                agency.put(actualFieldName, value);
            }
            else {
                // For text, email, phone, URL, etc.
                agency.put(actualFieldName, value);
            }
        }
        
        // Check if we found Agency_Name__c
        System.debug('Agency_Name__c value found: ' + agencyNameValue);
        
        // Set the Name field
       /* if(String.isNotBlank(agencyNameValue)) {
            agency.Name = agencyNameValue;
            System.debug('Setting Name field to Agency_Name__c value: ' + agencyNameValue);
        } 
        // Check other possible name fields
        else if(fieldValues.containsKey('Company_Name__c') && fieldValues.get('Company_Name__c') != null) {
            agency.Name = (String)fieldValues.get('Company_Name__c');
            System.debug('Setting Name field to Company_Name__c: ' + agency.Name);
        }
        else if(fieldValues.containsKey('First_Name__c') && fieldValues.containsKey('Last_Name__c')) {
            String firstName = (String)fieldValues.get('First_Name__c');
            String lastName = (String)fieldValues.get('Last_Name__c');
            if(String.isNotBlank(firstName) || String.isNotBlank(lastName)) {
                agency.Name = (String.isNotBlank(firstName) ? firstName : '') + 
                             (String.isNotBlank(firstName) && String.isNotBlank(lastName) ? ' ' : '') + 
                             (String.isNotBlank(lastName) ? lastName : '');
                System.debug('Setting Name field to First + Last name: ' + agency.Name);
            }
        }
        else {
            // Last resort: Check if there's any field with "Name" in it
            for(String key : fieldValues.keySet()) {
                if(key.containsIgnoreCase('Name') && fieldValues.get(key) != null) {
                    String potentialName = (String)fieldValues.get(key);
                    if(String.isNotBlank(potentialName)) {
                        agency.Name = potentialName;
                        System.debug('Setting Name field from ' + key + ': ' + agency.Name);
                        break;
                    }
                }
            }
            
            // Final fallback
            if(String.isBlank(agency.Name)) {
                agency.Name = 'Agency - ' + System.now().format('yyyy-MM-dd HH:mm');
                System.debug('Setting default Name: ' + agency.Name);
            }
        }*/
        
        // SECOND: Handle picklist values specifically to avoid bad values
        handlePicklistDefaults(agency, fieldMap);
        
        // Debug: Check what values are being set
        System.debug('Final agency object before insert:');
        System.debug('Name: ' + agency.Name);
        System.debug('Agency_Name__c field value: ' + agency.Agency_Name__c);
        System.debug('Onboarding_Stage__c: ' + agency.Onboarding_Stage__c);
        System.debug('Status__c: ' + agency.Status__c);
        System.debug('Total fields to insert: ' + JSON.serializePretty(agency));
        
        // Insert the record
        insert agency;
        
        System.debug('Record created successfully with ID: ' + agency.Id);
        System.debug('Record Name: ' + agency.Name);
        
        return agency.Id;
        
    } 
    
    
    catch (DmlException e) {
    String errorMessage = 'Error creating agency: ';
    for (Integer i = 0; i < e.getNumDml(); i++) {
        errorMessage += e.getDmlMessage(i) + ' ';
    }

    System.debug('DML Error: ' + errorMessage);
        return null;

    // Rethrow as standard Apex exception
   // throw new Exception(errorMessage.trim());

} catch (Exception e) {
    System.debug('General Error: ' + e.getMessage() + ' at line ' + e.getLineNumber());
    System.debug('StackTrace: ' + e.getStackTraceString());
return null;
    //throw new Exception('Error: ' + e.getMessage());
}
 
    
}

// Helper method to handle picklist defaults
private static void handlePicklistDefaults(Agency_Onboarding__c agency, Map<String, Schema.SObjectField> fieldMap) {
    // Handle Onboarding_Stage__c
    if(fieldMap.containsKey('Onboarding_Stage__c')) {
        Schema.DescribeFieldResult stageField = fieldMap.get('Onboarding_Stage__c').getDescribe();
        if(stageField.getType() == Schema.DisplayType.Picklist) {
            // Get all active values
            Map<String, String> activeValues = new Map<String, String>();
            for(Schema.PicklistEntry entry : stageField.getPicklistValues()) {
                if(entry.isActive()) {
                    activeValues.put(entry.getValue(), entry.getLabel());
                }
            }
            
            String currentValue = agency.Onboarding_Stage__c;
            if(String.isBlank(currentValue) || !activeValues.containsKey(currentValue)) {
                // Set to first active value
                for(Schema.PicklistEntry entry : stageField.getPicklistValues()) {
                    if(entry.isActive()) {
                        agency.Onboarding_Stage__c = entry.getValue();
                        System.debug('Set default Onboarding_Stage__c to: ' + entry.getValue());
                        break;
                    }
                }
            }
        }
    }
    
    // Handle Status__c
    if(fieldMap.containsKey('Status__c')) {
        Schema.DescribeFieldResult statusField = fieldMap.get('Status__c').getDescribe();
        if(statusField.getType() == Schema.DisplayType.Picklist) {
            // Get all active values
            Map<String, String> activeValues = new Map<String, String>();
            for(Schema.PicklistEntry entry : statusField.getPicklistValues()) {
                if(entry.isActive()) {
                    activeValues.put(entry.getValue(), entry.getLabel());
                }
            }
            
            String currentValue = agency.Status__c;
            if(String.isBlank(currentValue) || !activeValues.containsKey(currentValue)) {
                // Set to first active value
                for(Schema.PicklistEntry entry : statusField.getPicklistValues()) {
                    if(entry.isActive()) {
                        agency.Status__c = entry.getValue();
                        System.debug('Set default Status__c to: ' + entry.getValue());
                        break;
                    }
                }
            }
        }
    }
}

// Helper method to get default picklist value
private static String getDefaultPicklistValue(String fieldName, Map<String, Schema.SObjectField> fieldMap) {
    if(fieldMap.containsKey(fieldName)) {
        Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
        if(fieldDescribe.getType() == Schema.DisplayType.Picklist) {
            for(Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                if(entry.isActive()) {
                    return entry.getValue();
                }
            }
        }
    }
    return null;
}
    
    // Helper methods for custom options
    private static List<Map<String, String>> getAccountTypeOptions() {
        return new List<Map<String, String>>{
            new Map<String, String>{'label' => '-- None --', 'value' => ''},
            new Map<String, String>{'label' => 'Savings', 'value' => 'Savings'},
            new Map<String, String>{'label' => 'Current', 'value' => 'Current'},
            new Map<String, String>{'label' => 'Checking', 'value' => 'Checking'}
        };
    }
    
    private static List<Map<String, String>> getCurrencyOptions() {
        return new List<Map<String, String>>{
            new Map<String, String>{'label' => '-- None --', 'value' => ''},
            new Map<String, String>{'label' => 'AED - UAE Dirham', 'value' => 'AED'},
            new Map<String, String>{'label' => 'USD - US Dollar', 'value' => 'USD'},
            new Map<String, String>{'label' => 'EUR - Euro', 'value' => 'EUR'},
            new Map<String, String>{'label' => 'GBP - British Pound', 'value' => 'GBP'},
            new Map<String, String>{'label' => 'INR - Indian Rupee', 'value' => 'INR'}
        };
    }
    
    private static List<Map<String, String>> getBankBranchOptions() {
        return new List<Map<String, String>>{
            new Map<String, String>{'label' => '-- None --', 'value' => ''},
            new Map<String, String>{'label' => 'Dubai Main Branch', 'value' => 'Dubai Main'},
            new Map<String, String>{'label' => 'Abu Dhabi Branch', 'value' => 'Abu Dhabi'},
            new Map<String, String>{'label' => 'Sharjah Branch', 'value' => 'Sharjah'},
            new Map<String, String>{'label' => 'Ajman Branch', 'value' => 'Ajman'},
            new Map<String, String>{'label' => 'Ras Al Khaimah Branch', 'value' => 'RAK'}
        };
    }
    
    private static List<Map<String, String>> getCountryOptions() {
        return new List<Map<String, String>>{
            new Map<String, String>{'label' => '-- None --', 'value' => ''},
            new Map<String, String>{'label' => 'United Arab Emirates', 'value' => 'UAE'},
            new Map<String, String>{'label' => 'Saudi Arabia', 'value' => 'KSA'},
            new Map<String, String>{'label' => 'Qatar', 'value' => 'Qatar'},
            new Map<String, String>{'label' => 'Oman', 'value' => 'Oman'},
            new Map<String, String>{'label' => 'Kuwait', 'value' => 'Kuwait'},
            new Map<String, String>{'label' => 'Bahrain', 'value' => 'Bahrain'},
            new Map<String, String>{'label' => 'India', 'value' => 'India'},
            new Map<String, String>{'label' => 'Pakistan', 'value' => 'Pakistan'}
        };
    }
    
    private static List<Map<String, String>> getBankNameOptions() {
    return new List<Map<String, String>>{
        new Map<String, String>{ 'label' => '-- None --', 'value' => '' },
        new Map<String, String>{ 'label' => 'Emirates NBD', 'value' => 'Emirates NBD' },
        new Map<String, String>{ 'label' => 'Dubai Islamic Bank', 'value' => 'Dubai Islamic Bank' },
        new Map<String, String>{ 'label' => 'Commercial Bank of Dubai', 'value' => 'Commercial Bank of Dubai' },
        new Map<String, String>{ 'label' => 'Mashreq Bank', 'value' => 'Mashreq Bank' },
        new Map<String, String>{ 'label' => 'Emirates Islamic Bank', 'value' => 'Emirates Islamic Bank' },
        new Map<String, String>{ 'label' => 'HSBC Bank Middle East (HSBC)', 'value' => 'HSBC Bank Middle East (HSBC)' },
        new Map<String, String>{ 'label' => 'Standard Chartered Bank', 'value' => 'Standard Chartered Bank' },
        new Map<String, String>{ 'label' => 'Citibank', 'value' => 'Citibank' },
        new Map<String, String>{ 'label' => 'Abu Dhabi Commercial Bank (ADCB)', 'value' => 'Abu Dhabi Commercial Bank (ADCB)' },
        new Map<String, String>{ 'label' => 'First Abu Dhabi Bank (FAB)', 'value' => 'First Abu Dhabi Bank (FAB)' },
        new Map<String, String>{ 'label' => 'Bank of Sharjah', 'value' => 'Bank of Sharjah' },
        new Map<String, String>{ 'label' => 'United Arab Bank', 'value' => 'United Arab Bank' },
        new Map<String, String>{ 'label' => 'Invest Bank', 'value' => 'Invest Bank' },
        new Map<String, String>{ 'label' => 'RAKBANK', 'value' => 'RAKBANK' },
        new Map<String, String>{ 'label' => 'Commercial Bank International', 'value' => 'Commercial Bank International' },
        new Map<String, String>{ 'label' => 'National Bank of Fujairah', 'value' => 'National Bank of Fujairah' },
        new Map<String, String>{ 'label' => 'National Bank of Umm Al-Qaiwain', 'value' => 'National Bank of Umm Al-Qaiwain' },
        new Map<String, String>{ 'label' => 'Sharjah Islamic Bank', 'value' => 'Sharjah Islamic Bank' },
        new Map<String, String>{ 'label' => 'Al Hilal Bank', 'value' => 'Al Hilal Bank' },
        new Map<String, String>{ 'label' => 'Ajman Bank', 'value' => 'Ajman Bank' },
        new Map<String, String>{ 'label' => 'WIO Bank', 'value' => 'WIO Bank' }
    };
}

    // 5. Get field metadata (optional - for debugging)
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getPicklistFieldNames() {
        Map<String, String> fieldNames = new Map<String, String>();
        try {
            Schema.DescribeSObjectResult objDescribe = Agency_Onboarding__c.SObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            
            for(String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                if(fieldDescribe.getType() == Schema.DisplayType.Picklist) {
                    fieldNames.put(fieldName, fieldDescribe.getLabel());
                }
            }
        } catch (Exception e) {
            System.debug('Error getting picklist field names: ' + e.getMessage());
        }
        return fieldNames;
    }

@AuraEnabled
public static void updateAgency(Id recordId, Map<String, Object> fieldValues) {
    Account acc = new Account(Id = recordId);
    for (String key : fieldValues.keySet()) {
        acc.put(key, fieldValues.get(key));
    }
    update acc;
}


	@AuraEnabled(cacheable=true)
public static Map<String, Object> getAllPicklistValuesWithMetadata() {
    Map<String, Object> result = new Map<String, Object>();
    try {
        Schema.DescribeSObjectResult objDescribe = Agency_Onboarding__c.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        // Get field labels
        Map<String, String> fieldLabels = new Map<String, String>();
        
        // Get all picklist values
        Map<String, List<Map<String, String>>> picklistValues = new Map<String, List<Map<String, String>>>();
        List<Map<String, Object>> fieldInfoList = new List<Map<String, Object>>();
        
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
            fieldLabels.put(fieldName, fieldDescribe.getLabel());
            
            // Check if field is a picklist
            if(fieldDescribe.isAccessible() && 
               fieldDescribe.getType() == Schema.DisplayType.Picklist) {
                
                List<Map<String, String>> valuesList = new List<Map<String, String>>();
                List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
                
                // Add all active picklist values
                for(Schema.PicklistEntry entry : picklistEntries) {
                    if(entry.isActive()) {
                        valuesList.add(new Map<String, String>{
                            'label' => entry.getLabel(),
                            'value' => entry.getValue()
                        });
                    }
                }
                
                picklistValues.put(fieldName, valuesList);
                
                // Create field info
                Map<String, Object> fieldInfo = new Map<String, Object>();
                fieldInfo.put('apiName', fieldName);
                fieldInfo.put('label', fieldDescribe.getLabel());
                fieldInfo.put('type', 'Picklist');
                fieldInfo.put('required', !fieldDescribe.isNillable());
                fieldInfo.put('values', valuesList);
                fieldInfo.put('count', valuesList.size());
                fieldInfoList.add(fieldInfo);
            }
        }
        
        // Return structured data
        result.put('picklistValues', picklistValues);
        result.put('fieldLabels', fieldLabels);
        result.put('fieldInfo', fieldInfoList);
        result.put('totalPicklistFields', fieldInfoList.size());
        result.put('objectLabel', objDescribe.getLabel());
        result.put('objectName', objDescribe.getName());
        
    } catch (Exception e) {
        throw new System.AuraHandledException
            
         ('Error fetching picklist values: ' + e.getMessage());
    }
    return result;
}



// 6. Upload files as Content Documents (Files) - Main method
@AuraEnabled
public static void uploadFiles(Id recordId, List<Map<String, Object>> filesData) {
    try {
        if (recordId == null || filesData == null || filesData.isEmpty()) {
            System.debug('No files to upload or invalid record ID');
            return;
        }
        
        System.debug('Uploading ' + filesData.size() + ' files for record: ' + recordId);
        
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        
        for (Map<String, Object> fileData : filesData) {
            try {
                String fileName = (String)fileData.get('name');
                String docType = (String)fileData.get('docType');
                String base64Data = (String)fileData.get('base64Data');
                String fileType = (String)fileData.get('type');
                
                if (String.isBlank(base64Data)) {
                    System.debug('Skipping file ' + fileName + ' - No base64 data');
                    continue;
                }
                
                // Decode base64 data
                Blob fileBlob = EncodingUtil.base64Decode(base64Data);
                
                // Check file size (max 5MB)
                if (fileBlob.size() > 5 * 1024 * 1024) {
                    System.debug('File ' + fileName + ' exceeds 5MB limit. Size: ' + fileBlob.size());
                    continue;
                }
                
                // Create ContentVersion
                ContentVersion cv = new ContentVersion();
                cv.VersionData = fileBlob;
                cv.Title = fileName;
                cv.PathOnClient = fileName;
                cv.FirstPublishLocationId = recordId; // This links to the record
                
                // Add document type as description
                if (String.isNotBlank(docType)) {
                    cv.Description = docType + ' - Agency Onboarding Document';
                } else {
                    cv.Description = 'Agency Onboarding Document';
                }
                
                // Set the Origin field to 'H' for Content uploaded through the UI
                cv.Origin = 'H';
                
                contentVersions.add(cv);
                System.debug('Prepared file: ' + fileName + ' for upload');
                
            } catch (Exception e) {
                System.debug('Error processing file: ' + e.getMessage() + ' - ' + e.getStackTraceString());
                // Continue with other files
            }
        }
        
        if (!contentVersions.isEmpty()) {
            // Insert ContentVersion records
            insert contentVersions;
            System.debug('Successfully uploaded ' + contentVersions.size() + ' files as ContentVersion');
            
            // Now create ContentDocumentLinks to link files to the record
            createContentDocumentLinks(recordId, contentVersions);
        }
        
    } catch (Exception e) {
        System.debug('Error uploading files: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        throw new System.AuraHandledException('Error uploading files: ' + e.getMessage());
    }
}

// Helper method to create ContentDocumentLinks
private static void createContentDocumentLinks(Id recordId, List<ContentVersion> contentVersions) {
    try {
        // Get ContentDocumentIds from ContentVersions
        Set<Id> contentVersionIds = new Set<Id>();
        for (ContentVersion cv : contentVersions) {
            contentVersionIds.add(cv.Id);
        }
        
        // Query to get ContentDocumentIds
        List<ContentVersion> contentVersionsWithDocIds = [
            SELECT Id, ContentDocumentId 
            FROM ContentVersion 
            WHERE Id IN :contentVersionIds AND ContentDocumentId != null
        ];
        
        if (contentVersionsWithDocIds.isEmpty()) {
            System.debug('No ContentDocumentIds found for the uploaded files');
            return;
        }
        
        // Create ContentDocumentLinks
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (ContentVersion cv : contentVersionsWithDocIds) {
            if (cv.ContentDocumentId != null) {
                ContentDocumentLink link = new ContentDocumentLink();
                link.ContentDocumentId = cv.ContentDocumentId;
                link.LinkedEntityId = recordId;
                link.ShareType = 'V'; // Viewer permission
                link.Visibility = 'AllUsers';
                
                links.add(link);
            }
        }
        
        if (!links.isEmpty()) {
            insert links;
            System.debug('Created ' + links.size() + ' ContentDocumentLinks for record: ' + recordId);
        }
        
    } catch (Exception e) {
        System.debug('Error creating ContentDocumentLinks: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        // Don't throw error - files are already uploaded as ContentVersion
    }
}

// 7. Alternative method using Attachments (legacy - if you prefer attachments over files)
@AuraEnabled
public static void uploadAttachments(Id recordId, List<Map<String, Object>> filesData) {
    try {
        if (recordId == null || filesData == null || filesData.isEmpty()) {
            return;
        }
        
        List<Attachment> attachments = new List<Attachment>();
        
        for (Map<String, Object> fileData : filesData) {
            try {
                String fileName = (String)fileData.get('name');
                String docType = (String)fileData.get('docType');
                String base64Data = (String)fileData.get('base64Data');
                String fileType = (String)fileData.get('type');
                
                if (String.isBlank(base64Data)) {
                    continue;
                }
                
                // Decode base64 data
                Blob fileBlob = EncodingUtil.base64Decode(base64Data);
                
                // Check file size (max 5MB)
                if (fileBlob.size() > 5 * 1024 * 1024) {
                    System.debug('File ' + fileName + ' exceeds 5MB limit. Size: ' + fileBlob.size());
                    continue;
                }
                
                Attachment att = new Attachment();
                att.Name = fileName;
                att.Body = fileBlob;
                att.ParentId = recordId;
                
                // Set content type
                if (String.isNotBlank(fileType)) {
                    att.ContentType = fileType;
                }
                
                if (String.isNotBlank(docType)) {
                    att.Description = docType;
                }
                
                attachments.add(att);
                
            } catch (Exception e) {
                System.debug('Error processing attachment: ' + e.getMessage());
            }
        }
        
        if (!attachments.isEmpty()) {
            insert attachments;
            System.debug('Successfully uploaded ' + attachments.size() + ' attachments');
        }
        
    } catch (Exception e) {
        System.debug('Error uploading attachments: ' + e.getMessage());
        throw new System.AuraHandledException('Error uploading attachments: ' + e.getMessage());
    }
}


@AuraEnabled(cacheable=true)
public static Map<String, String> checkDuplicate(
    Boolean isIndividual,
    String email,
    String tradeLicense
) {
    Map<String, String> result = new Map<String, String>();
    result.put('exists', 'false');

    if (isIndividual && String.isNotBlank(email)) {

        List<Agency_Onboarding__c> recs = [
            SELECT Id, Name, Email__c
            FROM Agency_Onboarding__c
            WHERE Email__c = :email
            LIMIT 1
        ];

        if (!recs.isEmpty()) {
            result.put('exists', 'true');
            result.put('reason', 'EMAIL');
            result.put('recordId', recs[0].Id);
            result.put('recordName', recs[0].Name);
        }
    }

    if (!isIndividual && String.isNotBlank(tradeLicense)) {

        List<Agency_Onboarding__c> recs = [
            SELECT Id, Name, Trade_License_Number__c
            FROM Agency_Onboarding__c
            WHERE Trade_License_Number__c = :tradeLicense
            LIMIT 1
        ];

        if (!recs.isEmpty()) {
            result.put('exists', 'true');
            result.put('reason', 'TRADE_LICENSE');
            result.put('recordId', recs[0].Id);
            result.put('recordName', recs[0].Name);
        }
    }

    return result;
}

// 8. Method to upload files AFTER record creation - Combined approach
@AuraEnabled
public static Id createAgencyWithFiles(Map<String, Object> fieldValues, Id recordTypeId, List<Map<String, Object>> filesData) {
    try {
        // First, create the agency record
        Id recordId = createAgency(fieldValues, recordTypeId);
        
        // Then, upload files if any
        if (filesData != null && !filesData.isEmpty()) {
            uploadFiles(recordId, filesData);
        }
        
        return recordId;
        
    } catch (Exception e) {
    System.debug(
        'Error in createAgencyWithFiles: ' +
        e.getMessage() + ' - ' + e.getStackTraceString()
    );
    return null; // or handle appropriately
}
}
}