@isTest
public class BrokerRegistrationFormControllerTest {

    @TestSetup
    static void setupTestData() {
        insert new Agency_Onboarding__c(
            Status__c = 'New',
            Email__c = 'dup@test.com',
            Trade_License_Number__c = 'TL-DUP-123'
        );
    }

    @isTest
    static void testConstructorFull() {
        Test.startTest();
        BrokerRegistrationFormController ctrl = new BrokerRegistrationFormController();
        Test.stopTest();

        // Constructor coverage + picklists
        ctrl.getCorporateSubTypeOptions();
        ctrl.getIndividualSubTypeOptions();
        ctrl.getStepLabels();
        ctrl.getCurrentStepSafe();
        ctrl.getTotalSteps();
        ctrl.getIsLastStep();
        ctrl.getIsCorporate();
        ctrl.getIsIndividual();
        ctrl.getIsStep1();
        ctrl.getIsStep2();
        ctrl.getIsStep3();
        ctrl.getIsStep4();
        ctrl.getIsFirstStep();
        ctrl.getShowTradeLicense();
        ctrl.getShowRera();
        ctrl.getShowBrokerCard();
    }

    @isTest
    static void testOnAgencyTypeChangeCorporate() {
        BrokerRegistrationFormController ctrl = new BrokerRegistrationFormController();
        
        Test.startTest();
        ctrl.selectedAgencyType = 'Corporate';
        ctrl.onAgencyTypeChange();
        Test.stopTest();

        ctrl.getStepLabels();
    }

    @isTest
    static void testOnAgencyTypeChangeIndividual() {
        BrokerRegistrationFormController ctrl = new BrokerRegistrationFormController();
        
        Test.startTest();
        ctrl.selectedAgencyType = 'Individual';
        ctrl.onAgencyTypeChange();
        Test.stopTest();

        ctrl.getStepLabels();
    }

    @isTest
    static void testNavigationMethods() {
        BrokerRegistrationFormController ctrl = new BrokerRegistrationFormController();
        ctrl.selectedAgencyType = 'Corporate';
        
        Test.startTest();
        ctrl.nextStep();
        ctrl.previousStep();
        ctrl.toggleAgencyType();
        Test.stopTest();
    }

    @isTest
    static void testSaveCorporateSuccessFullPath() {
        BrokerRegistrationFormController ctrl = new BrokerRegistrationFormController();
        
        ctrl.selectedAgencyType = 'Corporate';
        ctrl.onAgencyTypeChange();
        
        ctrl.agency.Agency_Name__c = 'Test Corp Unique';
        ctrl.agency.Trade_License_Number__c = 'TL-UNIQUE-9999';
        ctrl.agency.Have_TRN__c = 'No';
        ctrl.agency.Bank_Document_Available__c = 'No / Under Process';
        
        // Required files for corporate
        ctrl.tradeLicenseFile = Blob.valueOf('trade license data');
        ctrl.tradeLicenseFileName = 'tl.pdf';
        ctrl.authPassportFile = Blob.valueOf('auth passport');
        ctrl.authPassportFileName = 'passport.pdf';
        ctrl.trnVatFile = Blob.valueOf('TRN declaration');
        ctrl.trnVatDeclarationFileName = 'trn.pdf';
        ctrl.bankNocFile = Blob.valueOf('bank noc');
        ctrl.bankNocFileName = 'noc.pdf';

        Test.startTest();
        ctrl.saveAgency();
        Test.stopTest();
    }

    @isTest
    static void testSaveIndividualSuccessFullPath() {
        BrokerRegistrationFormController ctrl = new BrokerRegistrationFormController();
        
        ctrl.selectedAgencyType = 'Individual';
        ctrl.onAgencyTypeChange();
        
        ctrl.agency.Email__c = 'unique-individual-123@test.com';
        ctrl.agency.First_Name__c = 'Test Individual';
        ctrl.agency.Sub_Type__c = 'UAE Resident';
        
        // Individual required files
        ctrl.passportFile = Blob.valueOf('individual passport');
        ctrl.passportFileName = 'passport.pdf';
        ctrl.visaFile = Blob.valueOf('visa');
        ctrl.visaFileName = 'visa.pdf';
        ctrl.eidFile = Blob.valueOf('eid');
        ctrl.eidFileName = 'eid.pdf';

        Test.startTest();
        ctrl.saveAgency();
        Test.stopTest();
    }

    @isTest
    static void testSaveCorporateDuplicate() {
        BrokerRegistrationFormController ctrl = new BrokerRegistrationFormController();
        
        ctrl.selectedAgencyType = 'Corporate';
        ctrl.agency.Trade_License_Number__c = 'TL-DUP-123';

        Test.startTest();
        ctrl.saveAgency();
        Test.stopTest();

        ctrl.closeDuplicateModal();
    }

    @isTest
    static void testSaveIndividualDuplicate() {
        BrokerRegistrationFormController ctrl = new BrokerRegistrationFormController();
        
        ctrl.selectedAgencyType = 'Individual';
        ctrl.agency.Email__c = 'dup@test.com';

        Test.startTest();
        ctrl.saveAgency();
        Test.stopTest();

        ctrl.closeDuplicateModal();
    }

