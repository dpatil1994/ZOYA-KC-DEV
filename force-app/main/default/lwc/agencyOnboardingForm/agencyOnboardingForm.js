import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import checkDuplicate from '@salesforce/apex/AgencyOnboardingControllerClone.checkDuplicate';

import getRecordTypes from '@salesforce/apex/AgencyOnboardingControllerClone.getRecordTypes';
import getAllPicklistValues from '@salesforce/apex/AgencyOnboardingControllerClone.getAllPicklistValues';
import createAgency from '@salesforce/apex/AgencyOnboardingControllerClone.createAgency';
//import uploadFiles from '@salesforce/apex/AgencyOnboardingControllerClone.uploadFiles';
import updateAgency from '@salesforce/apex/AgencyOnboardingControllerClone.updateAgency';

import ZOYA_CAROUSEL from '@salesforce/resourceUrl/zoyaCarousel';

export default class AgencyOnboardingForm extends NavigationMixin(LightningElement) {

    /* ============================
       FORM DATA
       ============================ */
    @track agency = {
        // Default values
        Status__c: 'New',
        Onboarding_Stage__c: 'Step 1 - Basic Details',
        Bank_Document_Available__c: 'No',
        IBAN_NUMBER__c: '',
       Emirates_No__c: '',
       Sales_Representative__c: '',
     Agency_Account_Manager__c: ''
    };

    @track stepErrors = [];
@track showDuplicateModal = false;
@track duplicateRecordName;
@track duplicateRecordId;
@track duplicateReason;


@track createdRecordId = null;
@track isDraftCreated = false;

@track uploadedDocTypes = new Set(); // for validation
@track fileNames = {};     // already present (keep it)

    @track isBankDetailsVisible = false;
    //@track uploadedFiles = [];
    @track showSuccessModal = false;

    /* ============================
       PICKLIST & RECORD TYPE DATA
       ============================ */
    @track picklistOptions = {};
    @track recordTypeOptions = [];
    @track selectedRecordTypeId;
    @track recordTypeMap = {};
    
    /* ============================
       UI STATE
       ============================ */
    @track showCorporateFields = true;
    @track showIndividualFields = false;
    @track currentStep = 1;
    @track steps = [];
    
    @api recordId;
    @track isEditMode = false;
    
    carouselImage = ZOYA_CAROUSEL;
    
    @track isCorporate = true;
    @track isIndividual = false;

    @track showTRNField = false;
 
    @track showPartnerField = false;
    agencySubTypeOptions = [
        { label: 'UAE Residents', value: 'UAE Residents' },
        { label: 'International', value: 'International' }
    ];
    agencySubTypeOptionscorporate = [
    { label: 'Real Estate Company - other emirate', value: 'Real Estate Company - other emirate' },
    { label: 'UAE non real estate company', value: 'UAE non real estate company' },
    { label: 'International Company', value: 'International Company' },
    { label: 'Dubai Real Estate Company (RERA Registered)', value: 'Dubai Real Estate Company (RERA Registered)' }
];

/*salesRepresentativeOptions = [
    { label: 'Siddikaa Nazneen (CSO)', value: 'Siddikaa Nazneen (CSO)' },
    { label: 'Anastasiaa (Sales Team Manager)', value: 'Anastasiaa (Sales Team Manager)' },
    { label: 'Neha Thakur (Sales Team Manager)', value: 'Neha Thakur (Sales Team Manager)' },
    { label: 'Abdel Fattah Diaab', value: 'Abdel Fattah Diaab' },
    { label: 'Manal', value: 'Manal' },
    { label: 'Ramy Elmansy', value: 'Ramy Elmansy' },
    { label: 'Toufik', value: 'Toufik' },
    { label: 'Sana Ahmed', value: 'Sana Ahmed' },
    { label: 'Alina', value: 'Alina' },
    { label: 'Ahmed Hamdy', value: 'Ahmed Hamdy' },
    { label: 'Abdulla MK', value: 'Abdulla MK' },
    { label: 'Apoorv', value: 'Apoorv' }
];*/

    /* ============================
       VALIDATION STATE
       ============================ */
    @track fieldErrors = {}; // Track field-level errors
    @track captchaInput = ''; // Add captcha input tracking
   @track visibleDocs = {};

    /* ============================
       GETTERS
       ============================ */
    get isStep1() { return this.currentStep === 1; }
    get isStep2() { return this.currentStep === 2; }
    get isStep3() { return this.currentStep === 3; }
    get isStep4() { return this.isCorporate && this.currentStep === 4; }
    get isFirstStep() { return this.currentStep === 1; }
    get isLastStep() {
        return this.isCorporate 
            ? this.currentStep === 4 
            : this.currentStep === 3;
    }


/* =========================
   INDIVIDUAL SUBTYPE HELPERS for new request of christine 
   ========================= */

get isUaeResidentIndividual() {
    return this.isIndividual && this.agency.Sub_Type__c === 'UAE Residents';
}

get isInternationalIndividual() {
    return this.isIndividual && this.agency.Sub_Type__c === 'International';
}

//corporate

get isDubaiRera() {
    return this.agency.Sub_Type__c === 'Dubai Real Estate Company (RERA Registered)';
}

get showUaeIdVisaCorporate() {
    return this.agency.Sub_Type__c !== 'International Company';
}

get showNationalIdCorporate() {
    return (
        this.agency.Sub_Type__c !== 'Dubai Real Estate Company (RERA Registered)' &&
        this.agency.Sub_Type__c !== 'International Company'
    );
}

get isCountryCodeRequiredCorporate() {
    return (
        this.agency.Sub_Type__c === 'Dubai Real Estate Company (RERA Registered)' ||
        this.agency.Sub_Type__c === 'International Company'
    );
}

    /* ============================
       LIFECYCLE HOOKS
       ============================ */
    connectedCallback() {
        if (this.recordId) {
            this.isEditMode = true;
            this.loadRecordData();
        }
        this.updateStepPath();
        this.isBankDetailsVisible = this.agency.Bank_Document_Available__c === 'Yes';
    }

