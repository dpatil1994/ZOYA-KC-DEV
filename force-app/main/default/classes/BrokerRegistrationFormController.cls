/**
* @File Name  :  BrokerRegistrationFormController .cls
*@Description : Controller for Broker Registration form VFP- to manage all funtion and get field
*
* @Author            : KC0126(Harshita Singh)
* @Last Modified By  : Harshita Singh
* @Last Modified On  : January 16, 2025
* @Modification Log  :
*==============================================================================
* Ver | Date         | Author              | Modification
*==============================================================================
*  1.0 | December 25, 2025 |   | Initial Version
*  1.1 | January 16, 2025|   | Gets ALL picklist values dynamically'

**/

public class BrokerRegistrationFormController {
    public Agency_Onboarding__c agency { get; set; }
    public Integer corporateTotalSteps { get; set; } 
    public Integer individualTotalSteps { get; set; } 
    public Integer currentStep { get; set; }
    public Integer totalSteps { get; set; }
    public Boolean showSuccessModal { get; set; }
    public Boolean showDuplicateModal { get; set; }
    public String duplicateMessage { get; set; }
    public String duplicateRecordName { get; set; }
 public String selectedAgencyType { get; set; }
public Boolean isCorporate { get; set; }
public Boolean isIndividual { get; set; }
public Date TRNExpiryDate { get; set; }
    

    
    // ================= FILE UPLOAD VARIABLES =================
   
public transient Blob shareOwnerPassportFile { get; set; }
public String shareOwnerPassportFileName { get; set; }

public  transient Blob tradeLicenseFile { get; set; }
public String tradeLicenseFileName { get; set; }

public  transient Blob reraFile { get; set; }
public String reraCertificateFileName { get; set; }

public  transient Blob brokerCardFile { get; set; }
public String brokerCardFileName { get; set; }

public  transient Blob trnVatFile { get; set; }
public String trnVatDeclarationFileName { get; set; }

public  transient Blob vatCertificateFile { get; set; }
public String vatCertificateFileName { get; set; }

public  transient Blob authPassportFile { get; set; }
public String authPassportFileName { get; set; }

public  transient Blob authVisaFile { get; set; }
public String authVisaFileName { get; set; }

public  transient Blob authEidFile { get; set; }
public String authEidFileName { get; set; }

public  transient Blob bankIbanFile { get; set; }
public String bankIbanFileName { get; set; }

public  transient Blob bankNocFile { get; set; }
public String bankNocFileName { get; set; }
    
public  transient Blob moaFile { get; set; }
public String moaFileName { get; set; }
    
public  transient Blob poaFile { get; set; }
public String poaFileName { get; set; }
    
  /* ===============================
   FILE UPLOAD VARIABLES
   =============================== */
public  transient Blob passportFile { get; set; }
public String passportFileName { get; set; }
public  transient Blob visaFile { get; set; }
public String visaFileName { get; set; }
public transient Blob eidFile { get; set; }
public String eidFileName { get; set; }
public transient Blob nationalIdFile { get; set; }
public String nationalIdFileName { get; set; }
public transient Blob bankLetterFile { get; set; }
public String bankLetterFileName { get; set; }
public String createdAgencyName { get; set; }
public Id createdAgencyId { get; set; }


    
    // ========== MISSING PICKLIST OPTIONS - ADD THESE ==========
    public List<SelectOption> agencySubTypeOptionsCorporate { get; set; }
    public List<SelectOption> ownershipOptions { get; set; }
    public List<SelectOption> countryCodeOptions { get; set; }
    public List<SelectOption> nationalityOptions { get; set; }
    public List<SelectOption> bankDocumentOptions { get; set; }
    public List<SelectOption> companyTradeLicenseOptions { get; set; }      
    public List<SelectOption> salesRepOptions { get; set; }                 
    public List<SelectOption> yesNoOptions { get; set; }                    
    public List<SelectOption> licenseTypeOptions { get; set; }   
    //public List<SelectOption> accountTypeOptions { get; set; }
    //public List<SelectOption> currencyOptions { get; set; } 
    // ===== Missing Picklists =====
    // 
public List<SelectOption> countryOptions { get; set; }
public List<SelectOption> designationOptions { get; set; }
public List<SelectOption> accountTypeOptions { get; set; }
public List<SelectOption> currencyOptions { get; set; }
public List<SelectOption> agencySubTypeOptions { get; set; }


    //public Boolean showCorporateFields { get; set; }
   // public Boolean showIndividualFields { get; set; }
    public Boolean showPartnerField { get; set; }
    public Boolean showUaeIdVisaCorporate { get; set; }
    public Boolean showTRNField { get; set; }
    public Boolean isBankDetailsVisible { get; set; }
    public Boolean isDubaiRera { get; set; }                               
    
    public List<Attachment> attachments { get; set; }
    
