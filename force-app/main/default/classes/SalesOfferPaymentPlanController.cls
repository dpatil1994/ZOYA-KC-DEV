/**
* @File Name         : SalesOfferPaymentPlanController .cls
* @Description       : SalesOfferPaymentPlanController manages the display and calculation of payment plans for sales 
					   offers. It retrieves the sales offer and related property unit information, calculates fees such 
					   as DLD and admin charges, applies discounts based on the selected payment plan, and generates 
					   installment schedules for standard, 30%, 50%, and 100% down payment plans. The controller also 
					   calculates down payment amounts, remaining installment counts, and total payable amounts. 
					   Additionally, it handles loading property unit images and prepares file name headers for downloading 
					   payment plans as PDFs, providing a comprehensive view of the offer and payment details for use in 
					   Visualforce pages.
*
* @Author            : KC0115
* @Last Modified By  : Sanjeev Kumar Ray
* @Last Modified On  : December 30, 2025
* @Modification Log  :
*==============================================================================
* Ver | Date         | Author              | Modification
*==============================================================================
* 1.0 | December 30, 2025 | Sanjeev Kumar Ray | Initial Version
**/




public with sharing class SalesOfferPaymentPlanController {

    /* =======================
       BASIC OFFER DETAILS
       ======================= */
    public String offerName { get; set; }
    public Decimal originalPrice { get; set; }
    public Decimal netPrice { get; set; }
    public Date offerDate { get; set; }
    public String projectName { get; set; }

    public Sales_Offer__c salesOffer { get; set; }

    /* =======================
       FEES
       ======================= */
    public Decimal dldPercentage { get; set; }
    public Decimal dldAmount { get; set; }
    public Decimal adminFee { get; set; }
    public Decimal remainingAmount { get; set; }
   
    /* =======================
       Property Unit Images
       ======================= */
    public String unitImageUrl { get; set; }
    public Boolean hasUnitImage { get; set; }
    public String propertyUnitName { get; set; }
    public String propertyUnitType { get; set; }
    public Decimal propertyTotalArea { get; set; }
    public Decimal propertyTotalAmount { get; set; }
    public Decimal propertyDiscountPercent { get; set; }
    public Decimal propertyDiscountAmount { get; set; }
    public Decimal propertyDiscountedAmount { get; set; }
    public String recordOwnerName { get; set; }

    /* =======================
       PAYMENT PLAN
       ======================= */
    public List<PaymentInstallment> paymentPlan { get; set; }
    public Boolean isMultiPagePlan { get; set; }
    public String paymentPlanType { get; set; }

    /* =======================
       INNER CLASS
       ======================= */
    public class PaymentInstallment {
        public String installmentName { get; set; }
        public Date milestoneDate { get; set; }
        public Decimal percentage { get; set; }
        public Decimal amount { get; set; }
    }

    /* =======================
       CONSTRUCTOR
       ======================= */
    public SalesOfferPaymentPlanController(ApexPages.StandardController controller) {

        // Get Offer Id
        Id offerId = ApexPages.currentPage().getParameters().get('id');
        if(offerId == null){
         //   offerId = 'a04WE000003pl4nYAA'; // fallback (remove in prod)
        }

        // Query Offer
        salesOffer = [
            SELECT Name,
                   Original_Price__c,
                   Net_Price__c,
                   Offer_Date__c,
                   CreatedDate,
                   Project__r.Name,
                   Payment_Plan__c,
                   Property_Unit__r.Name,
                   Property_Unit__r.Unit_Type__c,
                   Property_Unit__r.Total_Area_Sq_ft__c,
                   Property_Unit__r.Original_Price__c,
                   Owner.Name
            FROM Sales_Offer__c
            WHERE Id = :offerId
            LIMIT 1
        ];

        // =======================
        // BASIC INFO
        // =======================
        offerName        = salesOffer.Name;
        originalPrice    = salesOffer.Original_Price__c != null ? salesOffer.Original_Price__c : 0;
        netPrice         = salesOffer.Net_Price__c != null ? salesOffer.Net_Price__c : 0;
        offerDate        = salesOffer.Offer_Date__c != null ? salesOffer.Offer_Date__c : salesOffer.CreatedDate.date();
        projectName      = salesOffer.Project__r.Name;
        propertyUnitName = salesOffer.Property_Unit__r != null ? salesOffer.Property_Unit__r.Name : null;
        propertyUnitType = salesOffer.Property_Unit__r != null ? salesOffer.Property_Unit__r.Unit_Type__c : null;
        propertyTotalArea= salesOffer.Property_Unit__r != null ? salesOffer.Property_Unit__r.Total_Area_Sq_ft__c : 0;
        propertyTotalAmount = salesOffer.Property_Unit__r != null ? salesOffer.Property_Unit__r.Original_Price__c : 0;
        recordOwnerName  = salesOffer.Owner.Name;
        paymentPlanType  = salesOffer.Payment_Plan__c;

        // =======================
        // FEES & DISCOUNT
        // =======================
        dldPercentage = 4;
        dldAmount = (netPrice * dldPercentage / 100).setScale(2);
        adminFee = 3500;

        // Discount from picklist dynamically
        propertyDiscountPercent = getDiscountPercentDecimal();
        propertyDiscountAmount = (propertyTotalAmount * propertyDiscountPercent / 100).setScale(2);
        propertyDiscountedAmount = (propertyTotalAmount - propertyDiscountAmount).setScale(2); 


        // =======================
        // PAYMENT PLAN LOGIC
        // =======================
        String plan = salesOffer.Payment_Plan__c;

        if(plan == 'Standard Payment Plan – 0% Discount'){
            initPaymentPlan69();
        } else if(plan == '30% Down Payment – 4% Discount'){
            initPaymentPlan30();
        } else if(plan == '50% Down Payment – 8% Discount'){initPaymentPlan50();
        } else if(plan == '100% Down Payment (No ROI) – 20% Discount'){
            initPaymentPlan100();
        } else {initPaymentPlan69(); // default
        }

        isMultiPagePlan = paymentPlan != null && paymentPlan.size() > 40;

        // Load property unit image
        loadPropertyUnitImage();

        // =======================
        // CALCULATE REMAINING AMOUNT
        // =======================
        remainingAmount = getRemainingAmount();
    }
    

    /* =======================
       PAYMENT PLAN INITIALIZERS
       ======================= */
   public void initPaymentPlan69() {
    Map<Integer, Decimal> special = new Map<Integer, Decimal>{
        0 => 10,  // 1st installment
        1 => 10,  // 2nd installment
        29 => 10  // 30th installment
    };
    generatePlan(69, special, 5); // last installment = 5%
}


   public void initPaymentPlan30() {
    Map<Integer, Decimal> special = new Map<Integer, Decimal>{
        0 => 30,  // 1st installment = 30%
        29 => 10  // 30th installment = 10%
    };
    generatePlan(58, special, 5); // last installment = 5%
}

   public void initPaymentPlan50() {
    Map<Integer, Decimal> special = new Map<Integer, Decimal>{
        0 => 50,  // 1st installment = 50%
        29 => 10  // 30th installment = 10%
    };
    generatePlan(38, special, 5); // last installment = 5%
}


  public void initPaymentPlan100() {
    paymentPlan = new List<PaymentInstallment>();
    PaymentInstallment inst = new PaymentInstallment();
    inst.installmentName = '100% Down Payment';
    inst.milestoneDate = offerDate;
    inst.percentage = 100;

    // Use Discounted Price here instead of Original Price
    Decimal baseAmount = propertyDiscountedAmount != null ? propertyDiscountedAmount : originalPrice;
    inst.amount = baseAmount.setScale(2);

    paymentPlan.add(inst);
}


    /* =======================
       GENERATOR METHOD
       ======================= */
 private void generatePlan(
    Integer totalInstallments,
    Map<Integer, Decimal> specialInstallments,
    Decimal lastInstallmentPercent
) {
    paymentPlan = new List<PaymentInstallment>();

    // 🟡 CHANGED: For Standard Payment Plan we need special date logic (45 days gap then monthly)
    Boolean isStandardPlan = (paymentPlanType == 'Standard Payment Plan – 0% Discount');
    Date previousDate = null;

    for(Integer i = 0; i < totalInstallments; i++){
        Decimal percent;

        if(specialInstallments.containsKey(i)){
            percent = specialInstallments.get(i);
        } else if(i == totalInstallments - 1){
            percent = lastInstallmentPercent;
        } else {
            percent = 1;
        }

        PaymentInstallment inst = new PaymentInstallment();

        // === CUSTOM INSTALLMENT NAMES (unchanged) ===
        if (i == 0) {
            inst.installmentName = 'Down Payment - Installment 1';
        } else if (i == 29) {
            inst.installmentName = 'Installment 30 (Handover)';
        } else {
            inst.installmentName = 'Installment ' + (i + 1);
        }

        // === 🟡 CHANGED: Milestone Date logic – conditionally apply 45‑day rule ===
       // === ✅ UPDATED: Milestone Date logic – 45 days ONLY for first row ===
if (isStandardPlan) {

    if (i == 0) {
        // First installment → 45 days from offer date
        inst.milestoneDate = offerDate.addDays(45);
    } else {
        // All remaining installments → +1 month from previous installment
        inst.milestoneDate = previousDate.addMonths(1);
    }

    previousDate = inst.milestoneDate;

}else {
            // Original logic for all other plans
            inst.milestoneDate = offerDate.addMonths(i + 1);
        }
        // ===============================================

        Decimal baseAmount = propertyDiscountedAmount != null ? propertyDiscountedAmount : originalPrice;
        inst.percentage = percent;
        inst.amount = (baseAmount * percent / 100).setScale(2);

        paymentPlan.add(inst);
    }
}

    /* =======================
       PROPERTY UNIT IMAGE
       ======================= */
    private void loadPropertyUnitImage() {
        hasUnitImage = false;

        if(salesOffer.Property_Unit__c == null){
            return;
        }

        List<ContentDocumentLink> cdlList = [
            SELECT ContentDocumentId,
                   ContentDocument.LatestPublishedVersionId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :salesOffer.Property_Unit__c
            ORDER BY ContentDocument.CreatedDate DESC
            LIMIT 1
        ];

        if(!cdlList.isEmpty()){
            String versionId = cdlList[0].ContentDocument.LatestPublishedVersionId;
            unitImageUrl = '/sfc/servlet.shepherd/version/download/' + versionId;
            hasUnitImage = true;
        }
    }

    /* =======================
       DOWN PAYMENT CALCULATION
       ======================= */
   public Decimal getDownPaymentAmount() {
    if (propertyDiscountedAmount == null || paymentPlanType == null) {
        return 0;
    }

    Decimal percent = 0;

    if (paymentPlanType == 'Standard Payment Plan – 0% Discount') {
        percent = 0; // 0% means NO down payment
    } 
    else if (paymentPlanType == '30% Down Payment – 4% Discount') {
        percent = 30;
    } 
    else if (paymentPlanType == '50% Down Payment – 8% Discount') {
        percent = 50;
    } 
    else if (paymentPlanType == '100% Down Payment (No ROI) – 20% Discount') {
        percent = 100;
    }

    // If percent is 0 → amount should be 0
    if (percent == 0) {
        return 0;
    }

    // Calculate on DISCOUNTED PRICE
    return (propertyDiscountedAmount * percent / 100).setScale(2);
}


    /* =======================
       REMAINING INSTALLMENTS
       ======================= */
 public Integer getRemainingInstallmentCount() {
    if (paymentPlan == null || paymentPlan.isEmpty()) {
        return 0;
    }

    // Special case: 100% Down Payment → show 0
    if (paymentPlanType == '100% Down Payment (No ROI) – 20% Discount') {
        return 0;
    }

    // Default: return all installments count (banki)
    return paymentPlan.size();
}





    /* =======================
       REMAINING AMOUNT
       ======================= */
 public Decimal getRemainingAmount() {
    Decimal discountedAmount = propertyDiscountedAmount != null ? propertyDiscountedAmount : 0;
    Decimal admin = adminFee != null ? adminFee : 0;
    Decimal dld = dldAmount != null ? dldAmount : 0;

    Decimal downPayment = getDownPaymentAmount(); // 0 if 0%

    Decimal remaining;

    // If down payment is 0%, entire discounted amount goes to remaining installments
    if (downPayment == 0) {
        remaining = discountedAmount - admin - dld;
    } else {
        remaining = discountedAmount - downPayment - admin - dld;
    }

    return remaining > 0 ? remaining.setScale(2) : 0;
}


    
    // for picklist value and display in % on PDF Field

    /* =======================
   PAYMENT PLAN DISCOUNT %
   ======================= */
public String getPaymentPlanDiscountPercent() {
    if (paymentPlanType == null) {
        return '';
    }

    // Regex to extract percentage like 0%, 4%, 8%, 20%
    Pattern p = Pattern.compile('(\\d+%)');
    Matcher m = p.matcher(paymentPlanType);

    if (m.find()) {
        return m.group(1);
    }

    return '';
}
    
   public Decimal getDownPaymentPercent() {
    if (paymentPlanType == null) return 0;

    // Extract first number followed by %
    Pattern p = Pattern.compile('(\\d+)%');
    Matcher m = p.matcher(paymentPlanType);

    if (m.find()) {
        // First % number = down payment %
        return Decimal.valueOf(m.group(1));
    }

    return 0;
}

public Integer getDownPaymentCount() {
    return getDownPaymentAmount() > 0 ? 1 : 0;
}

public Decimal getDiscountPercentDecimal() {
    if (paymentPlanType == null) return 0;

    // Extract the number followed by % from the picklist
    Pattern p = Pattern.compile('(\\d+)%');
    Matcher m = p.matcher(paymentPlanType);

    Decimal discountPercent = 0;
    while (m.find()) {
        // Last number in picklist is always the discount percent
        discountPercent = Decimal.valueOf(m.group(1));
    }

    return discountPercent;
}
    
    
public void setPdfFileName() {
    if (salesOffer != null && salesOffer.Name != null) {
        DateTime dt = DateTime.now();
        String todayStr = dt.format('dd-MMM-yyyy');

        ApexPages.currentPage().getHeaders().put(
            'Content-Disposition',
            'attachment; filename="Sales_Offer_' + salesOffer.Name + '_' + todayStr + '.pdf"'
        );
    }
}


// Total of Down Payment + DLD + Admin Fee
public Decimal getTotalPaymentAmount() {
    Decimal downPayment = getDownPaymentAmount();
    Decimal dld = dldAmount != null ? dldAmount : 0;
    Decimal admin = adminFee != null ? adminFee : 0;

    Decimal total = downPayment + dld + admin;
    return total.setScale(2);
}


}