    /* ============================
       WIRED METHODS
       ============================ */
    @wire(getRecordTypes)
    wiredRecordTypes({ data, error }) {
        if (data) {
            this.recordTypeOptions = data;
            data.forEach(rt => {
                this.recordTypeMap[rt.label] = rt.value;
            });

            // Default to Corporate or first record type
            if (this.recordTypeMap['Corporate']) {
                this.selectedRecordTypeId = this.recordTypeMap['Corporate'];
            } else if (data.length > 0) {
                this.selectedRecordTypeId = data[0].value;
            }
        } else if (error) {
            this.showToast('Error', 'Failed to load record types', 'error');
        }
    }

    @wire(getAllPicklistValues)
    wiredPicklists({ data, error }) {
        if (data) {
            this.picklistOptions = data;
            console.log('Loaded picklist options:', Object.keys(data).length, 'fields');
            console.log('Country__c picklist:', data.Country__c);
            
            // Log all picklist fields for debugging
            Object.keys(data).forEach(fieldName => {
                console.log(`${fieldName}: ${data[fieldName].length} options`);
            });
        } else if (error) {
            console.error('Picklist Error:', error);
            this.showToast('Error', 'Failed to load picklist values', 'error');
        }
    }

    /* ============================
       METHODS
       ============================ */
    
    updateStepPath() {
        const totalSteps = this.isCorporate ? 4 : 3;
        const labels = this.isCorporate 
            ? ["Company Information", "Signatory Details", "Bank Info", "Documents"]
            : ["Agent Details", "Bank Info", "Documents"];
        
        this.steps = Array.from({length: totalSteps}, (_, i) => ({
            number: i + 1,
            label: labels[i],
            class: i + 1 < this.currentStep ? 'step step-completed' :
                   i + 1 === this.currentStep ? 'step step-active' : 'step'
        }));
    }

  /*  get showEmiratesIdField() {
    return this.agency === 'INDIVIDUAL UAE (NATIONAL OR RESIDENT)';
}  */
handleChange(event) {
    const { name, value } = event.target;

    // Update agency field
    this.agency = { 
        ...this.agency, 
        [name]: value || null 
    };

    console.log(this.agency);

    /* ===============================
       OWNERSHIP → PARTNERS
       =============================== */
    if (name === 'ownership__c') {
        this.showPartnerField = (value === 'Partnership');

        if (!this.showPartnerField) {
            this.agency = {
                ...this.agency,
                No_Of_Partners__c: null
            };
        }
         this.updateVisibleDocs(this.agency.Sub_Type__c);
    }

    /* ===============================
       TRN FIELD
       =============================== */
    if (name === 'have_trn__c') {

        this.agency = {
            ...this.agency,
            Have_TRN__c: value || null
        };

        this.showTRNField = value === 'Yes';

        if (value !== 'Yes') {
            this.agency.TRN_NUMBER_VAT__c = null;
        }

        // 🔹 IMPORTANT: refresh documents
        this.updateVisibleDocs(this.agency.Sub_Type__c);
    }

    /* ===============================
       SUB TYPE CHANGE
       =============================== */
    if (name === 'Sub_Type__c') {

        // Existing document logic (DO NOT REMOVE)
        this.updateVisibleDocs(value);

        // 👉 ONLY FOR INDIVIDUAL
        if (this.isIndividual) {

            if (value === 'UAE Residents') {
                this.agency = {
                    ...this.agency,
                    National_Id_Number__c: null,
                    National_Id_Expiry_date__c: null,
                    Country__c: null
                };
            }

            if (value === 'International') {
                this.agency = {
                    ...this.agency,
                    Emirates_No__c: null,
                    Emirates_ID_Expiry_Date__c: null,
                    UAE_Visa_File_Number__c: null,
                    Visa_Expiry_Date__c: null
                };
            }
        }
    }

    /* ===============================
       BANK DETAILS VISIBILITY
       =============================== */
    if (name === 'Bank_Document_Available__c') {
        this.isBankDetailsVisible = value === 'Yes';

        //  IMPORTANT: refresh documents
        this.updateVisibleDocs(this.agency.Sub_Type__c);
    }

    /* ===============================
       CLEAR FIELD ERROR ON CHANGE
       =============================== */
    if (this.fieldErrors[name]) {
        this.fieldErrors = { ...this.fieldErrors, [name]: null };
        this.clearFieldError(name);
    }

    console.log(`Field changed: ${name} = ${value}`);
}

updateVisibleDocs(subtype) {

    console.log(
        "RUN updateVisibleDocs with subtype =",
        subtype,
        "| length:",
        subtype?.length
    );

    // 🔹 reset
    this.visibleDocs = {};

    // 🔹 subtype based docs (existing logic)
    const required = this.documentRules[subtype];

    if (!required) {
        console.log("No matching document rule found for:", subtype);
        return;
    }

    required.forEach(doc => {
        this.visibleDocs[doc] = true;
    });
   /* ===============================
   🟢 OWNERSHIP BASED DOCUMENT LOGIC
   =============================== */

if (this.isCorporate && this.agency.ownership__c === 'Partnership') {
    this.visibleDocs["Share Owner's Passport Copy"] = true;
    this.visibleDocs["Memorandum of Association"] = true;
} else {
    delete this.visibleDocs["Share Owner's Passport Copy"];
    delete this.visibleDocs["Memorandum of Association"];
}


    /* ===============================
       🟢 CORPORATE TRN DOCUMENT LOGIC
       =============================== */
    if (this.isCorporate) {
        const hasTrn = this.agency.Have_TRN__c === 'Yes';

        if (hasTrn) {
            // show VAT Certificate only
            this.visibleDocs['VAT Certificate'] = true;
            delete this.visibleDocs['TRN / VAT Declaration'];
        } else {
            // show TRN / VAT Declaration only
            this.visibleDocs['TRN / VAT Declaration'] = true;
            delete this.visibleDocs['VAT Certificate'];
        }
    }

    /* ===============================
   🟢 BANK DOCUMENT LOGIC
   =============================== */
const bankStatus = this.agency.Bank_Document_Available__c;

// 🔹 CORPORATE ONLY
if (this.isCorporate) {
    if (bankStatus === 'No') {
        this.visibleDocs['Bank NOC'] = true;
        delete this.visibleDocs['Bank / IBAN Letter'];
    }

    if (bankStatus === 'Yes') {
        this.visibleDocs['Bank / IBAN Letter'] = true;
        delete this.visibleDocs['Bank NOC'];
    }
}

// 🔹 INDIVIDUAL ONLY
if (this.isIndividual) {
    if (bankStatus === 'No') {
        this.visibleDocs['Bank NOC'] = true;
        delete this.visibleDocs['Bank Letter'];
    }

    if (bankStatus === 'Yes') {
        this.visibleDocs['Bank Letter'] = true;
        delete this.visibleDocs['Bank NOC'];
        // DO NOTHING
        // Bank Letter already comes from documentRules
    }
}
    console.log(
        "Final Visible docs set to:",
        JSON.stringify(this.visibleDocs)
    );
}