    // Newely fields added here
    // ================= AGENCY ONBOARDING FIELDS =================
public String Address { get; set; }
public String AgencyAccountManager { get; set; }
public String AgencyName { get; set; }
public String AuthorizedSignatoryEmail { get; set; }
public String AuthorizedSignatoryMobile { get; set; }
public String BankAccountNumber { get; set; }
public String BankAddress { get; set; }
public String BankBranchName { get; set; }
public String BankDocumentAvailable { get; set; }
public String BankName { get; set; }
public String BeneficiaryName { get; set; }
public String BRNNo { get; set; }
public String BrokerAddress { get; set; }
public String City { get; set; }
public String CompanyOfficialPhone { get; set; }
public String CompanyAltEmail1 { get; set; }
public String CompanyAltEmail2 { get; set; }
public String CompanyEmail { get; set; }
public Date CompanyRegExpiryDate { get; set; }
public String CompanyRegNumber { get; set; }
public Date CompanyReraExpiry { get; set; }
public String CompanyTradeLicenseType { get; set; }
public String CompanyOrnReraNumber { get; set; }
public String ContactPersonName { get; set; }
public String Country { get; set; }
public String CountryCode { get; set; }
//public String Currency { get; set; }
public String Designation { get; set; }
public String Email { get; set; }
public Date EmiratesIdExpiry { get; set; }
public String EmiratesIdNumber { get; set; }
public String FirstName { get; set; }
public String HaveTRN { get; set; }
public String IBAN { get; set; }
public String IFSC { get; set; }
public String LastName { get; set; }
public Date NationalIdExpiry { get; set; }
public String NationalIdNumber { get; set; }
public String Nationality { get; set; }
public String NoOfPartners { get; set; }
public String OnboardingStage { get; set; }
public String Ownership { get; set; }
public Date PassportExpiry { get; set; }
public String PassportNo { get; set; }
public String PendingDocuments { get; set; }
public String Phone { get; set; }
public Decimal POBox { get; set; }
public String SalesRepresentative { get; set; }
public String SelectDocument { get; set; }
public String SortCode { get; set; }
public String Status { get; set; }
public String SubType { get; set; }
public String SwiftCode { get; set; }
public Date TradeLicenseExpiry { get; set; }
public String TradeLicenseNumber { get; set; }
public String TRNNumber { get; set; }
public String Type { get; set; }
public String UaeVisaFileNumber { get; set; }
public Date VisaExpiry { get; set; }

    
public BrokerRegistrationFormController() {

    showDuplicateModal = false;

    corporateTotalSteps = 4;
    individualTotalSteps = 3;

    //  Default selection
    selectedAgencyType = 'Corporate';
    currentStep = 1;
    totalSteps = corporateTotalSteps;

    agency = new Agency_Onboarding__c(
        Status__c = 'New',
        Type__c = 'Corporate'
    );
    if (selectedAgencyType == 'Corporate') {
        agency.Sub_Type__c = 'Dubai Real Estate Company (RERA Registered)';
    }


    agency.Have_TRN__c = 'No';
    agency.Bank_Document_Available__c = 'No / Under Process';

    initializePicklistOptions();
}



 /** public void onAgencyTypeChange() {
    system.debug('selectedAgencyType >> '+selectedAgencyType);
    if (selectedAgencyType == 'Corporate') {
        totalSteps = 4;
        isCorporate = true;
        isIndividual = false;
        agency.Type__c = 'Corporate'; // Set Type field
    } else {
        totalSteps = 3;
        isCorporate = false;
        isIndividual = true;
        agency.Type__c = 'Individual'; // Set Type field
    }
    currentStep = 1;
  
    agency = new Agency_Onboarding__c(Status__c = 'New', Type__c = selectedAgencyType);
} **/
    public void onAgencyTypeChange() {
        system.debug('selectedAgencyType## '+selectedAgencyType);
    if (selectedAgencyType == 'Corporate') {
        totalSteps = 4;
        isCorporate = true;
        isIndividual = false;
    } if (selectedAgencyType == 'Individual') {
        totalSteps = 3;
        isCorporate = false;
        isIndividual = true;
    }
         resetFormOnAgencyTypeSwitch();

    currentStep = 1;
    agency.Type__c = selectedAgencyType;
}
    
