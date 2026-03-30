public with sharing class miorahSalesOfferController {

    public Sales_Offer__c offer { get; set; }
    public List<InstallmentRow> installmentList { get; set; }
    public Integer totalRows { get; set; }
    public Date dealDate { get; set; }

    // ===== Payment Summary =====
    public Decimal downPaymentPercent { get; set; }
    public Decimal downPaymentAmount { get; set; }
    public Decimal dldPercent { get; set; }
    public Decimal dldAmount { get; set; }
    public Decimal adminFee { get; set; }
    public Decimal totalPaymentAmount { get; set; }
    
     public String projectName { get; set; }
     public String propertyName { get; set; } 
     public String recordOwnerName { get; set; }

    public miorahSalesOfferController() {

        Id recordId = ApexPages.currentPage().getParameters().get('id');
        if (recordId == null) return;

        offer = [
    SELECT Id, Name, Payment_Plan__c,
           Project__c,
           Project__r.Name,
           Property_Unit__c,
           Property_Unit__r.Name, 
           Type__c, Original_Price__c,
           Offer_Promotion__c, Net_Price__c,  Owner.Name
    FROM Sales_Offer__c
    WHERE Id = :recordId
    LIMIT 1
];


        dealDate = Date.today();

        Decimal baseAmount =
            offer.Net_Price__c != null
            ? offer.Net_Price__c
            : offer.Original_Price__c;

        adminFee = 3500;
        dldPercent = 4;
        dldAmount = (baseAmount * dldPercent / 100).setScale(2);
        
        
        projectName = offer.Project__r.Name;
        propertyName = offer.Property_Unit__r.Name;
         recordOwnerName  = offer.Owner.Name;
        
        
        installmentList = new List<InstallmentRow>();

        // =========================
        // PICKLIST → RULE MAPPING
        // =========================
        Map<Integer, Decimal> specialPercents = new Map<Integer, Decimal>();

        if (offer.Payment_Plan__c == 'Standard Payment Plan – 0% Discount') {
            totalRows = 58;
            downPaymentPercent = 20;
            specialPercents.put(1, 20);
        }
        else if (offer.Payment_Plan__c == '30% Down Payment – 4% Discount') {
            totalRows = 58;
            downPaymentPercent = 30;
            specialPercents.put(1, 30);
        }
        else if (offer.Payment_Plan__c == '50% Down Payment – 8% Discount') {
            totalRows = 58;
            downPaymentPercent = 50;
            specialPercents.put(1, 50);
        }
        else if (offer.Payment_Plan__c == '100% Down Payment (No ROI) – 20% Discount') {
            totalRows = 1;
            downPaymentPercent = 100;
        }
        else {
            totalRows = 58;
            downPaymentPercent = 20;
            specialPercents.put(1, 20);
        }

        // Common special installments
        if (totalRows > 1) {
            specialPercents.put(21, 10);       // 21st installment
            specialPercents.put(totalRows, 6); // last installment
        }

        downPaymentAmount =
            (baseAmount * downPaymentPercent / 100).setScale(2);

        totalPaymentAmount =
            downPaymentAmount + dldAmount + adminFee;

        // =========================
        // INSTALLMENT GENERATION
        // =========================
        Date startDate = dealDate.addMonths(1);

        for (Integer i = 1; i <= totalRows; i++) {

            Decimal percent;

            if (totalRows == 1) {
                percent = 100;
            }
            else if (specialPercents.containsKey(i)) {
                percent = specialPercents.get(i);
            }
            else {
                percent = 1;
            }

            Decimal amount =
                (baseAmount * percent / 100).setScale(2);

            installmentList.add(
                new InstallmentRow(
                    i,
                    startDate.addMonths(i - 1),
                    percent,
                    amount
                )
            );
        }
    }

    // ===== Wrapper =====
    public class InstallmentRow {
        public String label { get; set; }
        public Date milestoneDate { get; set; }
        public Decimal percent { get; set; }
        public Decimal amount { get; set; }

        public InstallmentRow(
            Integer index,
            Date d,
            Decimal p,
            Decimal a
        ) {
            label = 'Installment ' + index;
            milestoneDate = d;
            percent = p;
            amount = a;
        }
    }
}