    handleCorporateSelect(event) {
        event.preventDefault();
        this.switchToCorporate();
    }

    handleIndividualSelect(event) {
        event.preventDefault();
        this.switchToIndividual();
    }
resetAgencyData() {
    this.agency = {
        Status__c: 'New',
        Onboarding_Stage__c: 'Step 1 - Basic Details',
        Bank_Document_Available__c: 'No',
        IBAN_NUMBER__c: '',
        Emirates_No__c: '',
        Sales_Representative__c: '',
        Agency_Account_Manager__c: ''
    };

    // Clear document & validation state
    this.visibleDocs = {};
    this.uploadedDocTypes = new Set();
    this.fileNames = {};
    this.fieldErrors = {};
    this.stepErrors = [];
    this.isBankDetailsVisible = false;
}

    switchToCorporate() {
        this.isCorporate = true;
        this.resetAgencyData();
        this.isIndividual = false;
        this.showCorporateFields = true;
        this.showIndividualFields = false;
        
        if (this.recordTypeMap['Corporate']) {
            this.selectedRecordTypeId = this.recordTypeMap['Corporate'];
        }
        
        this.currentStep = 1;
        this.updateStepPath();
        this.clearAllFieldErrors();
    }

    switchToIndividual() {
        this.isCorporate = false;
        this.resetAgencyData();
        this.isIndividual = true;
        this.showCorporateFields = false;
        this.showIndividualFields = true;
        
        if (this.recordTypeMap['Individual']) {
            this.selectedRecordTypeId = this.recordTypeMap['Individual'];
        } else if (this.recordTypeOptions.length > 1) {
            this.selectedRecordTypeId = this.recordTypeOptions[1].value;
        }
        
        this.currentStep = 1;
        this.updateStepPath();
        this.clearAllFieldErrors();
    }

    async handleNext() {
    console.log('STEP:', this.currentStep);
    console.log('AGENCY:', JSON.stringify(this.agency, null, 2));

    // Step validation
    if (!this.validateCurrentStep()) {
        console.log(' Current step validation failed');
        return;
    }
     /* ===============================
       🔍 DUPLICATE CHECK (STEP 1 ONLY)
       =============================== */
    if (this.currentStep === 1) {
        const duplicateResult = await checkDuplicate({
            isIndividual: this.isIndividual,
            email: this.isIndividual ? this.agency.Email__c : null,
            tradeLicense: this.isCorporate ? this.agency.Trade_License_Number__c : null
        });

        if (duplicateResult.exists === 'true') {
            this.showDuplicatePopup(
                duplicateResult.recordName,
                duplicateResult.recordId,
                duplicateResult.reason
            );
            return; //  STOP navigation
        }
    }


    const maxSteps = this.isCorporate ? 4 : 3;

    //  CHECK: Documents step se pehle record create karna hai
    const isBeforeDocumentStep =
        (this.isCorporate && this.currentStep === 3) ||
        (!this.isCorporate && this.currentStep === 2);

   

    // Move to next step
    if (this.currentStep < maxSteps) {
        this.currentStep++;
        this.updateStepPath();
        window.scrollTo(0, 0);
    }
}


    handlePrevious() {
        if (this.currentStep > 1) {
            this.currentStep--;
            this.updateStepPath();
            window.scrollTo(0, 0);
            this.clearAllFieldErrors();
        }
    }

    // Clear all field errors
    clearAllFieldErrors() {
        this.fieldErrors = {};
        // Clear all error messages from UI
        const errorElements = this.template.querySelectorAll('.field-error');
        errorElements.forEach(element => {
            element.style.display = 'none';
        });
        // Clear custom validity
        const inputs = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-input-field');
        inputs.forEach(input => {
            if (input.setCustomValidity) {
                input.setCustomValidity('');
                input.reportValidity();
            }
        });
        // Remove error highlighting
        const errorContainers = this.template.querySelectorAll('[data-field]');
        errorContainers.forEach(container => {
            container.style.borderLeft = 'none';
            container.style.paddingLeft = '0';
        });
        // Remove error class from inputs
        const errorInputs = this.template.querySelectorAll('.slds-has-error');
        errorInputs.forEach(input => {
            input.classList.remove('slds-has-error');
        });
    }

    // Clear specific field error
    clearFieldError(fieldName) {
        const errorElement = this.template.querySelector(`[data-error="${fieldName}"]`);
        if (errorElement) {
            errorElement.style.display = 'none';
        }
        const inputElement = this.template.querySelector(`[name="${fieldName}"]`);
        if (inputElement && inputElement.setCustomValidity) {
            inputElement.setCustomValidity('');
            inputElement.reportValidity();
        }
        // Remove error highlighting
        const fieldContainer = this.template.querySelector(`[data-field="${fieldName}"]`);
        if (fieldContainer) {
            fieldContainer.style.borderLeft = 'none';
            fieldContainer.style.paddingLeft = '0';
        }
        // Remove error class
        const inputField = this.template.querySelector(`[name="${fieldName}"]`);
        if (inputField) {
            inputField.classList.remove('slds-has-error');
        }
    }

