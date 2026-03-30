public with sharing class CustomerCashReceiptController {

    /* ===== Public properties for VF binding ===== */
    public String customerName { get; set; }       // Client Name
    public String customerEmail { get; set; }      // Account Email
    public String customerPhone { get; set; }      // Account Phone
    public String projectName { get; set; }
    public String unitName { get; set; }
    public String receiptName { get; set; }
    public String receiptDate { get; set; }
    public String receiptAmount { get; set; }
    public String appliedAmount { get; set; }
    public String receiptMethod { get; set; }
    public String chequeNumber { get; set; }
    public String chequeDate { get; set; }
    public String bankAccount { get; set; }
    public String bankTransactionNumber { get; set; }
    public String remarks { get; set; }

    // Record Created Date
    public Date recDate { get; set; }
    public String officerUser { get; set; }
    public String modeOfPayment { get; set; }

    /* ===== Constructor ===== */
    public CustomerCashReceiptController() {
        Id receiptId = 'a08WE00000lJ4uTYAS';
        if (receiptId != null) {
            loadReceipt(receiptId);
        }
    }

    /* ===== Load Receipt & populate get/set variables ===== */
    private void loadReceipt(Id receiptId) {

        Receipt__c r = [
            SELECT
                Name,
                CreatedDate,
                CreatedBy.Name,
                Mode_of_Payment__c,
                Receipt_Date__c,
                Receipt_Amount__c,
                Applied_Amount__c,
                Receipt_Method__c,
                Cheque_Number__c,
                Cheque_Date__c,
                BT_Bank_Account__c,
                Bank_Transaction_Number__c,
                Remarks__c,
                Customer_Name__r.Id,
                Customer_Name__r.Name,
                Customer_Name__r.Email__c,
                Customer_Name__r.Phone,
                Project__r.Name,
                Customer_Unit__r.Name
            FROM Receipt__c
            WHERE Id = :receiptId
            LIMIT 1
        ];

        // Basic Receipt Info
        receiptName = r.Name;
        receiptDate = r.Receipt_Date__c != null ? String.valueOf(r.Receipt_Date__c) : '';
        receiptAmount = r.Receipt_Amount__c != null ? String.valueOf(r.Receipt_Amount__c) : '0';
        appliedAmount = r.Applied_Amount__c != null ? String.valueOf(r.Applied_Amount__c) : '0';
        receiptMethod = r.Receipt_Method__c;
        chequeNumber = r.Cheque_Number__c;
        chequeDate = r.Cheque_Date__c != null ? String.valueOf(r.Cheque_Date__c) : '';
        bankAccount = r.BT_Bank_Account__c;
        bankTransactionNumber = r.Bank_Transaction_Number__c;
        remarks = r.Remarks__c;

        projectName = r.Project__r != null ? r.Project__r.Name : '';
        unitName = r.Customer_Unit__r != null ? r.Customer_Unit__r.Name : '';

        // Customer Info (Lookup)
        if (r.Customer_Name__r != null) {
            customerName = r.Customer_Name__r.Name;      // Client Name
            customerEmail = r.Customer_Name__r.Email__c;    // Email
            customerPhone = r.Customer_Name__r.Phone;    // Phone
        } else {
            customerName = '';
            customerEmail = '';
            customerPhone = '';
        }

        // Other Info
        recDate = r.CreatedDate != null ? r.CreatedDate.date() : null;
        officerUser = r.CreatedBy != null ? r.CreatedBy.Name : '';
        modeOfPayment = r.Mode_of_Payment__c != null ? r.Mode_of_Payment__c : '';
        //receptAmount r.Receipt_Amount__c != null ? r.Receipt_Amount__c : '';
    }
}