    private void resetFormOnAgencyTypeSwitch() {

    agency = new Agency_Onboarding__c(
        Status__c = 'New',
        Type__c = selectedAgencyType
    );

    agency.Have_TRN__c = 'No';
    agency.Bank_Document_Available__c = 'No / Under Process';

    if (selectedAgencyType == 'Corporate') {
        agency.Sub_Type__c = 'Dubai Real Estate Company (RERA Registered)';
    }

    currentStep = 1;

    // Clear all files
    tradeLicenseFile = null;
    reraFile = null;
    brokerCardFile = null;
    shareOwnerPassportFile = null;
    trnVatFile = null;
    vatCertificateFile = null;
    authPassportFile = null;
    authVisaFile = null;
    authEidFile = null;
    moaFile = null;
    poaFile = null;
    bankIbanFile = null;
    bankNocFile = null;
    passportFile = null;
    visaFile = null;
    eidFile = null;
    nationalIdFile = null;
    bankLetterFile = null;
}

@TestVisible
    private void init() {
        agency = new Agency_Onboarding__c(
            Status__c = 'New',
         //   OnboardingStage__c = 'Step 1 - Basic Details',
            Bank_Document_Available__c = 'No'
        );
        currentStep = 1;
        totalSteps = 4;
        isCorporate = true;
        isIndividual = false;
      //  showCorporateFields = true;
        //showIndividualFields = false;
        showPartnerField = false;
        showTRNField = false;
        isDubaiRera = false;
        
        initializePicklistOptions();
    }
    @TestVisible
    private Agency_Onboarding__c fetchAgency(Id agencyId) {
    return [
        SELECT Address__c,
               Agency_Account_Manager__c,
               Agency_Name__c,
               Authorized_Signatory_Email__c,
               Authorized_Signatory_Mobile__c,
               Bank_Account_Number__c,
               Bank_Address__c,
               Bank_Branch_Name__c,
               Bank_Document_Available__c,
               Bank_Name__c,
               Beneficiary_name_Account_Holder_Name__c,
               BRN_No__c,
               Company_Address__c,
               Cities__c,
               Company_Official_Phone_No__c,
               Company_Alternate_Email_1__c,
               Company_Alternate_Email_2__c,
               Company_Email__c,
               Company_Registration_Expiry_Date__c,
               Company_Registration_Number__c,
               Company_RERA_Registration_Expiry__c,
               Company_Trade_License_Registration_Type__c,
               Compnay_ORN_RERA_Number__c,
               Contact_Person_Name__c,
               Country__c,
               Country_Code__c,
               Currency__c,
               Designation__c,
               Email__c,
               Emirates_ID_Expiry_Date__c,
               Emirates_No__c,
               First_Name__c,
               Have_TRN__c,
               IBAN_Number__c,
               IFSC_Code__c,
               Last_Name__c,
               National_Id_Expiry_date__c,
               National_Id_Number__c,
               Nationality__c,
               No_Of_Partners__c,
               Onboarding_Stage__c,
               OwnerShip__c,
               Passport_Expiry_Date__c,
               Passport_No__c,
               Pending_Documents__c,
               Phone_No__c,
               PO_Box__c,
               Sales_Representative__c,
               Select_Document__c,
               SORT_Code__c,
               Status__c,
               Sub_Type__c,
               SWIFT_Code__c,
               Trade_License_Expiry_Date__c,
               Trade_License_Number__c,
               TRN_NUMBER_VAT__c,
               Type__c,
               UAE_Visa_File_Number__c,
               Visa_Expiry_Date__c
        FROM Agency_Onboarding__c
        WHERE Id = :agencyId
        LIMIT 1
    ];
}
public Integer getCurrentStepSafe() {
    return currentStep == null ? 1 : currentStep;
}

public Boolean getIsLastStep() {
    return getCurrentStepSafe() >= getTotalSteps();
}
    public Integer getTotalSteps() {
    return getStepLabels().size();
}

    public List<String> getStepLabels() {

    if (selectedAgencyType == 'Corporate') {
        return new List<String>{
            'Corporate / Company Information',
            'Signatory Details',
            'Bank Information',
            'Documents'
        };
    }

    // Individual
    return new List<String>{
        'Agent Details',
        'Bank Information',
        'Documents'
    };
}

@TestVisible
   private void initializePicklistOptions() {

    agencySubTypeOptionsCorporate =
        getPicklistOptions('Agency_Onboarding__c', 'Sub_Type__c');

    agencySubTypeOptions =
        getPicklistOptions('Agency_Onboarding__c', 'Sub_Type__c');

    ownershipOptions =
        getPicklistOptions('Agency_Onboarding__c', 'Ownership__c');

    countryCodeOptions =
        getPicklistOptions('Agency_Onboarding__c', 'Country_Code__c');

    nationalityOptions =
        getPicklistOptions('Agency_Onboarding__c', 'Nationality__c');

    bankDocumentOptions =
        getPicklistOptions('Agency_Onboarding__c', 'Bank_Document_Available__c');

    accountTypeOptions =
        getPicklistOptions('Agency_Onboarding__c', 'Type__c');

    currencyOptions =
        getPicklistOptions('Agency_Onboarding__c', 'Currency__c');

    countryOptions =
        getPicklistOptions('Agency_Onboarding__c', 'Country__c');

    designationOptions =
        getPicklistOptions('Agency_Onboarding__c', 'Designation__c');

    licenseTypeOptions =
        getPicklistOptions('Agency_Onboarding__c',
            'Company_Trade_License_Registration_Type__c');
       companyTradeLicenseOptions =
    getPicklistOptions(
        'Agency_Onboarding__c',
        'Company_Trade_License_Registration_Type__c'
    );


    yesNoOptions = new List<SelectOption>{
        new SelectOption('No', 'No'),
        new SelectOption('Yes', 'Yes')
    };
}