    // Show field error in UI (remove console.error)
    showFieldError(fieldName, message) {
        // Store error in state
        this.fieldErrors = { ...this.fieldErrors, [fieldName]: message };
        
        // Try to find the error message element
        let errorElement = this.template.querySelector(`[data-error="${fieldName}"]`);
        
        // If no specific error element exists, try to find by data-field attribute
        if (!errorElement) {
            errorElement = this.template.querySelector(`[data-field="${fieldName}"] .field-error`);
        }
        
        // If still no element, try to find any error container with matching field
        if (!errorElement) {
            const allErrorElements = this.template.querySelectorAll('[data-field]');
            for (let container of allErrorElements) {
                const field = container.getAttribute('data-field');
                if (field === fieldName) {
                    const innerError = container.querySelector('.field-error');
                    if (innerError) {
                        errorElement = innerError;
                        break;
                    }
                }
            }
        }
        
        // Show error message in the element if found
        if (errorElement) {
            errorElement.textContent = message;
            errorElement.style.display = 'block';
            errorElement.style.color = '#c23934';
            errorElement.style.fontSize = '0.75rem';
            errorElement.style.marginTop = '0.25rem';
            
            // Scroll to error element
            setTimeout(() => {
                errorElement.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }, 100);
        } else {
            // Fallback: set custom validity on the input field
            const inputElement = this.template.querySelector(`[name="${fieldName}"]`);
            if (inputElement && inputElement.setCustomValidity) {
                inputElement.setCustomValidity(message);
                inputElement.reportValidity();
            }
            // Do NOT show console error - validation should be silent in console
        }
        
        // Highlight the field with error
        const fieldContainer = this.template.querySelector(`[data-field="${fieldName}"]`);
        if (fieldContainer) {
            fieldContainer.style.borderLeft = '3px solid #c23934';
            fieldContainer.style.paddingLeft = '0.5rem';
        }
        
        // Also add error class to the input itself
        const inputField = this.template.querySelector(`[name="${fieldName}"]`);
        if (inputField) {
            inputField.classList.add('slds-has-error');
        }
    }

    // Improved validation method
    validateCurrentStep() {
        // Clear previous errors for this step
         this.stepErrors = []; 
        this.clearAllFieldErrors();
        
        // Step-wise validation based on form type
        if (this.isCorporate) {
            return this.validateCorporateStep();
        } else {
            return this.validateIndividualStep();
        }
    }

    // Corporate Form Validation
    validateCorporateStep() {
        switch(this.currentStep) {
            case 1:
                return this.validateCorporateStep1();
            case 2:
                return this.validateCorporateStep2();
            case 3:
                return this.validateCorporateStep3();
            case 4:
                return this.validateCorporateStep4();
            default:
                return true;
        }
    }

    // Corporate Step 1 Validation
    validateCorporateStep1() {

    const st = this.agency.Sub_Type__c;

    let requiredFields = [
        'Sub_Type__c',
        'Agency_Name__c',
        'Trade_License_Number__c',
        'Company_Trade_License_Registration_Type__c',
        'Trade_License_Expiry_Date__c',
        'Company_Email__c',
        'Company_Official_Phone_No__c',
        'Sales_Representative__c',
        'Country_Code__c'
    ];

    if (st === 'Dubai Real Estate Company (RERA Registered)') {
        requiredFields.push(
            'ownership__c',
            //'Company_Alternate_Email_1__c',
            'Company_RERA_Registration_Expiry__c',
            'PO_Box__c',
            'Have_TRN__c',
            'Compnay_ORN_RERA_Number__c',
            'Company_Address__c',
            'Country_Code__c'
        );
    }

    if (st === 'UAE non real estate company') {
        requiredFields.push(
            //'Company_Alternate_Email_1__c',
            'PO_Box__c',
            'Have_TRN__c',
            'Company_Address__c',
            'Country_Code__c'
        );
    }

    if (st === 'Real Estate Company - other emirate') {
        requiredFields.push(
            'ownership__c',
           // 'Company_Alternate_Email_1__c',
            'PO_Box__c',
            'Have_TRN__c',
            'Company_Address__c',
            'Country_Code__c'
        );
    }

    if (st === 'International Company') {
        requiredFields.push(
            'ownership__c',
            //'Company_Alternate_Email_1__c',
            'PO_Box__c',
            'Have_TRN__c',
            'Company_Address__c',
            'Country_Code__c'
        );
    }

    // TRN Number only if Have TRN = Yes
    if (this.agency.Have_TRN__c === 'Yes') {
        requiredFields.push('TRN_NUMBER_VAT__c');
    }

    return this.validateFields(requiredFields);
}


    // Corporate Step 2 Validation
   validateCorporateStep2() {

    const st = this.agency.Sub_Type__c;

    let requiredFields = [
        'First_Name__c',
        'Last_Name__c',
        'Passport_No__c',
        'Passport_Expiry_Date__c',
        'Authorized_Signatory_Mobile__c',
        'Designation__c',
        'Authorized_Signatory_Email__c',
        'Nationality__c'
    ];

    if (
        st === 'Dubai Real Estate Company (RERA Registered)' ||
        st === 'International Company'
    ) {
       requiredFields.push('Country_Code__c');

    }

    return this.validateFields(requiredFields);
}

    // Corporate Step 3 Validation
    validateCorporateStep3() {
        let isValid = true;
        
        // Bank Document Available is required
        if (!this.agency.Bank_Document_Available__c) {
            this.showFieldError('Bank_Document_Available__c', 'Please select if Bank Document is Available');
             this.stepErrors.push(label); 
            isValid = false;
        }
        
        // If bank document is available, validate bank details
        if (this.isBankDetailsVisible) {
            const bankRequiredFields = [
                'Beneficiary_name_Account_Holder_Name__c',
                'Type__c',
                'Currency__c',
                'Bank_Account_Number__c',
                'Bank_Branch_Name__c',
                'Bank_Address__c',
                'Country__c'
            ];
            
            if (!this.validateFields(bankRequiredFields)) {
                isValid = false;
            }
        }
        
        return isValid;
    }


