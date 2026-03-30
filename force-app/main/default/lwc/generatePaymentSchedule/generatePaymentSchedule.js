import { LightningElement, api } from 'lwc';
import generateSchedule from '@salesforce/apex/PaymentScheduleService.generateSchedule';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class GeneratePaymentSchedule extends LightningElement {
    @api recordId;
    isLoading = false;
    showSpinner = false;

    // Method called when Generate Schedule button is clicked
    handleGenerateSchedule() {
        if (!this.recordId) {
            this.showToast('Error', 'Record ID is not available. Please try again.', 'error');
            return;
        }

        this.isLoading = true;
        this.showSpinner = true;

        // Call Apex method
        generateSchedule({ salesOfferId: this.recordId })
            .then(() => {
                this.showToast('Success', 'Payment Schedule generated successfully!', 'success');
                
                // Close the Quick Action modal
                this.closeActionModal();
                
                // Optional: Refresh the page after 2 seconds
                setTimeout(() => {
                    this.refreshPage();
                }, 2000);
            })
            .catch(error => {
                let errorMessage = 'An error occurred while generating payment schedule.';
                
                if (error && error.body) {
                    if (error.body.message) {
                        errorMessage = error.body.message;
                    }
                }
                
                this.showToast('Error', errorMessage, 'error');
            })
            .finally(() => {
                this.isLoading = false;
                this.showSpinner = false;
            });
    }

    // Method called when Cancel button is clicked
    handleCancel() {
        // Close the Quick Action modal without doing anything
        this.closeActionModal();
    }

    // Method to close the Quick Action modal
    closeActionModal() {
        // THIS IS THE CORRECT WAY TO CLOSE QUICK ACTION MODAL
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    // Method to refresh the page
    refreshPage() {
        // Method 1: Refresh the current page
        window.location.reload();
        
        // OR Method 2: Dispatch event to parent to refresh related list
        // const refreshEvent = new CustomEvent('refresh');
        // this.dispatchEvent(refreshEvent);
    }

    // Method to show toast messages
    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }
}