    public Boolean getShowNationalIdCorporate() {
    return agency != null &&
           agency.Sub_Type__c != 'Dubai Real Estate Company (RERA Registered)' &&
           agency.Sub_Type__c != 'International Company';
}
public Boolean getShowReraOptional() {
    return agency != null 
        && agency.Sub_Type__c == 'Dubai Real Estate Company (RERA Registered)'
        && agency.Company_RERA_Registration_Expiry__c == null;
}
public Boolean getShowtrnVatDeclaration() {
    return agency != null && agency.Have_TRN__c == 'Yes';
}
public Boolean getShowVatCertificate() {
    return agency != null && agency.Have_TRN__c == 'Yes';
}
public Boolean getShowAuthPassport() {
    return true;
}

public Boolean getShowAuthVisa() {
    return true;
}

public Boolean getShowAuthEid() {
    return true;
}

public Boolean getShowShareOwner() {
    return agency != null && agency.Ownership__c == 'Partnership';
}

public Boolean getShowMoa() {
    return agency != null && agency.Ownership__c == 'Partnership';
}

public Boolean getShowPoa() {
    return agency != null && agency.Ownership__c == 'Partnership';
}

public Boolean getShowBankIban() {
    return true;
}

public Boolean getShouldShowBankNoc() {
    return agency != null && agency.Bank_Document_Available__c == 'Yes';
}
    
    // ========== GETTER METHODS - CONDITIONAL FIELDS ==========
    public Boolean getShowPartnerField() {
        return agency != null && agency.Ownership__c == 'Partnership';
    }
    
    public Boolean getShowTRNField() {
        return agency != null && agency.Have_TRN__c == 'Yes';
    }
    
    public Boolean getIsDubaiRera() {
        return agency != null && agency.Sub_Type__c == 'Dubai Real Estate Company RERA Registered';
    }
    
    public PageReference nextStep() {

    // Run duplicate check ONLY on step 1
    if (currentStep == 1) {
        if (checkForDuplicates()) {
            showDuplicateModal = true;
            return null; // STOP navigation
        }
    }

    if (currentStep < getTotalSteps()) {
        currentStep++;
    }

    return null;
}
public PageReference previousStep() {
    if (currentStep > 1) {
        currentStep--;
    }
    return null;
}

    
 public PageReference saveAgency() {
    try {

        // STEP 1: Validate current step
        if (!validateCurrentStep()) {
            return null;
        }

        // STEP 2: Duplicate check
        if (checkForDuplicates()) {
            showDuplicateModal = true;
            return null;
        }
        

        // STEP 3: Set Record Type properly
        if (selectedAgencyType == 'Corporate') {
            agency.RecordTypeId = getRecordTypeId('Corporate');
        } 
        else if (selectedAgencyType == 'Individual') {
            agency.RecordTypeId = getRecordTypeId('Individual');
        }

        // STEP 4: Save record
        insert agency;
        
        Agency_Onboarding__c saved =
    [SELECT Name FROM Agency_Onboarding__c WHERE Id = :agency.Id];

createdAgencyId = saved.Id;
createdAgencyName = saved.Name;
        
         validateAllFiles();
          validateRequiredDocuments(); 
        // STEP 5: Upload documents
        uploadDocuments();

        // STEP 6: Show success modal
        showSuccessModal = true;

        return null;

    } catch (Exception e) {
        ApexPages.addMessage(
            new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Error saving record: ' + e.getMessage()
            )
        );
    }
    return null;
}