 // Corporate Step 4 Validation - Fixed document validation
    validateCorporateStep4() {

    let isValid = true;

    Object.keys(this.visibleDocs).forEach(doc => {

        if (!this.isDocumentRequired(doc)) return;

        if (this.isDocumentMissing(doc)) {

            const clean = doc.replace(/[^a-zA-Z0-9]/g, '_');

            this.showFieldError(clean, `Please upload ${doc}`);
            this.stepErrors.push(doc);

            isValid = false;
        }
    });

    return isValid;
}


    // Individual Form Validation
    validateIndividualStep() {
        switch(this.currentStep) {
            case 1:
                return this.validateIndividualStep1();
            case 2:
                return this.validateIndividualStep2();
            case 3:
                return this.validateIndividualStep3();
            default:
                return true;
        }
    }

    validateIndividualStep1() {

    let requiredFields = [
        'First_Name__c',
        'Last_Name__c',
        'Email__c',
        'Phone_No__c',
        'Sales_Representative__c',
        'Country_Code__c'
    ];

    if (this.isUaeResidentIndividual) {
        requiredFields.push(
            'Emirates_No__c',
            'Emirates_ID_Expiry_Date__c',
            'UAE_Visa_File_Number__c',
            'Visa_Expiry_Date__c',
            'Country_Code__c'
        );
    }

    if (this.isInternationalIndividual) {
        requiredFields.push(
            'National_Id_Number__c',
            'National_Id_Expiry_date__c',
            'Country__c',
            'Country_Code__c'

        );
    }

    return this.validateFields(requiredFields);
}


    // Individual Step 2 Validation
    validateIndividualStep2() {
        let isValid = true;
        
        // Bank Document Available is required
        if (!this.agency.Bank_Document_Available__c) {
            this.showFieldError('Bank_Document_Available__c', 'Please select if Bank Document is Available');
             this.stepErrors.push(label); 
            isValid = false;
        }
        
        // If bank document is available, validate bank details
        if (this.isBankDetailsVisible) {
            const bankRequiredFields = [
                'Beneficiary_name_Account_Holder_Name__c',
                'Type__c',
                'Currency__c',
                'Bank_Account_Number__c',
                'Bank_Branch_Name__c',
                'Bank_Address__c',
                'Country__c',
                'Country_Code__c'
                
            ];
            
            if (!this.validateFields(bankRequiredFields)) {
                isValid = false;
            }
        }
        
        return isValid;
    }

    // Individual Step 3 Validation - Fixed document validation
   validateIndividualStep3() {

    let isValid = true;

    Object.keys(this.visibleDocs).forEach(doc => {

        if (!this.isDocumentRequired(doc)) return;

        if (this.isDocumentMissing(doc)) {

            const clean = doc.replace(/[^a-zA-Z0-9]/g, '_');

            this.showFieldError(clean, `Please upload ${doc}`);
            this.stepErrors.push(doc); //  document in top error

            isValid = false;
        }
    });

    return isValid;
}

isDocumentRequired(doc) {

    if (doc.includes('(if available)')) return false;

    const bankStatus = this.agency.Bank_Document_Available__c;

    if (doc === 'Bank Letter') return bankStatus === 'Yes';
    if (doc === 'Bank / IBAN Letter') return bankStatus === 'Yes';
    if (doc === 'Bank NOC') return bankStatus === 'No';

    return true;
}

isDocumentMissing(doc) {
    return !this.uploadedDocTypes.has(doc);
}


    // Generic field validation helper
    validateFields(fieldNames) {
        let isValid = true;
        
        for (const fieldName of fieldNames) {
            const value = this.agency[fieldName];
            
            if (!value || (typeof value === 'string' && value.trim() === '')) {
               const label = this.getFieldLabel(fieldName);
this.showFieldError(fieldName, `${label} is required`);
this.stepErrors.push(label);   // 🔴 add to top error
isValid = false;

            }
            
            // Special validation for email fields
            if (fieldName.includes('Email') && value) {
                if (!this.isValidEmail(value)) {
                    this.showFieldError(fieldName, 'Please enter a valid email address');
                    isValid = false;
                }
            }
            
            // Special validation for phone fields
            if (fieldName.includes('Phone') && value) {
                if (!this.isValidPhone(value)) {
                    this.showFieldError(fieldName, 'Please enter a valid phone number');
                    isValid = false;
                }
            }
            
            // Special validation for date fields
            if (fieldName.includes('Date') && value) {
                if (!this.isValidDate(value)) {
                    this.showFieldError(fieldName, 'Please enter a valid date');
                    isValid = false;
                }
            }
        }
        
        return isValid;
    }

    // Get field label from field name
    getFieldLabel(fieldName) {
        const labelMap = {
            'Sub_Type__c': 'Sub Type',
            'Agency_Name__c': 'Agency Name',
            'Trade_License_Number__c': 'Trade License Number',
            'Company_Trade_License_Registration_Type__c': 'Company Trade License Registration Type',
            'Trade_License_Expiry_Date__c': 'Trade License Expiry Date',
            'Company_Email__c': 'Company Email',
            'Company_Official_Phone_No__c': 'Company Official Phone No',
            'First_Name__c': 'First Name',
            'Last_Name__c': 'Last Name',
            'Emirates_ID_Expiry_Date__c': 'Emirates ID Expiry Date',
            'Passport_No__c': 'Passport No',
            'Passport_Expiry_Date__c': 'Passport Expiry Date',
            'Email__c': 'Email',
            'Authorized_Signatory_Mobile__c':'Authorized Signatory Email',
            'Authorized_Signatory_Email__c':'Authorized Signatory Mobile',
            'Designation__c': 'Designation',
            'Emirates_No__c': 'Emirates ID Number',
            'Phone_No__c': 'Phone',
            'Bank_Document_Available__c': 'Bank Document Available',
            'Beneficiary_name_Account_Holder_Name__c': 'Beneficiary Name',
            'Type__c': 'Account Type',
            'Currency__c': 'Currency',
            'Bank_Account_Number__c': 'Bank Account Number'
        };
        
        return labelMap[fieldName] || fieldName.replace(/_/g, ' ').replace(/__c$/, '');
    }

