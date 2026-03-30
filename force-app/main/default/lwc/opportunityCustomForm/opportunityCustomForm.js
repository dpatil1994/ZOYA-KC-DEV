import { LightningElement, api, track } from 'lwc';
import getPropertyUnits from '@salesforce/apex/OpportunityBookingController.getPropertyUnits';
import saveOpportunity from '@salesforce/apex/OpportunityBookingController.saveOpportunity';
import { NavigationMixin } from 'lightning/navigation';

export default class OpportunityBookingForm extends NavigationMixin(LightningElement) {

    @api recordId;
    todayDate = new Date().toISOString().split('T')[0];

    @track propertyUnitOptions = [];
    selectedUnit;
    disableUnit = true;

    handlePropertyChange(event) {
        const propertyId = event.detail.value;
        this.disableUnit = false;

        getPropertyUnits({ propertyId })
            .then(result => {
                this.propertyUnitOptions = result.map(unit => ({
                    label: unit.Name,
                    value: unit.Id
                }));
            });
    }

    handleUnitChange(event) {
        this.selectedUnit = event.detail.value;
    }

    handleSave() {
        const opp = {};
        this.template.querySelectorAll('lightning-input-field')
            .forEach(f => opp[f.fieldName] = f.value);

        opp.CloseDate = this.todayDate;

        saveOpportunity({
            opp: opp,
            propertyUnitId: this.selectedUnit
        }).then(id => {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: id,
                    objectApiName: 'Opportunity',
                    actionName: 'view'
                }
            });
        });
    }

    handleCancel() {
        window.history.back();
    }
}