@TestVisible
    
    private Boolean validateCurrentStep() {
        // Add your validation logic here
        return true;
    }
    
    @TestVisible
    private Boolean checkForDuplicates() {

    // INDIVIDUAL – check by Email
    // INDIVIDUAL – check by Email (skip Rejected records)
if (selectedAgencyType == 'Individual' && agency.Email__c != null) {

    List<Agency_Onboarding__c> dupList = [
        SELECT Id, Name
        FROM Agency_Onboarding__c
        WHERE Email__c = :agency.Email__c
        AND Onboarding_Stage__c != 'Rejected'
        LIMIT 1
    ];

    if (!dupList.isEmpty()) {
        duplicateMessage = 'A record already exists with the same Email.';
        duplicateRecordName = dupList[0].Name;
        return true;
    }
}


    // CORPORATE – check by Trade License
    // CORPORATE – check by Trade License (skip Rejected records)
if (selectedAgencyType == 'Corporate' && agency.Trade_License_Number__c != null) {

    List<Agency_Onboarding__c> dupList = [
        SELECT Id, Name
        FROM Agency_Onboarding__c
        WHERE Trade_License_Number__c = :agency.Trade_License_Number__c
        AND Onboarding_Stage__c != 'Rejected'
        LIMIT 1
    ];

    if (!dupList.isEmpty()) {
        duplicateMessage = 'A record already exists with the same Trade License Number.';
        duplicateRecordName = dupList[0].Name;
        return true;
    }
}


    return false;
}
public void uploadDocuments() {

    uploadAsFile(tradeLicenseFile, tradeLicenseFileName);
    uploadAsFile(reraFile, reraCertificateFileName);
    uploadAsFile(brokerCardFile, brokerCardFileName);
    uploadAsFile(shareOwnerPassportFile, shareOwnerPassportFileName);
    uploadAsFile(trnVatFile, trnVatDeclarationFileName);
    uploadAsFile(vatCertificateFile, vatCertificateFileName);

    uploadAsFile(authPassportFile, authPassportFileName);
    uploadAsFile(authVisaFile, authVisaFileName);
    uploadAsFile(authEidFile, authEidFileName);

    uploadAsFile(moaFile, moaFileName);
    uploadAsFile(poaFile, poaFileName);

    uploadAsFile(bankIbanFile, bankIbanFileName);
    uploadAsFile(bankNocFile, bankNocFileName);

    uploadAsFile(passportFile, passportFileName);
    uploadAsFile(visaFile, visaFileName);
    uploadAsFile(eidFile, eidFileName);
    uploadAsFile(nationalIdFile, nationalIdFileName);
    uploadAsFile(bankLetterFile, bankLetterFileName);

    // Clear blobs (same as tum pehle kar rahe ho)
    tradeLicenseFile = null;
    reraFile = null;
    brokerCardFile = null;
    shareOwnerPassportFile = null;
    trnVatFile = null;
    vatCertificateFile = null;
    authPassportFile = null;
    authVisaFile = null;
    authEidFile = null;
    moaFile = null;
    poaFile = null;
    bankIbanFile = null;
    bankNocFile = null;
    passportFile = null;
    visaFile = null;
    eidFile = null;
    nationalIdFile = null;
    bankLetterFile = null;
}
private void uploadAsFile(Blob fileBody, String fileName) {

    if (fileBody == null || String.isBlank(fileName)) {
        return;
    }

    // Step 1: Create ContentVersion (actual file)
    ContentVersion cv = new ContentVersion();
    cv.Title = fileName;
    cv.PathOnClient = fileName;
    cv.VersionData = fileBody;
    insert cv;

    // Step 2: Get ContentDocumentId
    cv = [
        SELECT ContentDocumentId
        FROM ContentVersion
        WHERE Id = :cv.Id
        LIMIT 1
    ];

    // Step 3: Link file to Agency_Onboarding__c
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.ContentDocumentId = cv.ContentDocumentId;
    cdl.LinkedEntityId = agency.Id;
    cdl.ShareType = 'V';        // Viewer
    cdl.Visibility = 'AllUsers';

    insert cdl;
}

    
    public void toggleAgencyType() {
       currentStep = 1;
    }
    
    @TestVisible
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
    public Boolean getIsUaeResidentIndividual() {
    return agency != null 
        && isIndividual == true
        && agency.Sub_Type__c == 'UAE Residents';
}
public Boolean getIsInternationalIndividual() {
    return agency != null 
        && isIndividual == true
        && agency.Sub_Type__c == 'International';
}

    
    public void loadAgencyData(Id agencyId) { 
    Agency_Onboarding__c a = fetchAgency(agencyId);

  //  Address = a.Address__c != null ? a.Address__c : '';
    AgencyAccountManager = a.Agency_Account_Manager__c != null ? a.Agency_Account_Manager__c : '';
    AgencyName = a.Agency_Name__c != null ? a.Agency_Name__c : '';
    AuthorizedSignatoryEmail = a.Authorized_Signatory_Email__c != null ? a.Authorized_Signatory_Email__c : '';
    AuthorizedSignatoryMobile = a.Authorized_Signatory_Mobile__c != null ? a.Authorized_Signatory_Mobile__c : '';
    BankAccountNumber = a.Bank_Account_Number__c != null ? a.Bank_Account_Number__c : '';
    BankAddress = a.Bank_Address__c != null ? a.Bank_Address__c : '';
    BankBranchName = a.Bank_Branch_Name__c != null ? a.Bank_Branch_Name__c : '';
    BankDocumentAvailable = a.Bank_Document_Available__c != null ? a.Bank_Document_Available__c : '';
    BankName = a.Bank_Name__c != null ? a.Bank_Name__c : '';
    BeneficiaryName = a.Beneficiary_name_Account_Holder_Name__c != null ? a.Beneficiary_name_Account_Holder_Name__c : '';
    BRNNo = a.BRN_No__c != null ? a.BRN_No__c : '';
    BrokerAddress = a.Company_Address__c != null ? a.Company_Address__c : '';
    City = a.Cities__c != null ? a.Cities__c : '';
    CompanyOfficialPhone = a.Company_Official_Phone_No__c != null ? a.Company_Official_Phone_No__c : '';
    CompanyAltEmail1 = a.Company_Alternate_Email_1__c != null ? a.Company_Alternate_Email_1__c : '';
    CompanyAltEmail2 = a.Company_Alternate_Email_2__c != null ? a.Company_Alternate_Email_2__c : '';
    CompanyEmail = a.Company_Email__c != null ? a.Company_Email__c : '';
    CompanyRegExpiryDate = a.Company_Registration_Expiry_Date__c;
    CompanyRegNumber = a.Company_Registration_Number__c != null ? a.Company_Registration_Number__c : '';
    CompanyReraExpiry = a.Company_RERA_Registration_Expiry__c;
    CompanyTradeLicenseType = a.Company_Trade_License_Registration_Type__c != null ? a.Company_Trade_License_Registration_Type__c : '';
    CompanyOrnReraNumber = a.Compnay_ORN_RERA_Number__c != null ? a.Compnay_ORN_RERA_Number__c : '';
    ContactPersonName = a.Contact_Person_Name__c != null ? a.Contact_Person_Name__c : '';
    Country = a.Country__c != null ? a.Country__c : '';
    CountryCode = a.Country_Code__c != null ? a.Country_Code__c : '';
   // Currency = a.Currency__c != null ? a.Currency__c : '';
    Designation = a.Designation__c != null ? a.Designation__c : '';
    Email = a.Email__c != null ? a.Email__c : '';
    EmiratesIdExpiry = a.Emirates_ID_Expiry_Date__c;
    EmiratesIdNumber = a.Emirates_No__c != null ? a.Emirates_No__c : '';
    FirstName = a.First_Name__c != null ? a.First_Name__c : '';
    LastName = a.Last_Name__c != null ? a.Last_Name__c : '';
    PassportExpiry = a.Passport_Expiry_Date__c;
    PassportNo = a.Passport_No__c != null ? a.Passport_No__c : '';
    Status = a.Status__c != null ? a.Status__c : '';
}

    
    
    
    // Step getters
    // 
    public Boolean getIsBankDetailsVisible() {
    return agency != null 
        && agency.Bank_Document_Available__c == 'Yes';
}

    public Boolean getIsCorporate() {
    return selectedAgencyType == 'Corporate';
}