    // Email validation
    isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    // Phone validation (basic)
    isValidPhone(phone) {
        // Remove spaces, dashes, parentheses
        const cleanedPhone = phone.replace(/[\s\-()]/g, '');
        // Check if it contains only digits and optional +
        return /^\+?\d+$/.test(cleanedPhone);
    }

    // Date validation
    isValidDate(dateString) {
        if (!dateString) return false;
        
        try {
            const date = new Date(dateString);
            return date instanceof Date && !isNaN(date);
        } catch (e) {
            return false;
        }
    }
    get stepErrorsText() {
    return this.stepErrors.join(', ');
}

closeSuccessModal() {
    this.showSuccessModal = false;
}

get fileValue() {
    if (this.isCorporate) {
        return this.agency?.Company_Email__c || '';
    }
    return this.agency?.Email__c || '';
}
goToStep1() {
    this.resetForm();          // form clear
    this.currentStep = 1;      // step 1
    this.updateStepPath();     // step UI update
    this.showSuccessModal = false;

    window.scrollTo(0, 0);
}
showDuplicatePopup(name, recordId, reason) {
    this.duplicateRecordName = name;
    this.duplicateRecordId = recordId;
    this.duplicateReason = reason;
    this.showDuplicateModal = true;
}


closeDuplicateModal() {
    this.showDuplicateModal = false;
}

get duplicateMessage() {
    if (this.duplicateReason === 'EMAIL') {
        return 'This broker is already registered with the same Email address.';
    }
    if (this.duplicateReason === 'TRADE_LICENSE') {
        return 'This broker is already registered  with the same Trade License Number.';
    }
    return 'Duplicate record found.';
}

async handleSubmit() {
        try {
            console.log('Submitting form...');
            
            // First, validate the current step (should be the last step)
           if (!this.validateCurrentStep()) {
                console.log('Current step validation failed');
                // Scroll to first error
                setTimeout(() => {
                    const firstError = this.template.querySelector('.slds-has-error');
                    if (firstError) {
                        firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    }
                }, 100);
                return;
            } 
            
            // Create a clean copy of agency data
            const agencyData = {...this.agency};
            
            // Log the Agency_Name__c value
            console.log('Agency_Name__c value:', agencyData.Agency_Name__c);
            
            // Remove the invalid Address__c field if it exists
            if (agencyData.Address__c) {
                console.log('Removing invalid field: Address__c');
                delete agencyData.Address__c;
            }
            
            // Format dates before sending
            const dateFields = ['Establishment_Date__c', 'Trade_License_Expiry_Date__c', 'Date_of_Birth__c'];
            dateFields.forEach(field => {
                if (agencyData[field]) {
                    const formattedDate = this.formatDateForApex(agencyData[field]);
                    if (formattedDate) {
                        agencyData[field] = formattedDate;
                    } else {
                        delete agencyData[field];
                    }
                }
            });
            
            // Clean up empty values
            Object.keys(agencyData).forEach(key => {
                const value = agencyData[key];
                if (value === undefined || value === '' || value === null) {
                    delete agencyData[key];
                }
            });
            
            console.log('Submitting clean data:', JSON.stringify(agencyData, null, 2));
            
            /* ===============================
   🔍 DUPLICATE CHECK (ADD HERE)
   =============================== */

const duplicateResult = await checkDuplicate({
    isIndividual: this.isIndividual,
    email: this.isIndividual ? agencyData.Email__c : null,
    tradeLicense: this.isCorporate ? agencyData.Trade_License_Number__c : null
});

if (duplicateResult.exists === 'true') {
    this.showDuplicatePopup(
        duplicateResult.recordName,
        duplicateResult.recordId,
        duplicateResult.reason 
    );
    return; //  STOP SAVE
}
            // Step 1: Create the Agency record
            const recordId = await createAgency({
                fieldValues: agencyData,
                recordTypeId: this.selectedRecordTypeId
            });
            
            console.log('Agency created with ID:', recordId);
           
            

this.showSuccessModal = true;

setTimeout(() => {
    this.goToStep1();
}, 5000); 

       
        } catch (error) {
            console.error('Submit Error:', error);
            console.error('Error body:', error.body);
            this.showToast('Error', error.body?.message || error.message || 'Unknown error', 'error');
        }
    }

    // Helper method to format date
    formatDateForApex(dateValue) {
        if (!dateValue) return null;
        
        try {
            const date = new Date(dateValue);
            if (isNaN(date.getTime())) return null;
            
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            
            return `${year}-${month}-${day}`;
        } catch (e) {
            console.error('Date formatting error:', e);
            return null;
        }
    }

   

  resetForm() {
    this.agency = {
        Status__c: 'New',
        Onboarding_Stage__c: 'Step 1 - Basic Details',
        Bank_Document_Available__c: 'No'
    };

    this.currentStep = 1;
    this.isBankDetailsVisible = false;

    //  VERY IMPORTANT FOR lightning-file-upload
    this.uploadedDocTypes = new Set();   // reset validation tracking
    this.fileNames = {};                 // clear shown file names
    this.createdRecordId = null;          // unlink file upload target
    this.visibleDocs = {};                // safe reset

    this.captchaInput = '';
    this.fieldErrors = {};

    this.switchToCorporate();
    window.scrollTo(0, 0);
}

    
//@track fileNames = {};   // Store filenames by type
    //@track uploadedFiles = [];