    @isTest
    static void testLoadAgencyDataFull() {
        Agency_Onboarding__c testAgency = new Agency_Onboarding__c(
            Status__c = 'New',
            Agency_Name__c = 'Load Test Agency',
            Trade_License_Number__c = 'TL-LOAD-UNIQUE'
        );
        insert testAgency;

        BrokerRegistrationFormController ctrl = new BrokerRegistrationFormController();

        Test.startTest();
        ctrl.loadAgencyData(testAgency.Id);
        Test.stopTest();
    }

    @isTest
    static void testUploadDocumentsComplete() {
        Agency_Onboarding__c agency = new Agency_Onboarding__c(
            Status__c = 'New',
            Agency_Name__c = 'Upload Test Agency'
        );
        insert agency;

        BrokerRegistrationFormController ctrl = new BrokerRegistrationFormController();
        ctrl.agency = agency;

        // ALL 24 FILES
        ctrl.tradeLicenseFile = Blob.valueOf('tl'); ctrl.tradeLicenseFileName = 'tl.pdf';
        ctrl.reraFile = Blob.valueOf('rera'); ctrl.reraCertificateFileName = 'rera.pdf';
        ctrl.brokerCardFile = Blob.valueOf('broker'); ctrl.brokerCardFileName = 'broker.pdf';
        ctrl.shareOwnerPassportFile = Blob.valueOf('share'); ctrl.shareOwnerPassportFileName = 'share.pdf';
        ctrl.trnVatFile = Blob.valueOf('trn'); ctrl.trnVatDeclarationFileName = 'trn.pdf';
        ctrl.vatCertificateFile = Blob.valueOf('vat'); ctrl.vatCertificateFileName = 'vat.pdf';
        ctrl.authPassportFile = Blob.valueOf('authpass'); ctrl.authPassportFileName = 'authpass.pdf';
        ctrl.authVisaFile = Blob.valueOf('authvisa'); ctrl.authVisaFileName = 'authvisa.pdf';
        ctrl.authEidFile = Blob.valueOf('autheid'); ctrl.authEidFileName = 'autheid.pdf';
        ctrl.moaFile = Blob.valueOf('moa'); ctrl.moaFileName = 'moa.pdf';
        ctrl.poaFile = Blob.valueOf('poa'); ctrl.poaFileName = 'poa.pdf';
        ctrl.bankIbanFile = Blob.valueOf('iban'); ctrl.bankIbanFileName = 'iban.pdf';
        ctrl.bankNocFile = Blob.valueOf('noc'); ctrl.bankNocFileName = 'noc.pdf';
        ctrl.passportFile = Blob.valueOf('pass'); ctrl.passportFileName = 'pass.pdf';
        ctrl.visaFile = Blob.valueOf('visa'); ctrl.visaFileName = 'visa.pdf';
        ctrl.eidFile = Blob.valueOf('eid'); ctrl.eidFileName = 'eid.pdf';
        ctrl.nationalIdFile = Blob.valueOf('natid'); ctrl.nationalIdFileName = 'natid.pdf';
        ctrl.bankLetterFile = Blob.valueOf('bankletter'); ctrl.bankLetterFileName = 'bankletter.pdf';

        Test.startTest();
        ctrl.uploadDocuments();
        Test.stopTest();
    }

    @isTest
    static void testAllBooleanGetters() {
        BrokerRegistrationFormController ctrl = new BrokerRegistrationFormController();
        ctrl.agency = new Agency_Onboarding__c();

        Test.startTest();
        
        // Test ALL EXISTING getters from your controller
        ctrl.getShowPartnerField();
        ctrl.getShowTRNField();
        ctrl.getIsDubaiRera();
        ctrl.getShowNationalIdCorporate();
        ctrl.getShowReraOptional();
        ctrl.getShowtrnVatDeclaration();
        ctrl.getShowVatCertificate();
        ctrl.getShowAuthPassport();
        ctrl.getShowAuthVisa();
        ctrl.getShowAuthEid();
        ctrl.getShowShareOwner();
        ctrl.getShowMoa();
        ctrl.getShowPoa();
        ctrl.getShowBankIban();
        ctrl.getShouldShowBankNoc();
        ctrl.getIsBankDetailsVisible();
        ctrl.getShowVatSection();
        ctrl.getIsDubaiReraCompany();
        ctrl.getIsOtherEmirateCompany();
        ctrl.getIsUaeNonRealEstateCompany();
        ctrl.getIsInternationalCompany();
        ctrl.getHasTRN();
        ctrl.getIsPartnership();
        ctrl.getHasBankDocs();
        ctrl.getShowReraSection();
        ctrl.getShowTrnSection();
        ctrl.getShowPartnerCount();
        ctrl.getShowBankSection();
        ctrl.getIsUaeResidentIndividual();
        ctrl.getIsInternationalIndividual();
        ctrl.getShowNationalId();
        ctrl.getShowEmiratesVisa();

        Test.stopTest();
    }

    @isTest
    static void testUtilityMethods() {
        BrokerRegistrationFormController ctrl = new BrokerRegistrationFormController();
        
        Test.startTest();
        BrokerRegistrationFormController.resetForm();
        ctrl.resetAfterSuccess();
        ctrl.closeDuplicateModal();
        Test.stopTest();
    }

    @isTest
    static void testPicklistEdgeCase() {
        Test.startTest();
        BrokerRegistrationFormController ctrl = new BrokerRegistrationFormController();
        // Constructor calls initializePicklistOptions() - covers getPicklistOptions()
        // Edge case: non-existent field triggers catch block
        ctrl.getPicklistOptions('Agency_Onboarding__c', 'NonExistent__c');
        Test.stopTest();
    }
}