public Boolean getIsIndividual() {
    return selectedAgencyType == 'Individual';
}

    public Boolean getIsStep1() { return currentStep == 1; }
    public Boolean getIsStep2() { return currentStep == 2; }
    public Boolean getIsStep3() { return currentStep == 3; }
    public Boolean getIsStep4() { return currentStep == 4; }
    public Boolean getIsFirstStep() { return currentStep == 1; }
   // public Boolean getIsLastStep() { return currentStep == totalSteps; }
    
    public Boolean getShowTradeLicense() { return true; }
    public Boolean getShowRera() { return false; }
    public Boolean getShowBrokerCard() { return false; } 
    
    
   // public String selectedAgencyType { get; set; }

public List<SelectOption> getCorporateSubTypeOptions() {
    return new List<SelectOption>{
       
        new SelectOption('UAE non real estate company', 'UAE non real estate company'),
        new SelectOption('International Company', 'International Company'),
        new SelectOption('Dubai Real Estate Company (RERA Registered)', 'Dubai Real Estate Company (RERA Registered)'),
        new SelectOption('Real Estate Company - other emirate', 'Real Estate Company - other emirate')
    };
}

public List<SelectOption> getIndividualSubTypeOptions() {
    return new List<SelectOption>{
        new SelectOption('', '-- Select Individual Type --'),
        new SelectOption('UAE Resident', 'UAE Resident'),
        new SelectOption('International', 'International')
    };
}

    @RemoteAction
public static void resetForm() {
    // nothing needed
}
    
    @TestVisible
    private Id getRecordTypeId(String recordTypeName) {
    return [
        SELECT Id 
        FROM RecordType 
        WHERE SObjectType = 'Agency_Onboarding__c'
        AND DeveloperName = :recordTypeName
        LIMIT 1
    ].Id;
}
@TestVisible
    private void resetFormData() {
    agency = new Agency_Onboarding__c();
    currentStep = 1;
    agency.Have_TRN__c = 'No';
    selectedAgencyType = 'Corporate';
         if (selectedAgencyType == 'Corporate') {
        agency.Sub_Type__c = 'Dubai Real Estate Company (RERA Registered)';
    }
    
        
}
    
    
    /* for document visibility of Individual */
  
public Boolean getIsUaeIndividualDoc() {
    return selectedAgencyType == 'Individual'
        && agency.Sub_Type__c == 'UAE Resident';
}

public Boolean getIsInternationalIndividualDoc() {
    return selectedAgencyType == 'Individual'
        && agency.Sub_Type__c == 'International';
}

// Document visibility for Corporate 

    public Boolean getIsDubaiReraCompany() {
    return agency.Sub_Type__c == 'Dubai Real Estate Company (RERA Registered)';
}

