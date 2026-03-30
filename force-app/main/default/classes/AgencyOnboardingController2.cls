public with sharing class AgencyOnboardingController2 {

    // 1. Get Record Types (No Change - to get Record Type Id for saving)
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getRecordTypes() {
        // ... (Keep existing implementation) ...
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

    // 2. Updated: Get ALL Picklist values (No Record Type Filtering)
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Map<String, String>>> getAllPicklistValues() {
        Map<String, List<Map<String, String>>> picklistMap = new Map<String, List<Map<String, String>>>();
        try {
            Schema.DescribeSObjectResult objDescribe = Agency_Onboarding__c.SObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();

            // Loop through ALL fields and find picklist fields
            for(String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                
                // Check if field is a picklist and is accessible
                if(fieldDescribe.isAccessible() && 
                   fieldDescribe.getType() == Schema.DisplayType.Picklist) {

                    List<Map<String, String>> valuesList = new List<Map<String, String>>();
                    // 💡 Important: Call getPicklistValues() without arguments 
                    // to get the unfiltered, global set of values.
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
            
            // 💡 Custom Options (Static Values) को वापस जोड़ा जा रहा है 
            // क्योंकि आपने Record Type Filtering हटा दिया है।
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
            throw new AuraHandledException('Error fetching picklist values: ' + e.getMessage());
        }
        return picklistMap;
    }

    // 3. Get Picklist values for specific record type (DELETED - merged into #2)

    // 4. Create Agency_Onboarding__c record (No Change - it already uses recordTypeId from JS)
    @AuraEnabled
    public static Id createAgency(Map<String, Object> fieldValues, Id recordTypeId) {
        // ... (Keep existing implementation - it correctly uses recordTypeId) ...
        try {
            Agency_Onboarding__c agency = new Agency_Onboarding__c();
            
            // Set Record Type using the ID passed from LWC
            agency.RecordTypeId = recordTypeId;
            
            // ... (Rest of the field mapping and DML logic) ...
            
            // Map field values from UI to object fields
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Agency_Onboarding__c.fields.getMap();
            
            for(String key : fieldValues.keySet()) {
                if(fieldMap.containsKey(key)) {
                    Object value = fieldValues.get(key);
                    
                    // Handle empty strings
                    if(value == null || (value instanceof String && String.isBlank((String)value))) {
                        continue;
                    }
                    
                    // Type conversion
                    Schema.DescribeFieldResult fieldDescribe = fieldMap.get(key).getDescribe();
                    if(fieldDescribe.getType() == Schema.DisplayType.DATE && value instanceof String) {
                        try {
                            agency.put(key, Date.valueOf((String)value));
                        } catch (Exception e) {
                            agency.put(key, null);
                        }
                    } else {
                        agency.put(key, value);
                    }
                }
            }
            
            // Set default values if not provided
            if(String.isBlank(agency.Status__c)) {
                agency.Status__c = 'New';
            }
            if(String.isBlank(agency.Onboarding_Stage__c)) {
                agency.Onboarding_Stage__c = 'Step 1 - Basic Details';
            }
            
            // Insert the record
            insert agency;
            
            return agency.Id;
            
        } catch (DmlException e) {
            throw new AuraHandledException('Error creating agency: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
    
    // 💡 Helper methods for custom options (These were in your original code and are needed now)
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
            new Map<String, String>{'label' => '-- None --', 'value' => ''},
            new Map<String, String>{'label' => 'Emirates NBD', 'value' => 'Emirates NBD'},
            new Map<String, String>{'label' => 'Mashreq Bank', 'value' => 'Mashreq'},
            new Map<String, String>{'label' => 'Dubai Islamic Bank', 'value' => 'DIB'},
            new Map<String, String>{'label' => 'ADCB', 'value' => 'ADCB'},
            new Map<String, String>{'label' => 'HSBC', 'value' => 'HSBC'},
            new Map<String, String>{'label' => 'Standard Chartered', 'value' => 'Standard Chartered'},
            new Map<String, String>{'label' => 'RAKBANK', 'value' => 'RAKBANK'},
            new Map<String, String>{'label' => 'Commercial Bank of Dubai', 'value' => 'CBD'}
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
}