 documentRules = {

    "Dubai Real Estate Company (RERA Registered)": [
        "Trade license",
        "RERA Certificate",
        "Broker Card",
        //"TRN / VAT Declaration",
         //"VAT Certificate",   
       "Authorized Signatory Passport",
    "Authorized Signatory Visa",
    "Authorized Signatory Emirates ID",
       // "Share Owner's Passport Copy",
       // "Memorandum of Association(if available)",
        "Power of Attorney(if available)",
        "Bank / IBAN Letter"
    ],

    "Real Estate Company - other emirate": [
        "Trade license",
        "RERA Certificate (if available)",
        "Broker Card (if available)",
        //"TRN / VAT Declaration",
         //"VAT Certificate",   
        "Authorized Signatory Passport",
    "Authorized Signatory Visa",
    "Authorized Signatory Emirates ID",
       // "Share Owner's Passport Copy",
       // "Memorandum of Association(if available)",
        "Power of Attorney(if available)",
        "Bank / IBAN Letter"
    ],

    "UAE non real estate company": [
        "Trade license",
       // "TRN / VAT Declaration",
         //"VAT Certificate",   
        "Authorized Signatory Passport",
    "Authorized Signatory Visa",
    "Authorized Signatory Emirates ID",
       // "Share Owner's Passport Copy",
       // "Memorandum of Association(if available)",
        "Power of Attorney(if available)",
        "Bank / IBAN Letter",
        //"RERA Certificate (if available)",
       // "Broker Card (if available)"
    ],

    "International Company": [
        "Trade / Company License",
        "Authorized Signatory Passport",
       // "Share Owner's Passport Copy",
       // "Memorandum of Association(if available)",
        "Power of Attorney(if available)",
        "Bank / IBAN Letter"
    ],
    /* -------- INDIVIDUAL -------- */
    "UAE Residents": [
        "Passport Copy (Individual)",
        "Visa (Individual)",
        "EID (Individual)",
        "Bank Letter"
    ],

    "International": [
        "Passport Copy (Individual)",
        "National ID",
        "Bank Letter"
    ]
};


DOC_KEYS = {

    /* -------- INDIVIDUAL -------- */
    "Passport Copy (Individual)": "passportIndividual",
    "Visa (Individual)": "visaIndividual",
    "EID (Individual)": "eidIndividual",
    "National ID": "nationalId",
    "Bank Letter": "bankLetterIndividual",

    /* -------- CORPORATE -------- */
    "Trade license": "tradeLicense",
    "RERA Certificate": "reraCertificate",
    "RERA Certificate (if available)": "reraCertificateOptional",
    "Broker Card": "brokerCard",
    "Broker Card (if available)": "brokerCardOptional",

   "TRN / VAT Declaration": "trnVatDeclaration",

    
    "VAT Certificate": "vatCertificate",
   //  AUTHORIZED SIGNATORY (FIXED)
    "Authorized Signatory Passport": "authPassport",
    "Authorized Signatory Visa": "authVisa",
    "Authorized Signatory Emirates ID": "authEid",

    "Share Owner's Passport Copy": "shareOwnerPassport",
    "Memorandum of Association": "moa",

"Power of Attorney (if available)": "poa",

    "Bank / IBAN Letter": "bankIban",

    /* International */
    "Trade / Company License": "intlTradeLicense",
    //"Authorized Signatory Passport": "intlAuthPassport",
     "Bank NOC": "bankNoc"

};
renderDocumentStars() {

    const uploaders = this.template.querySelectorAll(
        'lightning-file-upload[data-doc-type]'
    );

    uploaders.forEach(uploader => {

        const doc = uploader.dataset.docType;
        if (!doc) return;

        // Find nearest document container
        const container = uploader.closest('.doc-box, .slds-col');
        if (!container) return;

        const star = container.querySelector('.doc-required-star');
        if (!star) return;

        if (this.isDocumentRequired(doc)) {
            star.textContent = '*';
        } else {
            star.textContent = '';
        }
    });
}
renderedCallback() {
    this.renderDocumentStars();
}


get canUploadFiles() {
    return !this.createdRecordId;
}

//Corporate getter
get showTradeLicense() { return this.visibleDocs["Trade license"]; }
get showRera() { return this.visibleDocs["RERA Certificate"]; }
get showReraOptional() { return this.visibleDocs["RERA Certificate (if available)"]; }
get showBrokerCard() { return this.visibleDocs["Broker Card"]; }
get showBrokerCardOptional() { return this.visibleDocs["Broker Card (if available)"]; }

get showVatCertificate() {
    return this.visibleDocs['VAT Certificate'];
}

get showtrnVatDeclaration() {
    return this.visibleDocs['TRN / VAT Declaration'];
}

get showAuthPassport() {
    return this.visibleDocs["Authorized Signatory Passport"];
}

get showAuthVisa() {
    return this.visibleDocs["Authorized Signatory Visa"];
}

get showAuthEid() {
    return this.visibleDocs["Authorized Signatory Emirates ID"];
}


get showShareOwner() { return this.visibleDocs["Share Owner's Passport Copy"]; }
get showMoa() { return this.visibleDocs["Memorandum of Association"]; }
get showPoa() { return this.visibleDocs["Power of Attorney(if available)"]; }
get showBankIban() {
    return this.visibleDocs['Bank / IBAN Letter'];
}

get shouldShowBankNoc() {
    return this.visibleDocs['Bank NOC'];
}

/* International type extras */
get showIntlTradeLicense() { return this.visibleDocs["Trade / Company License"]; }
get showIntlAuthPassport() { return this.visibleDocs["Authorized Signatory Passport"]; }


//Individual getter
get showPassportIndividual() {
    return this.visibleDocs["Passport Copy (Individual)"];
}

get showVisaIndividual() {
    return this.visibleDocs["Visa (Individual)"];
}

get showEidIndividual() {
    return this.visibleDocs["EID (Individual)"];
}

get showNationalId() {
    return this.visibleDocs["National ID"];
}

get showBankLetterIndividual() {
    return this.visibleDocs["Bank Letter"];
}


handleUploadFinished(event) {
    const uploadedFiles = event.detail.files;
    const docType = event.target.dataset.docType;

    if (!docType || !uploadedFiles?.length) {
        return;
    }

    // Mark doc as uploaded (for validation)
    this.uploadedDocTypes.add(docType);

    // Resolve key using DOC_KEYS
    const key = this.DOC_KEYS[docType];

    // Store filename (show under uploader)
    if (key) {
        this.fileNames = {
            ...this.fileNames,
            [key]: uploadedFiles.map(f => f.name).join(', ')
        };
    }

    // Clear validation error
    const clean = docType.replace(/[^a-zA-Z0-9]/g, '_');
    this.clearFieldError(clean);

    console.log('Uploaded:', docType, uploadedFiles);
    console.log('UPLOAD EVENT FIRED');
console.log('RecordId:', this.createdRecordId);
console.log('DocType:', docType);
console.log('UploadedDocTypes:', [...this.uploadedDocTypes]);

}

get tradeLicenseFileName() { return this.fileNames.tradeLicense; }
get reraCertificateFileName() { return this.fileNames.reraCertificate; }
get reraCertificateOptionalFileName() { return this.fileNames.reraCertificateOptional; }

get brokerCardFileName() { return this.fileNames.brokerCard; }
get brokerCardOptionalFileName() { return this.fileNames.brokerCardOptional; }

get vatCertificateFileName() {
    return this.fileNames.vatCertificate;
}
get bankNocFileName() {
    return this.fileNames.bankNoc;
}


get trnVatDeclarationFileName() {
    return this.fileNames.trnVatDeclaration;
}

get authPassportFileName() {
    return this.fileNames.authPassport;
}

get authVisaFileName() {
    return this.fileNames.authVisa;
}

get authEidFileName() {
    return this.fileNames.authEid;
}

get disableUploader() {
    return !!this.createdRecordId;
}

get shareOwnerPassportFileName() { return this.fileNames.shareOwnerPassport; }
get moaFileName() { return this.fileNames.moa; }
get poaFileName() { return this.fileNames.poa; }
get bankIbanFileName() { return this.fileNames.bankIban; }

get intlTradeLicenseFileName() { return this.fileNames.intlTradeLicense; }
//get intlAuthPassportFileName() { return this.fileNames.intlAuthPassport; }


get passportIndividualFileName() { return this.fileNames.passportIndividual; }
get visaIndividualFileName() { return this.fileNames.visaIndividual; }
get eidIndividualFileName() { return this.fileNames.eidIndividual; }
get nationalIdFileName() { return this.fileNames.nationalId; }
get bankLetterIndividualFileName() { return this.fileNames.bankLetterIndividual; }