public Boolean getIsOtherEmirateCompany() {
    return agency.Sub_Type__c == 'Real Estate Company - other emirate';
}

public Boolean getIsUaeNonRealEstateCompany() {
    return agency.Sub_Type__c == 'UAE non real estate company';
}

public Boolean getIsInternationalCompany() {
    return agency.Sub_Type__c == 'International Company';
}

    public Boolean getHasTRN() {
    return agency.Have_TRN__c == 'Yes';
}

public Boolean getIsPartnership() {
    return agency.OwnerShip__c == 'Partnership';
}

public Boolean getHasBankDocs() {
    return agency.Bank_Document_Available__c == 'Available';
}
@TestVisible
private static final Integer MAX_FILE_SIZE = 5 * 1024 * 1024; // 5 MB
@TestVisible
private void validateFileSize(Blob fileBody, String fileName) {
    if (fileBody != null && fileBody.size() > MAX_FILE_SIZE) {
        ApexPages.addMessage(
            new ApexPages.Message(
                ApexPages.Severity.ERROR,
                fileName + ' exceeds 5 MB limit. Please upload a smaller file.'
            )
        );
        throw new AuraHandledException('File size exceeded');
    }
}
@TestVisible
private void validateAllFiles() {

    // Corporate + Individual
    validateFileSize(tradeLicenseFile, 'Trade License');
    validateFileSize(reraFile, 'RERA Certificate');
    validateFileSize(brokerCardFile, 'Broker Card');
    validateFileSize(trnVatFile, 'TRN / VAT Document');
    validateFileSize(vatCertificateFile, 'VAT Certificate');

    validateFileSize(authPassportFile, 'Authorized Passport');
    validateFileSize(authVisaFile, 'Authorized Visa');
    validateFileSize(authEidFile, 'Emirates ID');

    validateFileSize(shareOwnerPassportFile, 'Share Owner Passport');
    validateFileSize(moaFile, 'Memorandum of Association');
    validateFileSize(poaFile, 'Power of Attorney');

    validateFileSize(bankIbanFile, 'Bank IBAN');
    validateFileSize(bankNocFile, 'Bank NOC');

    // Individual documents
    validateFileSize(passportFile, 'Passport');
    validateFileSize(visaFile, 'Visa');
    validateFileSize(eidFile, 'Emirates ID');
    validateFileSize(nationalIdFile, 'National ID');
    validateFileSize(bankLetterFile, 'Bank Letter');
}

    //Signatory Field Visibility 
        public Boolean getShowNationalId() {
    return agency != null
        && agency.Sub_Type__c != 'Dubai Real Estate Company (RERA Registered)';
}


            public Boolean getShowEmiratesVisa() {
            return agency != null &&
                   agency.Sub_Type__c != 'International Company';
        }
@TestVisible    
private void validateRequiredDocument(Blob file, String label) {
    if (file == null) {
        ApexPages.addMessage(
            new ApexPages.Message(
                ApexPages.Severity.ERROR,
                label + ' is required.'
            )
        );
        throw new AuraHandledException(label + ' missing');
    }
}
    @TestVisible
    private Boolean validateRequiredDocuments() {

    List<String> missingDocs = new List<String>();

    // ========== INDIVIDUAL ==========
    if (selectedAgencyType == 'Individual') {

        if (passportFile == null)
            missingDocs.add('Passport');

        if (agency.Sub_Type__c == 'UAE Resident') {
            if (visaFile == null)
                missingDocs.add('Visa');

            if (eidFile == null)
                missingDocs.add('Emirates ID');
        }

        if (agency.Sub_Type__c == 'International') {
            if (nationalIdFile == null)
                missingDocs.add('National ID');
        }
    }

    // ========== CORPORATE ==========
    if (selectedAgencyType == 'Corporate') {

        if (tradeLicenseFile == null)
            missingDocs.add('Trade License');

        if (agency.Sub_Type__c == 'Dubai Real Estate Company (RERA Registered)' ||
            agency.Sub_Type__c == 'Real Estate Company - other emirate') {

            if (reraFile == null)
                missingDocs.add('RERA Certificate');

            if (brokerCardFile == null)
                missingDocs.add('Broker Card');
        }

        if (agency.Have_TRN__c == 'Yes') {
            if (vatCertificateFile == null)
                missingDocs.add('VAT Certificate');
        } else {
            if (trnVatFile == null)
                missingDocs.add('VAT Declaration');
        }

        if (authPassportFile == null)
            missingDocs.add('Authorized Passport');

        if (agency.Sub_Type__c != 'International Company') {
            if (authVisaFile == null)
                missingDocs.add('Authorized Visa');

            if (authEidFile == null)
                missingDocs.add('Authorized Emirates ID');
        }

        if (agency.OwnerShip__c == 'Partnership') {
            if (shareOwnerPassportFile == null)
                missingDocs.add('Share Owner Passport');

            if (moaFile == null)
                missingDocs.add('Memorandum of Association');
        }

        if (agency.Bank_Document_Available__c == 'Yes') {
            if (bankIbanFile == null)
                missingDocs.add('Bank IBAN Letter');
        } else {
            if (bankNocFile == null)
                missingDocs.add('Bank NOC');
        }
    }
        

    //  STOP SAVE IF MISSING
    if (!missingDocs.isEmpty()) {
        ApexPages.addMessage(
            new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Please upload required documents: ' + String.join(missingDocs, ', ')
            )
        );
        return false; // VERY IMPORTANT
    }

    return true;
}
    public Boolean getShowVatSection() {
    return agency != null
        && agency.Sub_Type__c != 'International Company';
}

