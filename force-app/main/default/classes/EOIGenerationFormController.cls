public class EOIGenerationFormController {

    // EOI fields
    public String clientEmail { get; set; }
    public String projectName { get; set; }
    public Decimal eoiAmount { get; set; }
    public Date eoiDate { get; set; }

    // Buyer fields
    public String billingStreet { get; set; }
    public String billingCity { get; set; }
    public String billingCountry { get; set; }
    public String passportNo { get; set; }
    public String personMobile { get; set; }
    public String phone { get; set; }
    public String nationality { get; set; }
    public String emiratesNo { get; set; }
    public String internationalBrokerType { get; set; }
    public String BuyerName { get; set; }

    public EOIGenerationFormController() {

        eoiDate = Date.today();

        //Id eoiId = ApexPages.currentPage().getParameters().get('id');
        Id eoiId = 'a06WE00000efiajYAA';
        
        if(eoiId != null) {
            loadEOI(eoiId);
        }
    }

    private void loadEOI(Id eoiId) {

        System.debug('EOI Id: ' + eoiId);

        Expression_of_Interest__c eoi = [
            SELECT 
                Client_Email__c,
                Project_Name__r.Name,
                EOI_Amount__c,
                CreatedDate,

                /* Buyer (Person Account) fields */
                Buyer__r.BillingStreet,
                Buyer__r.BillingCity,
                Buyer__r.BillingCountry,
                Buyer__r.FirstName,
                Buyer__r.LastName,
                Buyer__r.PersonEmail,
                Buyer__r.PersonMobilePhone,
                Buyer__r.Phone,
                Buyer__r.Passport_No__pc,
                Buyer__r.Nationality__pc,
                Buyer__r.Emirates_No__pc,
                Buyer__r.International_Type_Of_Broker__c

            FROM Expression_of_Interest__c
            WHERE Id = :eoiId
            LIMIT 1
        ];

        System.debug('EOI Query Result: ' + eoi);

        // EOI fields
        clientEmail = eoi.Client_Email__c;
        projectName = eoi.Project_Name__r != null ? eoi.Project_Name__r.Name : '';
        eoiAmount = eoi.EOI_Amount__c != null ? eoi.EOI_Amount__c : 0;
        eoiDate = Date.valueOf(eoi.CreatedDate);

        // Buyer fields
        if (eoi.Buyer__r != null) {
            billingStreet = eoi.Buyer__r.BillingStreet;
            billingCity = eoi.Buyer__r.BillingCity;
            billingCountry = eoi.Buyer__r.BillingCountry;

            passportNo = eoi.Buyer__r.Passport_No__pc;
            personMobile = eoi.Buyer__r.PersonMobilePhone;
            phone = eoi.Buyer__r.Phone;
            nationality = eoi.Buyer__r.Nationality__pc;
            emiratesNo = eoi.Buyer__r.Emirates_No__pc;
            internationalBrokerType = eoi.Buyer__r.International_Type_Of_Broker__c;

            // Name
            BuyerName = eoi.Buyer__r.FirstName + ' ' + eoi.Buyer__r.LastName;

            // Email (Person Account)
            clientEmail = eoi.Buyer__r.PersonEmail;
        }
    }

    public String getFormattedEOIDate() {
        return eoiDate != null ? eoiDate.format() : '';
    }
}