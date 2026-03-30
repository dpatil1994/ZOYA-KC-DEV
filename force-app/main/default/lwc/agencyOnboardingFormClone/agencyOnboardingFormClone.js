import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import getRecordTypes from '@salesforce/apex/AgencyOnboardingControllerClone.getRecordTypes';
import getAllPicklistValues from '@salesforce/apex/AgencyOnboardingControllerClone.getAllPicklistValues';
import createAgency from '@salesforce/apex/AgencyOnboardingControllerClone.createAgency';
import uploadFiles from '@salesforce/apex/AgencyOnboardingControllerClone.uploadFiles';

import ZOYA_CAROUSEL from '@salesforce/resourceUrl/zoyaCarousel';

export default class AgencyOnboardingForm extends NavigationMixin(LightningElement) {

    /* ============================
       FORM DATA
       ============================ */
    @track agency = {
        // Default values
        Status__c: 'New',
        Onboarding_Stage__c: 'Step 1 - Basic Details',
        Bank_Document_Available__c: 'No'
    };
    @track uploadedFiles = {
        passportCopy: [],
        eidCopy: [],
        visaCopy: [],
        bankLetter: [],
        tradeLicense: [],
        chequeCopy: []
    };

@track showSuccessMessage = false;
@track lastCreatedRecordId = null;

    @track showTRNField = false;

    @track showPartnerField = false;

    @track isBankDetailsVisible = false;
       @track uploadedFiles = {};
    
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

    /* ============================
       VALIDATION STATE
       ============================ */
    @track fieldErrors = {}; // Track field-level errors
    @track captchaInput = ''; // Add captcha input tracking

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

handleFileUpload(event) {
        const key = event.target.dataset.docType;
        const files = Array.from(event.target.files);

        files.forEach((file, index) => {
            this.uploadedFiles[key].push({
                id: Date.now() + index,
                name: file.name,
                fileData: file
            });
        });

        this.uploadedFiles = { ...this.uploadedFiles }; // reactive update

        console.log('Uploaded Files:', JSON.stringify(this.uploadedFiles));
    }
    handleChange(event) {
    const { name, value } = event.target;
    this.agency = { ...this.agency, [name]: value || null };

    // 🔥 Ownership → Show/Hide Number_of_Partners__c
    if (name === 'ownership__c') {
        this.showPartnerField = (value === 'Partnership');

        // Hide होने पर value clear कर दें
        if (!this.showPartnerField) {
            this.agency = { 
                ...this.agency, 
                Number_of_Partners__c: null 
            };
        }
    }
    // Show/Hide TRN field based on picklist
if (name === 'have_trn__c') {
    this.showTRNField = (value === 'Yes');

    // Hide होने पर TRN Number clear कर दें
    if (!this.showTRNField) {
        this.agency = {
            ...this.agency,
            TRN_Number__c: null
        };
    }
}


    // Bank details visibility
    if (name === 'Bank_Document_Available__c') {
        this.isBankDetailsVisible = value === 'Yes';
    }

    // Clear field error when user starts typing
    if (this.fieldErrors[name]) {
        this.fieldErrors = { ...this.fieldErrors, [name]: null };
        this.clearFieldError(name);
    }

    console.log(`Field changed: ${name} = ${value}`);
}


    handleCorporateSelect(event) {
        event.preventDefault();
        this.switchToCorporate();
    }

    handleIndividualSelect(event) {
        event.preventDefault();
        this.switchToIndividual();
    }