    handleDownloadBankDocument() {
        this.showToast('Info', 'Download functionality to be implemented', 'info');
    }

    handleCaptchaChange(event) {
        this.captchaInput = event.target.value;
        // Clear captcha error when user starts typing
        this.clearFieldError('captchaInput');
    }

    handleRefreshCaptcha() {
        this.showToast('Info', 'Captcha refresh to be implemented', 'info');
    }

    async loadRecordData() {
        this.showToast('Info', 'Edit mode functionality to be implemented', 'info');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant,
            mode: 'dismissable'
        }));
    }
    
    // Debug method to see all loaded picklists
    debugPicklists() {
        console.log('=== LOADED PICKLIST FIELDS ===');
        Object.keys(this.picklistOptions).forEach(fieldName => {
            console.log(`${fieldName}:`, this.picklistOptions[fieldName]);
        });
        console.log('==============================');
    }

    get bankDocumentOptions() {
    if (this.picklistOptions && this.picklistOptions.Bank_Document_Available__c) {
        return this.picklistOptions.Bank_Document_Available__c.map(opt => {
            if (opt.value === 'Yes') {
                return { label: 'Available', value: 'Yes' };
            }
            if (opt.value === 'No') {
                return { label: 'No / Under Process', value: 'No' };
            }
            return opt;
        });
    }

    // fallback (safety)
    return [
        { label: 'Available', value: 'Yes' },
        { label: 'No / Under Process', value: 'No' }
    ];
}


    get customPicklistOptions() {
        return {
            accountType: this.picklistOptions.AccountTypeOptions || [],
            currency: this.picklistOptions.CurrencyOptions || [],
            bankBranch: this.picklistOptions.BankBranchOptions || [],
            country: this.picklistOptions.Country__c || [],   
            bankName: this.picklistOptions.BankNameOptions || [],
            yesNo: this.picklistOptions.YesNoOptions || [
                { label: 'Yes', value: 'Yes' },
                { label: 'No', value: 'No' }
            ]
        };
    }

    // Start confetti effect
startConfetti() {
    const confettiContainer = this.template.querySelector('.confetti-container');
    if (confettiContainer) {
        // Clear existing confetti
        confettiContainer.innerHTML = '';
        
        // Create confetti pieces
        for (let i = 0; i < 150; i++) {
            const confetti = document.createElement('div');
            confetti.className = 'confetti';
            confetti.style.left = Math.random() * 100 + '%';
            confetti.style.backgroundColor = this.getRandomColor();
            confetti.style.animationDelay = Math.random() * 3 + 's';
            confettiContainer.appendChild(confetti);
        }
        
        // Auto close after 5 seconds
        setTimeout(() => {
            this.closeSuccessModal();
        }, 5000);
    }
}

// Get random color for confetti
getRandomColor() {
    const colors = [
        '#FF6B6B', '#4ECDC4', '#FFD166', '#06D6A0', 
        '#118AB2', '#EF476F', '#FFD166', '#073B4C',
        '#7209B7', '#3A86FF', '#FB5607', '#8338EC'
    ];
    return colors[Math.floor(Math.random() * colors.length)];
}

// Close success modal and navigate to record
closeSuccessModal() {
    this.showSuccessModal = false;
    if (this.lastCreatedRecordId) {
        this.navigateToRecord(this.lastCreatedRecordId);
        this.resetForm();
    }
}

// Show error modal (optional, if you want to replace alert)
showErrorModal(title, message) {

    alert(title + ': ' + message);
}

}