public void resetAfterSuccess() {
    showSuccessModal = false;
    currentStep = 1;
    resetFormData();
}
public Boolean getIsOtherEmirateCompanyDoc() {
    return agency != null &&
           agency.Sub_Type__c == 'Real Estate Company - other emirate';
}
    public Boolean getIsUaeNonRealEstateCompanyField() {
    return agency != null &&
           agency.Sub_Type__c == 'UAE non real estate company';
}


public void closeDuplicateModal() {
    showDuplicateModal = false;
}
// Show hide for step 1 

public Boolean getShowReraSection() {
    return agency != null
        && agency.Sub_Type__c == 'Dubai Real Estate Company (RERA Registered)';
}

    // TRN section show/hide
public Boolean getShowTrnSection() {
    return agency != null
        && agency.Have_TRN__c == 'Yes';
}

// Partner count show/hide
public Boolean getShowPartnerCount() {
    return agency != null
        && agency.OwnerShip__c == 'Partnership';
}
// Bank section show / hide
public Boolean getShowBankSection() {
    return agency != null
        && agency.Bank_Document_Available__c == 'Available';
}

    
    // ===== Agent: UAE Resident fields =====
public Boolean getShowUaeAgentFields() {
    return agency != null
        && agency.Sub_Type__c == 'UAE Resident';
}

public Boolean getShowInternationalAgentFields() {
    return agency != null
        && agency.Sub_Type__c == 'International';
}
// new method for changes shared by deepak
public List<SelectOption> getFilteredTradeLicenseOptions() {
    List<SelectOption> filtered = new List<SelectOption>();
    String subTypeValue = agency.Sub_Type__c;  // Correct API
    
    System.debug('=== Sub_Type__c Value: "' + subTypeValue + '"');
    
    if (subTypeValue != null && 
        subTypeValue.trim().equalsIgnoreCase('International Company')) {
        System.debug('=== SHOWING DUBAI ONLY');
        filtered.add(new SelectOption('Dubai Economic Department - Mainland', 
                                     'Dubai Economic Department - Mainland'));
    } else {
        System.debug('=== SHOWING FULL LIST');
        filtered.addAll(companyTradeLicenseOptions);
    }
    return filtered;
}
    public PageReference filterTradeLicenseOnSubTypeChange() {
    // Forces getter re-evaluation with updated agency.SubType__c value
    return null;
}
    private Boolean validateExpiryDates() {
    Date today = Date.today();

    if (agency.Trade_License_Expiry_Date__c != null &&
        agency.Trade_License_Expiry_Date__c < today) {
        ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Trade License Expiry cannot be past date'
        ));
        return false;
    }

    if (agency.Passport_Expiry_Date__c != null &&
        agency.Passport_Expiry_Date__c < today) {
        ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Passport Expiry cannot be past date'
        ));
        return false;
    }

    if (agency.Visa_Expiry_Date__c != null &&
        agency.Visa_Expiry_Date__c < today) {
        ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Visa Expiry cannot be past date'
        ));
        return false;
    }

    if (agency.Emirates_ID_Expiry_Date__c != null &&
        agency.Emirates_ID_Expiry_Date__c < today) {
        ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Emirates ID Expiry cannot be past date'
        ));
        return false;
    }

    if (agency.National_Id_Expiry_date__c != null &&
        agency.National_Id_Expiry_date__c < today) {
        ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'National ID Expiry cannot be past date'
        ));
        return false;
    }

    if (agency.TRN_Expiry_Date__c != null &&
        agency.TRN_Expiry_Date__c < today) {
        ApexPages.addMessage(new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'TRN Expiry cannot be past date'
        ));
        return false;
    }

    return true;
}
    
    
    public List<SelectOption> getUserPicklistOptions() {

    List<SelectOption> options = new List<SelectOption>();

    options.add(new SelectOption('', '-- Select User --'));

    for (User u : [
        SELECT Id, Name 
        FROM User 
        WHERE IsActive = TRUE
        AND (Name LIKE '%Naz%' OR Profile.Name LIKE '%Sales%')
        ORDER BY Name
    ]) {
        options.add(new SelectOption(u.Name, u.Name)); // 👈 TEXT SAVE
    }

    return options;
}
    

}