    switchToCorporate() {
        this.isCorporate = true;
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

    handleNext() {
        if (this.validateCurrentStep()) {
            const maxSteps = this.isCorporate ? 4 : 3;
            if (this.currentStep < maxSteps) {
                this.currentStep++;
                this.updateStepPath();
                window.scrollTo(0, 0);
            }
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
        const requiredFields = [
            'Agency_Sub_Type__c',
            'Agency_Name__c',
            'Trade_License_Number__c',
            'Company_Trade_License_Registration_Type__c',
            'Trade_License_Expiry_Date__c',
            'Company_Email__c',
            'Company_Official_Phone_No__c'
        ];
        
        return this.validateFields(requiredFields);
    }

    // Corporate Step 2 Validation
    validateCorporateStep2() {
        const requiredFields = [
            'First_Name__c',
            'Last_Name__c',
            'Emirates_ID_Expiry_Date__c',
            'Passport_No__c',
            'Passport_Expiry_Date__c',
            'Email__c',
            'Designation__c',
            'Emirates_Id_number__c',
            'Phone__c'
        ];
        
        return this.validateFields(requiredFields);
    }

    // Corporate Step 3 Validation
    validateCorporateStep3() {
        let isValid = true;
        
        // Bank Document Available is required
        if (!this.agency.Bank_Document_Available__c) {
            this.showFieldError('Bank_Document_Available__c', 'Please select if Bank Document is Available');
            isValid = false;
        }
        
        // If bank document is available, validate bank details
        if (this.isBankDetailsVisible) {
            const bankRequiredFields = [
                'Beneficiary_Name__c',
                'Type__c',
                'Currency__c',
                'Bank_Account_Number__c'
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
        
        // Check if all required documents are uploaded
        const requiredDocTypes = [
            'Passport Copy (Authorized Signatory)',
            'EID (Authorized Signatory)',
            'Visa (Authorized Signatory)',
            'Bank Letter',
            'Cancelled Cheque Copy'
        ];
        
        // Check uploaded files
        const uploadedDocTypes = this.uploadedFiles.map(file => file.docType);
        
        for (const docType of requiredDocTypes) {
            if (!uploadedDocTypes.includes(docType)) {
                // Show error on the file upload field using a sanitized field name
                const sanitizedFieldName = docType.replace(/[^a-zA-Z0-9]/g, '_');
                this.showFieldError(sanitizedFieldName, `Please upload ${docType}`);
                isValid = false;
            }
        }
        
        // Check captcha - only if we're on the last step and trying to submit
        const captchaInputElement = this.template.querySelector('[name="captchaInput"]');
        if (captchaInputElement && (!this.captchaInput || this.captchaInput.trim() === '')) {
            this.showFieldError('captchaInput', 'Please enter captcha code');
            isValid = false;
        }
        
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

    // Individual Step 1 Validation
    validateIndividualStep1() {
        const requiredFields = [
            'First_Name__c',
            'Last_Name__c',
            'Email__c',
            'Phone__c'
        ];
        
        return this.validateFields(requiredFields);
    }

    // Individual Step 2 Validation
    validateIndividualStep2() {
        let isValid = true;
        
        // Bank Document Available is required
        if (!this.agency.Bank_Document_Available__c) {
            this.showFieldError('Bank_Document_Available__c', 'Please select if Bank Document is Available');
            isValid = false;
        }
        
        // If bank document is available, validate bank details
        if (this.isBankDetailsVisible) {
            const bankRequiredFields = [
                'Beneficiary_Name__c',
                'Type__c',
                'Currency__c',
                'Bank_Account_Number__c'
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
        
        // Check if all required documents are uploaded
        const requiredDocTypes = [
            'Passport Copy (Individual)',
            'EID (Individual)',
            'Visa (Individual)',
            'Bank Letter',
            'Cancelled Cheque Copy'
        ];
        
        // Check uploaded files
        const uploadedDocTypes = this.uploadedFiles.map(file => file.docType);
        
        for (const docType of requiredDocTypes) {
            if (!uploadedDocTypes.includes(docType)) {
                // Show error on the file upload field using a sanitized field name
                const sanitizedFieldName = docType.replace(/[^a-zA-Z0-9]/g, '_');
                this.showFieldError(sanitizedFieldName, `Please upload ${docType}`);
                isValid = false;
            }
        }
        
        // Check captcha - only if we're on the last step and trying to submit
        const captchaInputElement = this.template.querySelector('[name="captchaInput"]');
        if (captchaInputElement && (!this.captchaInput || this.captchaInput.trim() === '')) {
            this.showFieldError('captchaInput', 'Please enter captcha code');
            isValid = false;
        }
        
        return isValid;
    }

    // Generic field validation helper
    validateFields(fieldNames) {
        let isValid = true;
        
        for (const fieldName of fieldNames) {
            const value = this.agency[fieldName];
            
            if (!value || (typeof value === 'string' && value.trim() === '')) {
                this.showFieldError(fieldName, `${this.getFieldLabel(fieldName)} is required`);
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
            'Agency_Sub_Type__c': 'Agency Sub Type',
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
            'Designation__c': 'Designation',
            'Emirates_Id_number__c': 'Emirates ID Number',
            'Phone__c': 'Phone',
            'Bank_Document_Available__c': 'Bank Document Available',
            'Beneficiary_Name__c': 'Beneficiary Name',
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
            
            // Step 1: Create the Agency record
            const recordId = await createAgency({
                fieldValues: agencyData,
                recordTypeId: this.selectedRecordTypeId
            });
            
            console.log('Agency created with ID:', recordId);
            
            // Step 2: Upload files if any
            if (this.uploadedFiles.length > 0) {
                console.log('Uploading', this.uploadedFiles.length, 'files...');
                
                // Prepare files data for upload
                const filesToUpload = await this.prepareFilesForUpload(recordId);
                
                if (filesToUpload.length > 0) {
                    // Call Apex to upload files
                    await uploadFiles({
                        recordId: recordId,
                        filesData: filesToUpload
                    });
                    
                    console.log('Files uploaded successfully');
                    this.showToast('Success', `Agency created and ${filesToUpload.length} files uploaded successfully!`, 'success');
                } else {
                    this.showToast('Success', `Agency created successfully!`, 'success');
                }
            } else {
                this.showToast('Success', `Agency created successfully!`, 'success');
            }
            
            this.showSuccessMessage = true;

            this.navigateToRecord(recordId);
            this.resetForm();
            
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

    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    resetForm() {
        this.agency = {
            Status__c: 'New',
            Onboarding_Stage__c: 'Step 1 - Basic Details',
            Bank_Document_Available__c: 'No'
        };
        this.currentStep = 1;
        this.isBankDetailsVisible = false;
        this.uploadedFiles = [];
        this.captchaInput = '';
        this.fieldErrors = {};
        this.switchToCorporate();
    }

    async handleFileUpload(event) {
        try {
            const file = event.target.files[0];
            const docType = event.target.dataset.docType;
            
            if (file) {
                // Check file size (max 5MB)
                if (file.size > 5 * 1024 * 1024) {
                    this.showToast('Error', `File "${file.name}" exceeds 5MB limit`, 'error');
                    return;
                }
                
                // Check file type
                const allowedTypes = ['application/pdf', 'application/msword', 
                                     'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                                     'application/vnd.ms-powerpoint',
                                     'application/vnd.openxmlformats-officedocument.presentationml.presentation'];
                
                if (!allowedTypes.includes(file.type)) {
                    this.showToast('Error', `File "${file.name}" has invalid format. Allowed: PDF, DOC, DOCX, PPT, PPTX`, 'error');
                    return;
                }
                
                // Read file as base64
                const base64Data = await this.readFileAsBase64(file);
                
                // Add to uploadedFiles
                this.uploadedFiles.push({
                    name: file.name,
                    type: file.type,
                    size: file.size,
                    docType: docType,
                    file: file,
                    base64Data: base64Data
                });
                
                // Clear any error for this document type
                const sanitizedFieldName = docType.replace(/[^a-zA-Z0-9]/g, '_');
                this.clearFieldError(sanitizedFieldName);
                
                console.log(`File "${file.name}" uploaded for ${docType}`);
                
                // Reset the file input
                event.target.value = '';
            }
        } catch (error) {
            console.error('Error uploading file:', error);
            this.showToast('Error', 'Failed to upload file', 'error');
        }
    }

    // Helper method to read file as base64
    readFileAsBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => {
                // Remove data URL prefix (e.g., "data:application/pdf;base64,")
                const base64 = reader.result.split(',')[1];
                resolve(base64);
            };
            reader.onerror = reject;
            reader.readAsDataURL(file);
        });
    }

    // Prepare files data for Apex upload
    async prepareFilesForUpload(recordId) {
        const filesData = [];
        
        for (const fileData of this.uploadedFiles) {
            filesData.push({
                name: fileData.name,
                type: fileData.type,
                size: fileData.size,
                docType: fileData.docType,
                base64Data: fileData.base64Data,
                recordId: recordId
            });
        }
        
        return filesData;
    }
    

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
            return this.picklistOptions.Bank_Document_Available__c;
        }
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }

    get customPicklistOptions() {
        return {
            accountType: this.picklistOptions.AccountTypeOptions || [],
            currency: this.picklistOptions.CurrencyOptions || [],
            bankBranch: this.picklistOptions.BankBranchOptions || [],
            country: this.picklistOptions.CountryOptions || [],
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
    // You can implement an error modal similar to success modal
    // For now, just show an alert
    alert(title + ': ' + message);
}






}