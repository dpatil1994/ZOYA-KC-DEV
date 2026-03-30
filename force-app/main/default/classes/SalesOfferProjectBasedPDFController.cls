public with sharing class SalesOfferProjectBasedPDFController {

    /* ================= COMMON ================= */
    public Sales_Offer__c offer { get; set; }
    public String projectName { get; set; }
    public String propertyName { get; set; }
    public String recordOwnerName { get; set; }
    public Date dealDate { get; set; }

    public Boolean isMiorahProject { get; set; }
    public Boolean isZoyaProject { get; set; }

    /* ================= PAYMENT SUMMARY ================= */
    public Decimal downPaymentPercent { get; set; }
    public Decimal downPaymentAmount { get; set; }
    public Decimal dldAmount { get; set; }
    public Decimal adminFee { get; set; }
    public Decimal totalPaymentAmount { get; set; }
    
    public String propertyUnitType { get; set; }
     public Date offerDate { get; set; } 
    public String propertyUnitName { get; set; } 
   public Decimal propertyTotalAmount { get; set; } 
    
    public Decimal toalAreaSq { get; set; }
    public Decimal originlAmounts { get; set; }
    public Decimal netPrice { get; set; } 

    /* ================= INSTALLMENTS ================= */
    public Integer totalRows { get; set; }
    public List<InstallmentRow> installmentList { get; set; }

    /* ===================================================
        REQUIRED CONSTRUCTOR (DO NOT CHANGE SIGNATURE)
       =================================================== */
   public SalesOfferProjectBasedPDFController(
    ApexPages.StandardController controller
) {

    Id recordId = controller.getId();
    if (recordId == null) return;

    offer = [
        SELECT Id, Name,
               Payment_Plan__c,
               Project__r.Name,
               Property_Unit__r.Name,
               Type__c,
               Original_Price__c,
               Net_Price__c,
               Offer_Promotion__c,
               Owner.Name,
        Property_Unit__r.Total_Area_Sq_ft__c
        FROM Sales_Offer__c
        WHERE Id = :recordId
        LIMIT 1
    ];

    /* ===== BASIC ===== */
    projectName = offer.Project__r.Name;
    propertyName = offer.Property_Unit__r.Name;
	recordOwnerName = UserInfo.getName();
    dealDate = Date.today();
    propertyUnitType = offer.Type__c;
    toalAreaSq = offer.Property_Unit__r.Total_Area_Sq_ft__c;
    originlAmounts = offer.Original_Price__c;
    netPrice = offer.Net_Price__c;

    isMiorahProject =
        projectName != null &&
        projectName.toLowerCase().contains('miorah');

    isZoyaProject = !isMiorahProject;

    Decimal baseAmount =
        offer.Net_Price__c != null
        ? offer.Net_Price__c
        : offer.Original_Price__c;

    /* ===== FEES ===== */
    adminFee = 3500;
    dldAmount = (baseAmount * 4 / 100).setScale(2);

    installmentList = new List<InstallmentRow>();
    Map<Integer, Decimal> specialPercents = new Map<Integer, Decimal>();

    /* =====================================================
       🔥 PAYMENT PLAN RULES (MIORAH + NUVE BY ZOYA)
       ===================================================== */

  if (isMiorahProject) {

    // ---------- MIORAH LOGIC ----------
    if (offer.Payment_Plan__c == '100% Down Payment (No ROI) – 20% Discount') {

        totalRows = 1;
        downPaymentPercent = 100;

    } else {

        // 🔥 NEW: dynamic rows per plan
        if (offer.Payment_Plan__c == 'Standard Payment Plan – 0% Discount') {
            totalRows = 58;
            downPaymentPercent = 20;
        }
        else if (offer.Payment_Plan__c == '30% Down Payment – 4% Discount') {
            totalRows = 48;          // 🔥 changed
            downPaymentPercent = 30;
        }
        else if (offer.Payment_Plan__c == '50% Down Payment – 8% Discount') {
            totalRows = 28;          // 🔥 changed
            downPaymentPercent = 50;
        }
        else {
            totalRows = 58;          // safe default
            downPaymentPercent = 20;
        }

        // ===============================
        // MIORAH SPECIAL INSTALLMENTS
        // ===============================

        // 1st row → Down Payment
        specialPercents.put(1, downPaymentPercent);

        // 12th row → 10% (ONLY for these 3 plans)
        if (
            offer.Payment_Plan__c == 'Standard Payment Plan – 0% Discount' ||
            offer.Payment_Plan__c == '30% Down Payment – 4% Discount' ||
            offer.Payment_Plan__c == '50% Down Payment – 8% Discount'
        ) {
            specialPercents.put(12, 10);
        }

        // 21st row → 10%
        specialPercents.put(21, 10);

        // 🔥 Last row → 6% (dynamic now)
        specialPercents.put(totalRows, 6);
    }
} else {

        // ---------- NUVE BY ZOYA (EXISTING LOGIC) ----------
        if (offer.Payment_Plan__c == 'Standard Payment Plan – 0% Discount') {
            totalRows = 69;
            downPaymentPercent = 20;
            
            specialPercents.put(1, 10);
            specialPercents.put(2, 10);
        }
        else if (offer.Payment_Plan__c == '30% Down Payment – 4% Discount') {
            totalRows = 58;
            downPaymentPercent = 30;
            specialPercents.put(1, 30);
        }
        else if (offer.Payment_Plan__c == '50% Down Payment – 8% Discount') {
            totalRows = 38;
            downPaymentPercent = 50;
            specialPercents.put(1, 50);
        }
        else if (offer.Payment_Plan__c == '100% Down Payment (No ROI) – 20% Discount') {
            totalRows = 1;
            downPaymentPercent = 100;
        }
        else {
            totalRows = 69;
            downPaymentPercent = 0;
        }
    

        // Nuve special rows
        if (totalRows > 1) {
            specialPercents.put(30, 10);
            specialPercents.put(totalRows, 5);
        }
    }

    /* ===== PAYMENT SUMMARY ===== */
    downPaymentAmount =
        (baseAmount * downPaymentPercent / 100).setScale(2);

    totalPaymentAmount =
        downPaymentAmount + dldAmount + adminFee;

    /* ===== GENERATE INSTALLMENTS ===== */
  Boolean isStandardPlan =
    offer.Payment_Plan__c == 'Standard Payment Plan – 0% Discount';

Date previousDate;

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

    Decimal amount = (baseAmount * percent / 100).setScale(2);

    // ================= DATE LOGIC =================
    Date milestoneDate;

    if (isStandardPlan) {

        if (i == 1) {
            // ✅ Row 1 = Generated Date (Today / Deal Date)
            milestoneDate = dealDate;
        }
        else if (i == 2) {
            // ✅ Row 2 = 45 Days from Row 1
            milestoneDate = dealDate.addDays(45);
        }
        else {
            // ✅ From Row 3 onward = +1 Month from previous row
            milestoneDate = previousDate.addMonths(1);
        }

        previousDate = milestoneDate;
    }
    else {
        // Existing behaviour for other plans (unchanged)
        Date startDate = dealDate.addMonths(1);
        milestoneDate = startDate.addMonths(i - 1);
    }

    // ================= LABEL LOGIC =================
    String label;

    if (i == 1) {
        label = 'Down Payment - Installment 1';
    }
    else if (i == 30) {
        label = 'Installment 30 (Handover)';
    }
    else {
        label = 'Installment ' + i;
    }

    installmentList.add(
        new InstallmentRow(
            i,
            label,
            milestoneDate,
            percent,
            amount
        )
    );
}



}

    /* ================= WRAPPER ================= */
  public class InstallmentRow {
    public Integer rowIndex { get; set; }
    public String label { get; set; }
    public Date milestoneDate { get; set; }
    public Decimal percent { get; set; }
    public Decimal amount { get; set; }

    public InstallmentRow(
        Integer rowIndex,
        String label,
        Date milestoneDate,
        Decimal percent,
        Decimal amount
    ) {
        this.rowIndex = rowIndex;
        this.label = label;
        this.milestoneDate = milestoneDate;
        this.percent = percent;
        this.amount = amount;
    }
}


    /* ================= PDF FILE NAME ================= */
	public void setPdfFileName() { 

    // Convert Date → DateTime to use format()
    DateTime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));

    String todayDate = dt.format('dd-MMM-yyyy');

    ApexPages.currentPage().getHeaders().put(
        'Content-Disposition',
        'attachment; filename="SalesOffer_' + offer.Name + '_' + todayDate + '.pdf"'
    );
}


}