import { LightningElement, track, wire } from 'lwc';
import getProjects from '@salesforce/apex/PropertyUnitController.getProjects';
import getInventory from '@salesforce/apex/PropertyUnitController.getInventory';
import createSalesOffer from '@salesforce/apex/PropertyUnitController.createSalesOffer';
import { NavigationMixin } from 'lightning/navigation';

import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import PROPERTY_UNIT_OBJECT from '@salesforce/schema/Property_Unit__c';
import UNIT_TYPE_FIELD from '@salesforce/schema/Property_Unit__c.Unit_Type__c';
import VIEW_TYPE_FIELD from '@salesforce/schema/Property_Unit__c.View_Type__c';

import SALES_OFFER_OBJECT from '@salesforce/schema/Sales_Offer__c';
import PAYMENT_PLAN_FIELD from '@salesforce/schema/Sales_Offer__c.Payment_Plan__c';

export default class PropertyInventory extends NavigationMixin(LightningElement) {

    /* ================= FILTERS ================= */
    projectId;
    floor;
    unitType;
    viewType;

    /* ================= DATA ================= */
    @track inventory = [];
    @track projectOptions = [];
    @track unitTypeOptions = [];
    @track viewTypeOptions = [];
    @track paymentPlanOptions = [];
isLoading = false;
    selectedRows = [];
    showTable = false;

    /* ================= MODAL ================= */
    showOfferModal = false;
    selectedUnit;
    paymentPlan;
    salesOfferId;

    isSaving = false;
    isOfferCreated = false;
    successMessage;

    /* ================= TABLE ================= */
    columns = [
        { label: 'Project', fieldName: 'projectName' },
        { label: 'Unit No', fieldName: 'Name' },
        { label: 'Floor', fieldName: 'Level__c' },
        { label: 'Unit Type', fieldName: 'Unit_Type__c' },
        { label: 'View', fieldName: 'View_Type__c' },
        { label: 'Price', fieldName: 'Original_Price__c', type: 'currency' },
         {label: 'Total Area (Sq Ft)',fieldName: 'Total_Area_Sq_ft__c',type: 'number'}
    ];

    /* ================= WIRES ================= */
    @wire(getProjects)
wiredProjects({ data }) {
    if (data) {
        this.projectOptions = [
            { label: 'None', value: '' },   // 🔥 added
            ...data.map(p => ({
                label: p.Name,
                value: p.Id
            }))
        ];
    }
}

    @wire(getObjectInfo, { objectApiName: PROPERTY_UNIT_OBJECT })
    unitObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$unitObjectInfo.data.defaultRecordTypeId',
        fieldApiName: UNIT_TYPE_FIELD
    })
    wiredUnitType({ data }) {
    if (data) {
        this.unitTypeOptions = [
            { label: 'None', value: '' },   // 🔥 added
            ...data.values
        ];
    }
}

    @wire(getPicklistValues, {
        recordTypeId: '$unitObjectInfo.data.defaultRecordTypeId',
        fieldApiName: VIEW_TYPE_FIELD
    })
    wiredViewType({ data }) {
    if (data) {
        this.viewTypeOptions = [
            { label: 'None', value: '' },   // 🔥 added
            ...data.values
        ];
    }
}

    @wire(getObjectInfo, { objectApiName: SALES_OFFER_OBJECT })
    salesOfferObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$salesOfferObjectInfo.data.defaultRecordTypeId',
        fieldApiName: PAYMENT_PLAN_FIELD
    })
    wiredPaymentPlan({ data }) {
        if (data) this.paymentPlanOptions = data.values;
    }

    /* ================= FILTER HANDLERS ================= */
  handleProjectChange(e) {
    const value = e.detail.value;
    this.projectId = value === '' ? null : value;
}
    handleFloorChange(e) { this.floor = e.detail.value; }
    handleUnitTypeChange(e) { this.unitType = e.detail.value; }
    handleViewTypeChange(e) { this.viewType = e.detail.value; }

   loadInventory() {
    this.isLoading = true;   // 🔥 START loader (YAHAN)

    getInventory({
        projectId: this.projectId,
        floor: this.floor,
        unitType: this.unitType,
        viewType: this.viewType
    })
    .then(result => {
        this.inventory = result.map(r => ({
            ...r,
            projectName: r.Property__r ? r.Property__r.Name : ''
        }));
        this.selectedRows = [];
        this.showTable = true;
    })
    .catch(error => {
        console.error('Error loading inventory', error);
    })
    .finally(() => {
        this.isLoading = false;   // 🔥 STOP loader (YAHAN)
    });
}

    handleRowSelection(e) {
        this.selectedRows = e.detail.selectedRows;
    }

    get isNoSelection() {
        return this.selectedRows.length === 0;
    }

    /* ================= SALES OFFER FLOW ================= */
    generateOffer() {
        this.selectedUnit = this.selectedRows[0];
        this.showOfferModal = true;
    }

    handlePaymentPlanChange(e) {
        this.paymentPlan = e.detail.value;
    }

    get isFormDisabled() {
        return this.isSaving || this.isOfferCreated;
    }

    get isSaveDisabled() {
        return !this.paymentPlan || this.isSaving || this.isOfferCreated;
    }

    get isGenerateDisabled() {
        return !this.isOfferCreated;
    }

    saveSalesOffer() {
        this.isSaving = true;

        createSalesOffer({
            unitId: this.selectedUnit.Id,
            paymentPlan: this.paymentPlan
        })
        .then(id => {
            this.salesOfferId = id;
            this.isOfferCreated = true;
            this.successMessage =
                'Sales Offer created successfully. Now you can generate Sales Offer.';
        })
        .finally(() => {
            this.isSaving = false;
        });
    }

    generatePdf() {
        window.open(
            '/apex/SalesOfferProjectBasedPDF?id=' + this.salesOfferId,
            '_blank'
        );
    }

    closeModal() {
        this.showOfferModal = false;
        this.paymentPlan = null;
        this.salesOfferId = null;
        this.successMessage = null;
        this.isSaving = false;
        this.isOfferCreated = false;
    }

    /* ================= BOOK UNIT (OVERRIDE SAFE) ================= */
    bookUnit() {
    const unit = this.selectedRows[0];

    this[NavigationMixin.Navigate]({
        type: 'standard__component',
        attributes: {
            componentName: 'c__OpportunityCreateEdit'
        },
        state: {
            c__propertyUnitId: unit.Id,
            c__projectId: unit.Property__c,
             c__returnTo: 'inventory',
             c__ts: Date.now() 
        }
    });
}
resetFilter() {
    // 🔹 Reset filter values
    this.projectId = null;
    this.floor = null;
    this.unitType = null;
    this.viewType = null;

    // 🔹 Reset table data
    this.inventory = [];
    this.selectedRows = [];
    this.showTable = false;
}
    /* ================= UI HELPERS ================= */
    get formContainerClass() {
        return this.isFormDisabled ? 'slds-opacity_50' : '';
    }
}