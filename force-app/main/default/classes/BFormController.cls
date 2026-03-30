public with sharing class BFormController {
    
    public String selectedCategory { get; set; }
    public Integer currentStep { get; set; }
    public Integer maxSteps { get; set; }
    public String emailError { get; set; }
    public String email { get; set; }
    public String companyName { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public Boolean isCorporate { get; set; }
    public Boolean isIndividual { get; set; }
    public Agency_Onboarding__c agency { get; set; }
    
    
    public List<SelectOption> agencySubTypeOptionsCorporate { get; set; }
    public List<SelectOption> ownershipOptions { get; set; }
    public List<SelectOption> countryCodeOptions { get; set; }
    public List<SelectOption> nationalityOptions { get; set; }
    public List<SelectOption> bankDocumentOptions { get; set; }
    public List<SelectOption> companyTradeLicenseOptions { get; set; }      
    public List<SelectOption> salesRepOptions { get; set; }                 
    public List<SelectOption> yesNoOptions { get; set; }                    
    public List<SelectOption> licenseTypeOptions { get; set; }  
    public List<SelectOption> countryOptions { get; set; }
    public List<SelectOption> designationOptions { get; set; }
    public List<SelectOption> accountTypeOptions { get; set; }
    public List<SelectOption> currencyOptions { get; set; }
    public List<SelectOption> agencySubTypeOptions { get; set; }
    
    public BFormController() {
        selectedCategory = 'Corporate';
        currentStep = 1;
        maxSteps = 4; 
    }
    
    public void onCategoryChange() {
        system.debug(selectedCategory);
        currentStep = 1;
        
        if (selectedCategory == 'Corporate') {
            maxSteps = 4;
            isCorporate = true;
            isIndividual = false;
        } else if (selectedCategory == 'Individual') {
            maxSteps = 3;
            isCorporate = false;
            isIndividual = true;
        }
    }
    
    public void validateEmail() {
        emailError = null;
        
        if (String.isBlank(email)) {
            return;
        }
        
        Integer leadCount = [SELECT COUNT() FROM Lead WHERE Email = :email];
        Integer contactCount = [
            SELECT COUNT()
            FROM Contact
            WHERE Email = :email
        ];
        
        if (leadCount > 0 || contactCount > 0) {
            emailError = 'This email already exists. Please enter a different email address.';
        }
    }
    
    public PageReference next() {
        if (String.isNotBlank(emailError)) {
            return null; 
        }
        if (currentStep < maxSteps) {
            currentStep++;
        }
        return null;
    }
    
    public PageReference previous() {
        if (currentStep > 1) {
            currentStep--;
        }
        return null;
    }
    
    public Boolean getIsCorporate() {
        return selectedCategory == 'Corporate';
    }
    
    public Boolean getIsIndividual() {
        return selectedCategory == 'Individual';
    }
    
    public Boolean getIsCategorySelected() {
        return selectedCategory != null;
    }
    private void initializePicklistOptions() {
        agencySubTypeOptionsCorporate = getPicklistOptions('Agency_Onboarding__c', 'Sub_Type__c');
        agencySubTypeOptions = getPicklistOptions('Agency_Onboarding__c', 'Sub_Type__c');
        ownershipOptions = getPicklistOptions('Agency_Onboarding__c', 'Ownership__c');
    }
    
    private List<SelectOption> getPicklistOptions(String objectName, String fieldName) {
        List<SelectOption> options = new List<SelectOption>();
        try {
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            
            if (fieldMap.containsKey(fieldName)) {
                List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldName).getDescribe().getPicklistValues();
                for (Schema.PicklistEntry ple : picklistValues) {
                    if (ple.isActive()) {
                        options.add(new SelectOption(ple.getValue(), ple.getLabel()));
                    }
                }
            }
        } catch (Exception e) {
            // Fallback options if field doesn't exist
            if (fieldName.contains('Country_Code')) {
                options.add(new SelectOption('+971', '+971'));
                options.add(new SelectOption('+91', '+91'));
            }
        }
        return options;
    }
}